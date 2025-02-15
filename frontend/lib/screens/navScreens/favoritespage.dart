import 'package:flutter/material.dart';
import 'package:hanini_frontend/screens/game_room_screen.dart';
import 'package:hanini_frontend/screens/navScreens/homepage.dart';
import 'package:hanini_frontend/screens/navScreens/Online_mode.dart';
import 'package:hanini_frontend/screens/scribble_lobby_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const GameModeScreen(),
    );
  }
}

class GameModeScreen extends StatefulWidget {
  const GameModeScreen({super.key});

  @override
  _GameModeScreenState createState() => _GameModeScreenState();
}

class _GameModeScreenState extends State<GameModeScreen> {
  String selectedMode = "Online"; // Default is Online

  void selectMode(String mode) {
    setState(() {
      selectedMode = mode;
    });
    // Remove any direct navigation from here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 100), // Add top padding
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Choose a mode\nand start playing!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 300), // Increased from 120 to 180
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildModeButton(
                        "Offline", Icons.shield, selectedMode == "Offline"),
                    const SizedBox(width: 30),
                    _buildModeButton(
                        "Online", Icons.sports, selectedMode == "Online"),
                    const SizedBox(width: 30),
                    _buildModeButton("Multi player", Icons.group,
                        selectedMode == "Multi player"),
                  ],
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 100),
                  child: ElevatedButton(
                    onPressed: () {
                      // Only navigate when Start button is pressed
                      if (selectedMode == "Online") {
                        Navigator.push(  // Changed from pushReplacement to push
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChallengeScreen(),
                          ),
                        );
                      } else if (selectedMode == "Offline") {
                        Navigator.push(  // Changed from pushReplacement to push
                          context,
                          MaterialPageRoute(
                            builder: (context) => SketchPredictionPage(),
                          ),
                        );
                      } else if (selectedMode == "Multi player") {
                        Navigator.push(  // Changed from pushReplacement to push
                          context,
                          MaterialPageRoute(
                            builder: (context) => ScribbleLobbyScreen(),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6A5EDE),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Start',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const [
            Icon(Icons.home, color: Colors.grey),
            Icon(Icons.people, color: Colors.grey),
            SizedBox(width: 48),
            Icon(Icons.menu, color: Colors.grey),
            Icon(Icons.settings, color: Colors.grey),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF6A5EDE),
        child: const Icon(Icons.create),
        onPressed: () {},
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildModeButton(String mode, IconData icon, bool isSelected) {
    return GestureDetector(
      onTap: () => selectMode(mode),  // This now only updates the selection
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: isSelected ? 110 : 80,
        height: isSelected ? 110 : 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            colors: [
              const Color(0xFF1a1a1a),
              Colors.black.withOpacity(0.8),
            ],
          ),
          border:
              isSelected ? Border.all(color: Colors.yellow, width: 4) : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: isSelected ? 40 : 32,
            ),
            const SizedBox(height: 5),
            Text(
              mode,
              style: TextStyle(
                color: Colors.white,
                fontSize: isSelected ? 14 : 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
