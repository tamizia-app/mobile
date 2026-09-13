import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_tokens.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({
    required this.title,
    this.showBack = false,
    this.trailing,
    this.onBack,
    this.centerTitle = false,
    super.key,
  });
  final String title;
  final bool showBack;
  final Widget? trailing;
  final VoidCallback? onBack;
  final bool centerTitle;
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      color: AppColors.surface,
      border: Border(bottom: BorderSide(color: AppColors.divider)),
    ),
    child: SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppSizes.touch),
          child: Row(
            children: [
              if (showBack) ...[
                IconButton(
                  tooltip: 'Volver',
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: onBack ?? () => Navigator.pop(context),
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(title, style: AppTextStyles.headingSmall),
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: AppSpacing.sm),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    ),
  );
}

class TeacherGreetingHeader extends StatelessWidget {
  const TeacherGreetingHeader({required this.name, super.key});
  final String name;
  @override
  Widget build(BuildContext context) => ColoredBox(
    color: AppColors.surface,
    child: SafeArea(
      bottom: false,
      child: Padding(
        padding: AppSpacing.page,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 4,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.brandOrange,
                borderRadius: BorderRadius.circular(AppRadius.small),
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TamizIA · Espacio docente',
                    style: AppTextStyles.labelMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text('Hola, $name', style: AppTextStyles.headingMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
