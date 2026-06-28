import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AssessmentSummaryCard extends StatelessWidget {
  const AssessmentSummaryCard({required this.durationText, super.key});

  final String durationText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFFF5FBFF),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.schedule, color: AppColors.mutedText),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Duración estimada',
              style: TextStyle(color: Color(0xFF102532), fontSize: 16),
            ),
          ),
          Text(
            durationText,
            style: const TextStyle(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
