import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import '../models/game_session.dart';
import 'dart:math';

class GameService {
  final _database = FirebaseDatabase.instance.ref();
  final _wordList = [
    'apple', 'banana', 'cat', 'dog', 'elephant',
    'flower', 'guitar', 'house', 'ice cream', 'jellyfish',
    // Add more words as needed
  ];
  final _words = [
    'cat', 'dog', 'house', 'tree', 'car', 'sun', 'moon', 'star',
    'book', 'phone', 'computer', 'pizza', 'flower', 'bird', 'fish',
    'airplane', 'boat', 'train', 'bicycle', 'mountain', 'beach',
    'rainbow', 'butterfly', 'guitar', 'elephant', 'penguin', 'robot',
    'castle', 'dragon', 'unicorn', 'wizard', 'pirate', 'rocket',
    'dinosaur', 'superhero', 'mermaid', 'ghost', 'alien', 'monster'
  ];

  Stream<GameSession> subscribeToGame(String gameId) {
    return _database
        .child('game_sessions')
        .child(gameId)
        .onValue
        .map((event) {
      if (event.snapshot.value == null) {
        throw Exception('Game session not found');
      }
      // Fix type casting
      final data = Map<String, dynamic>.from(event.snapshot.value as Map<Object?, Object?>);
      return GameSession.fromJson(data);
    });
  }

  Future<void> joinGame(String gameId, Player player) async {
    final gameRef = _database.child('game_sessions').child(gameId);
    
    await gameRef.runTransaction((Object? obj) {
      if (obj == null) return Transaction.abort();
      
      final game = GameSession.fromJson(Map<String, dynamic>.from(obj as Map));
      if (game.players.any((p) => p.id == player.id)) return Transaction.success(obj);
      
      game.players.add(player);
      return Transaction.success(game.toJson());
    });
  }

  Future<void> submitGuess(String gameId, String playerId, String guess) async {
    final gameRef = _database.child('game_sessions').child(gameId);
    final snapshot = await gameRef.get();
    
    if (!snapshot.exists) return;
    
    final game = GameSession.fromJson(
      Map<String, dynamic>.from(snapshot.value as Map));
    
    if (game.currentWord?.toLowerCase() == guess.toLowerCase()) {
      // Update player score
      final playerIndex = game.players.indexWhere((p) => p.id == playerId);
      if (playerIndex != -1) {
        game.players[playerIndex].score += 100;
        await gameRef.child('players/$playerIndex/score')
            .set(game.players[playerIndex].score);
      }

      // End the current round and start the next one
      await endRound(gameId);
      await startNewRound(gameId);
    }
  }

  Future<void> startNewRound(String gameId) async {
    final gameRef = _database.child('game_sessions').child(gameId);
    final snapshot = await gameRef.get();
    if (!snapshot.exists) return;
    
    final game = GameSession.fromJson(Map<String, dynamic>.from(snapshot.value as Map));
    
    // Check minimum players
    if (game.players.length < 2) return;

    // Set max rounds based on number of players
    if (game.maxRounds != game.players.length) {
      await gameRef.update({
        'maxRounds': game.players.length,
      });
    }

    // Check if we've reached the maximum rounds
    if (game.currentRound >= game.players.length) {
      await gameRef.update({
        'state': GameState.gameOver.toString(),
      });
      return;
    }

    // Select new random word
    final word = _words[Random().nextInt(_words.length)];
    
    // Update game state
    await gameRef.update({
      'currentWord': word,
      'state': GameState.drawing.toString(),
      'roundStartTime': ServerValue.timestamp,
      'playersGuessedCorrect': [],
    });

    // Start round timer
    Timer(Duration(seconds: game.roundTime), () {
      endRound(gameId);
    });
  }

  Future<void> endRound(String gameId) async {
    final gameRef = _database.child('game_sessions').child(gameId);
    final snapshot = await gameRef.get();
    if (!snapshot.exists) return;
    
    final game = GameSession.fromJson(
      Map<String, dynamic>.from(snapshot.value as Map));
    
    // Increment round counter
    final nextRound = game.currentRound + 1;
    
    // Check if game should end
    if (nextRound >= game.players.length) {
      await gameRef.update({
        'state': GameState.gameOver.toString(),
        'currentRound': nextRound,
      });
      return;
    }
    
    // Rotate to next drawer
    final currentDrawerIndex = game.players.indexWhere((p) => p.isDrawing);
    final nextDrawerIndex = (currentDrawerIndex + 1) % game.players.length;
    
    game.players[currentDrawerIndex].isDrawing = false;
    game.players[nextDrawerIndex].isDrawing = true;

    // Update game state
    await gameRef.update({
      'state': GameState.waiting.toString(),
      'currentRound': nextRound,
      'players': game.players.map((p) => p.toJson()).toList(),
      'currentWord': null,
      'drawing_data': null,
      'playersGuessedCorrect': [],
    });

    // Start new round after a short delay
    Timer(const Duration(seconds: 3), () {
      startNewRound(gameId);
    });
  }

  Future<void> handleCorrectGuess(String gameId, String playerId) async {
    final gameRef = _database.child('game_sessions').child(gameId);
    final snapshot = await gameRef.get();
    if (!snapshot.exists) return;

    final game = GameSession.fromJson(Map<String, dynamic>.from(snapshot.value as Map));
    
    // Update scores
    final guessingPlayer = game.players.firstWhere((p) => p.id == playerId);
    final drawingPlayer = game.players.firstWhere((p) => p.isDrawing);
    
    guessingPlayer.score += 5;  // Points for guessing
    drawingPlayer.score += 2;   // Points for drawing

    // Add player to correct guesses list
    List<String> correctGuesses = [];
    final correctGuessesSnapshot = await gameRef.child('playersGuessedCorrect').get();
    if (correctGuessesSnapshot.exists && correctGuessesSnapshot.value != null) {
      correctGuesses = List<String>.from(correctGuessesSnapshot.value as List);
    }
    correctGuesses.add(playerId);

    // Update player scores and correct guesses
    await gameRef.update({
      'players': game.players.map((p) => p.toJson()).toList(),
      'playersGuessedCorrect': correctGuesses,
    });

    // Check if all non-drawing players have guessed correctly
    final nonDrawingPlayers = game.players.where((p) => !p.isDrawing).length;
    if (correctGuesses.length >= nonDrawingPlayers) {
      // End round if everyone has guessed
      await endRound(gameId);
    }
  }

  Stream<List<GameSession>> getAvailableGames() {
    return _database
        .child('game_sessions')
        .onValue
        .map((event) {
      final games = <GameSession>[];
      if (event.snapshot.value != null) {
        final gamesMap = Map<String, dynamic>.from(event.snapshot.value as Map);
        gamesMap.forEach((key, value) {
          final gameData = Map<String, dynamic>.from(value);
          gameData['id'] = key;
          final game = GameSession.fromJson(gameData);
          if (game.state == GameState.waiting) {
            games.add(game);
          }
        });
      }
      return games;
    });
  }
}
