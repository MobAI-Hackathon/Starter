import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/game_session.dart';
import '../services/game_service.dart';  // Add this import

class GameChat extends StatefulWidget {
  final GameSession gameSession;
  final String userId;
  final String userName;

  const GameChat({
    Key? key,
    required this.gameSession,
    required this.userId,
    required this.userName,
  }) : super(key: key);

  @override
  State<GameChat> createState() => _GameChatState();
}

class _GameChatState extends State<GameChat> {
  final _messageController = TextEditingController();
  final _chatRef = FirebaseDatabase.instance.ref().child('game_chats');
  final _gameService = GameService();  // Add this
  
  void _sendMessage(String message) {
    if (message.isEmpty) return;
    
    final isDrawer = widget.gameSession.players
        .firstWhere((p) => p.id == widget.userId)
        .isDrawing;
    
    if (isDrawer) return; // Drawer can't send messages
    
    final isCorrectGuess = widget.gameSession.currentWord?.toLowerCase() == 
        message.toLowerCase();
    
    _chatRef.child(widget.gameSession.id).push().set({
      'userId': widget.userId,
      'userName': widget.userName,
      'message': isCorrectGuess ? '🎉 Correct guess!' : message,
      'timestamp': ServerValue.timestamp,
      'isCorrectGuess': isCorrectGuess,
    });

    if (isCorrectGuess) {
      // Call game service to handle the correct guess
      _gameService.submitGuess(
        widget.gameSession.id,
        widget.userId,
        message
      );
      
      // Remove the old score update logic since it's now handled in submitGuess
    }

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: StreamBuilder(
            stream: _chatRef
                .child(widget.gameSession.id)
                .orderByChild('timestamp')
                .onValue,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(
                child: CircularProgressIndicator());

              final messages = <Map<String, dynamic>>[];
              if (snapshot.data?.snapshot.value != null) {
                // Fix type casting
                final messagesMap = Map<String, dynamic>.from(
                    snapshot.data!.snapshot.value as Map<Object?, Object?>);
                messages.addAll(messagesMap.values.map((value) => 
                    Map<String, dynamic>.from(value as Map<Object?, Object?>)));
                messages.sort((a, b) => 
                    (a['timestamp'] as int).compareTo(b['timestamp'] as int));
              }

              return ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  final isCurrentUser = message['userId'] == widget.userId;
                  final isCorrectGuess = message['isCorrectGuess'] ?? false;

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 8,
                    ),
                    child: Align(
                      alignment: isCurrentUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isCorrectGuess
                              ? Colors.green.shade100
                              : (isCurrentUser
                                  ? Colors.blue.shade100
                                  : Colors.grey.shade200),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              message['userName'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isCorrectGuess
                                    ? Colors.green
                                    : Colors.black87,
                              ),
                            ),
                            Text(message['message']),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        if (!widget.gameSession.players
            .firstWhere((p) => p.id == widget.userId)
            .isDrawing)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type your guess...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: _sendMessage,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _sendMessage(_messageController.text),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
