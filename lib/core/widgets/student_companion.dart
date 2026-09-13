import 'package:flutter/material.dart';

/// A quiet visual guide. It never reacts to the correctness of an answer.
class StudentCompanion extends StatelessWidget {
  const StudentCompanion({this.size = 76, super.key});

  final double size;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Image.asset(
      'assets/images/tamizia_companion.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      excludeFromSemantics: true,
    ),
  );
}
