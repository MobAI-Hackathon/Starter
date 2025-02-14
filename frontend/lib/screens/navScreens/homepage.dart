import 'package:flutter/material.dart';
import '../../widgets/simple_drawing_canvas.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drawing Training'),
        elevation: 0,
      ),
      body: const SafeArea(
        child: SimpleDrawingCanvas(),
      ),
    );
  }
}
