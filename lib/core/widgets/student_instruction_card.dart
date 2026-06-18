import 'package:flutter/material.dart';

class StudentInstructionCard extends StatelessWidget {
  const StudentInstructionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 234,
      height: 257,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFF7B2D), Color(0xFFFFAE60)],
        ),
      ),
      child: const Center(
        child: CircleAvatar(
          radius: 72,
          backgroundColor: Color(0xFFFFD39D),
          child: Icon(Icons.flutter_dash, size: 92, color: Color(0xFF8D4B20)),
        ),
      ),
    );
  }
}
