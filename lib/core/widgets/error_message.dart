import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class ErrorMessage extends StatelessWidget {
  const ErrorMessage({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.error_outline, color: AppColors.errorRed, size: 16),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.errorRed,
              fontSize: 13,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}
