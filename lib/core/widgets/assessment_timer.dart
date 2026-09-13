import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AssessmentTimer extends StatelessWidget {
  const AssessmentTimer({this.minutes = '00', this.seconds = '15', super.key});
  final String minutes;
  final String seconds;
  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Tiempo transcurrido: $minutes minutos, $seconds segundos',
    excludeSemantics: true,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.schedule_outlined,
          size: 18,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: AppSpacing.sm),
        Flexible(
          child: Text('$minutes:$seconds', style: AppTextStyles.bodySmall),
        ),
      ],
    ),
  );
}
