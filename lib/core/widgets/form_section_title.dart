import 'package:flutter/material.dart';

class FormSectionTitle extends StatelessWidget {
  const FormSectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF102532),
        fontSize: 17,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
    );
  }
}
