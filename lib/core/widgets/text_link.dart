import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class TextLink extends StatelessWidget {
  const TextLink({
    required this.text,
    required this.onTap,
    this.fontSize = 14,
    super.key,
  });

  final String text;
  final VoidCallback onTap;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(4),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          text,
          style: TextStyle(
            color: AppColors.primaryBlue,
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
