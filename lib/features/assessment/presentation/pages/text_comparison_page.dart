import 'package:flutter/material.dart';

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
              padding: const EdgeInsets.fromLTRB(18, 24, 18, 32),
              children: [
                _TextPanel(label: 'Texto esperado', text: args.expectedText),
                const SizedBox(height: 16),
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: accent,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFF102532),
              fontSize: 18,
              height: 1.45,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
