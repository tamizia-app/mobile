import 'package:flutter/material.dart';
import 'primary_button.dart';

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
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool primary;
  final bool orange;
  @override
  Widget build(BuildContext context) => PrimaryButton(
    text: text,
    onPressed: onPressed,
    icon: icon,
    student: true,
    variant: primary || orange
        ? AppButtonVariant.primary
        : AppButtonVariant.secondary,
  );
}
