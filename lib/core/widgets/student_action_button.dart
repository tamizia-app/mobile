import 'package:flutter/material.dart';

class StudentActionButton extends StatelessWidget {
  const StudentActionButton({
    required this.text,
    required this.onPressed,
    this.icon,
    this.primary = false,
    this.orange = false,
    super.key,
  });

  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool primary;
  final bool orange;

  @override
  Widget build(BuildContext context) {
    final background = orange
        ? const Color(0xFFFF5B0A)
        : primary
        ? const Color(0xFF28150E)
        : const Color(0xFFE6E9EE);
    final foreground = primary || orange
        ? Colors.white
        : const Color(0xFF231610);
    return SizedBox(
      height: 56,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: icon == null ? const SizedBox.shrink() : Icon(icon, size: 18),
        label: Text(text),
        style: FilledButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
