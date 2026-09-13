import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';
import 'app_states.dart';

class AssessmentSummaryCard extends StatelessWidget {
  const AssessmentSummaryCard({required this.durationText, super.key});
  final String durationText;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(AppSpacing.lg),
    decoration: AppSurfaces.card,
    child: AppDetailRow(label: 'Duración estimada', value: durationText),
  );
}
