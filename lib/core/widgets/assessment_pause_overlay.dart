import '../theme/app_tokens.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AssessmentPauseOverlay extends StatelessWidget {
  const AssessmentPauseOverlay({required this.visible, super.key});

  final bool visible;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    return Positioned.fill(
      child: IgnorePointer(
        child: Container(
          alignment: Alignment.center,
          color: Colors.white.withValues(alpha: 0.58),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: 16,
            ),
            decoration: BoxDecoration(
              color: AppColors.textPrimary,
              borderRadius: BorderRadius.circular(AppRadius.panel),
            ),
            child: const Text(
              'Evaluación pausada',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
