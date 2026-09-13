import 'package:flutter/material.dart';
import '../../features/exercises/domain/models/exercise.dart';
import '../theme/app_tokens.dart';
import '../theme/app_text_styles.dart';
import 'primary_button.dart';
import 'app_states.dart';

class ExerciseCard extends StatelessWidget {
  const ExerciseCard({
    required this.exercise,
    required this.onSelect,
    super.key,
  });
  final Exercise exercise;
  final VoidCallback onSelect;
  @override
  Widget build(BuildContext context) {
    final type = exercise.typeLabel.toLowerCase();
    final icon = type.contains('escritura') && type.contains('lectura')
        ? Icons.auto_stories_outlined
        : type.contains('escritura')
        ? Icons.edit_outlined
        : Icons.menu_book_outlined;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: AppSurfaces.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: AppStatusBadge(label: exercise.typeLabel, icon: icon),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(exercise.title, style: AppTextStyles.headingSmall),
          const SizedBox(height: AppSpacing.sm),
          Text(exercise.description, style: AppTextStyles.bodySmall),
          const SizedBox(height: AppSpacing.lg),
          Text(
            '${exercise.estimatedDurationMinutes} min · ${exercise.recommendedGrade}',
            style: AppTextStyles.labelMedium,
          ),
          const SizedBox(height: AppSpacing.xl),
          PrimaryButton(
            text: 'Ver ejercicio',
            icon: Icons.arrow_forward_rounded,
            onPressed: onSelect,
            variant: AppButtonVariant.secondary,
          ),
        ],
      ),
    );
  }
}
