import 'package:flutter/material.dart';
import '../../features/students/domain/models/student.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';
import '../theme/app_text_styles.dart';
import 'app_states.dart';

class StudentCard extends StatelessWidget {
  const StudentCard({
    required this.student,
    required this.onTap,
    this.classroomName,
    super.key,
  });
  final Student student;
  final VoidCallback onTap;
  final String? classroomName;
  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.card),
      side: const BorderSide(color: AppColors.divider),
    ),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.person_outline,
              color: AppColors.primary,
              size: 28,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(student.code, style: AppTextStyles.headingSmall),
                  Text('${student.age} años', style: AppTextStyles.bodySmall),
                  if (classroomName != null)
                    Text(
                      'Aula: $classroomName',
                      style: AppTextStyles.bodySmall,
                    ),
                  const SizedBox(height: AppSpacing.sm),
                  AppStatusBadge(
                    label: student.isActive ? 'Activo' : 'Inactivo',
                    icon: student.isActive
                        ? Icons.check_circle_outline
                        : Icons.pause_circle_outline,
                    color: student.isActive
                        ? AppColors.success
                        : AppColors.textSecondary,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    ),
  );
}
