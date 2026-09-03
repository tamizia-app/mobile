import 'package:flutter/material.dart';

class StudentSuccessBanner extends StatelessWidget {
  const StudentSuccessBanner({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFFFF4),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF9DF5BA)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.mood, color: Color(0xFF16A34A), size: 21),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF147A3A),
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
