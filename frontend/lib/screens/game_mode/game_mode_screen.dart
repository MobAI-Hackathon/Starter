import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GameModeScreen extends StatelessWidget {
  const GameModeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/genback.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildModeButton(
                context,
                'Online Mode',
                () => Navigator.pushNamed(context, '/online_mode'),
                Colors.blue,
              ),
              const SizedBox(height: 20),
              _buildModeButton(
                context,
                'Offline Mode',
                () => Navigator.pushNamed(context, '/offline_mode'),
                Colors.green,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeButton(
    BuildContext context,
    String text,
    VoidCallback onPressed,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
