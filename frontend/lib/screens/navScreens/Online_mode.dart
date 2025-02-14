import 'package:flutter/material.dart';

class OnlineModeScreen extends StatefulWidget {
  const OnlineModeScreen({super.key});

  @override
  _OnlineModeScreenState createState() => _OnlineModeScreenState();
}

class _OnlineModeScreenState extends State<OnlineModeScreen> {
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
            children: const [
              Text(
                "Online Mode",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Add your online mode content here
            ],
          ),
        ),
      ),
    );
  }
}
