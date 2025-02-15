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

class _GameModeScreenState extends State<GameModeScreen> with SingleTickerProviderStateMixin {
  String selectedMode = "Online";
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250), // Even shorter duration
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(  // Reduced scale
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void selectMode(String mode) {
    if (selectedMode != mode) {  // Only animate if selecting a different mode
      setState(() {
        selectedMode = mode;
      });
      _animationController.forward(from: 0.0);
    }
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
              const SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildModeButton(
                      "Offline", Icons.shield, selectedMode == "Offline", 
                      [const Color(0xFF9575CD), const Color(0xFF7E57C2)]), // Light purple
                  const SizedBox(width: 30),
                  _buildModeButton(
                      "Online", Icons.sports, selectedMode == "Online",
                      [const Color.fromARGB(255, 146, 105, 217), const Color(0xFF673AB7)]), // Medium purple
                  const SizedBox(width: 30),
                  _buildModeButton("Multi player", Icons.group,
                      selectedMode == "Multi player",
                      [const Color.fromARGB(255, 120, 71, 205), const Color(0xFF5E35B1)]), // Deep purple
                ],
              ),
              const SizedBox(height: 50),
              ElevatedButton(
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
                  backgroundColor: const Color(0xFF673AB7), // Updated to match theme
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
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
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
      floatingActionButton: Transform.translate(
        offset: const Offset(0, -5),
        child: FloatingActionButton(
          backgroundColor: const Color(0xFF673AB7), // Updated to match theme
          child: Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF673AB7),
            ),
            child: Center(
              child: ClipOval(
                child: Image.asset(
                  'assets/images/logo1.png',
                  width: 70,
                  height: 70,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          onPressed: () {},
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildModeButton(String mode, IconData icon, bool isSelected, List<Color> gradientColors) {
    return GestureDetector(
      onTap: () => selectMode(mode),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              if (isSelected) ...[
                Transform.scale(
                  scale: 1.0 + (_pulseAnimation.value * 0.15),  // Reduced pulse effect
                  child: Container(
                    width: 115,  // Slightly smaller container
                    height: 115,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: gradientColors[0].withOpacity(0.15),  // Reduced opacity
                    ),
                  ),
                ),
              ],
              AnimatedContainer(  // Added AnimatedContainer for smooth size transition
                duration: const Duration(milliseconds: 200),
                width: isSelected ? 105 : 80,  // Reduced selected size
                height: isSelected ? 105 : 80,
                child: Transform.scale(
                  scale: isSelected ? _scaleAnimation.value : 1.0,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: gradientColors,
                        stops: const [0.2, 0.8],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: gradientColors[0].withOpacity(0.3),
                          blurRadius: isSelected ? 15 : 8,
                          offset: const Offset(-4, -4),
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: isSelected ? 15 : 8,
                          offset: const Offset(4, 4),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              IconAndText(
                icon: icon,
                text: mode,
                isSelected: isSelected,
              ),
            ],
          );
        },
      ),
    );
  }
}

class IconAndText extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isSelected;

  const IconAndText({
    required this.icon,
    required this.text,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: isSelected ? 40 : 32,
        ),
        const SizedBox(height: 5),
        Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: isSelected ? 14 : 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 2,
                offset: const Offset(1, 1),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
