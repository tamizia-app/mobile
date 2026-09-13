import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';
import '../theme/app_colors.dart';

class StudentSuccessBanner extends StatelessWidget {
  const StudentSuccessBanner({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: AppColors.successContainer,
        borderRadius: BorderRadius.circular(AppRadius.control),
        border: Border.all(color: AppColors.successContainer),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.mood, color: AppColors.success, size: 21),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.success,
                fontSize: AppFontSizes.bodyLarge,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
