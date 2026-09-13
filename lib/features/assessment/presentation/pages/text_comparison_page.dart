import 'package:flutter/material.dart';
import '../../../../core/theme/app_tokens.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_header.dart';
import '../../domain/models/text_comparison_args.dart';

class TextComparisonPage extends StatelessWidget {
  const TextComparisonPage({super.key});

  @override
  Widget build(BuildContext context) {
    final argument = ModalRoute.of(context)?.settings.arguments;
    final args = argument is TextComparisonArgs
        ? argument
        : const TextComparisonArgs(
            expectedText: 'No disponible',
            recognizedText: 'No disponible',
          );
    return Scaffold(
      backgroundColor: AppColors.teacherBackground,
      body: Column(
        children: [
          AppHeader(
            title: args.title,
            showBack: true,
            centerTitle: true,
            onBack: () => Navigator.pop(context),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.xl,
                AppSpacing.lg,
                AppSpacing.xxl,
              ),
              children: [
                _TextPanel(label: 'Texto esperado', text: args.expectedText),
                const SizedBox(height: AppSpacing.lg),
                _TextPanel(
                  label: 'Texto reconocido',
                  text: args.recognizedText,
                  accent: AppColors.secondaryOrange,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TextPanel extends StatelessWidget {
  const _TextPanel({
    required this.label,
    required this.text,
    this.accent = AppColors.primaryBlue,
  });

  final String label;
  final String text;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.control),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: accent,
              fontSize: AppFontSizes.body,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            text,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: AppFontSizes.bodyLarge,
              height: 1.45,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
