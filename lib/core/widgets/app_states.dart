import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_tokens.dart';
import 'primary_button.dart';

class AppLoadingState extends StatelessWidget {
  const AppLoadingState({this.message = 'Cargando información…', super.key});
  final String message;
  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: AppSpacing.page,
      child: Semantics(
        liveRegion: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox.square(
              dimension: 28,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall,
            ),
          ],
        ),
      ),
    ),
  );
}

class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    required this.title,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
    super.key,
  });
  final String title;
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: AppSpacing.page,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 40, color: AppColors.primary),
            const SizedBox(height: AppSpacing.xl),
            Semantics(
              header: true,
              child: Text(title, style: AppTextStyles.headingSmall),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(message, style: AppTextStyles.bodySmall),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(text: actionLabel!, onPressed: onAction),
            ],
          ],
        ),
      ),
    ),
  );
}

class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader({required this.title, this.description, super.key});
  final String title;
  final String? description;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Semantics(
        header: true,
        child: Text(title, style: AppTextStyles.headingSmall),
      ),
      if (description != null) ...[
        const SizedBox(height: AppSpacing.xs),
        Text(description!, style: AppTextStyles.bodySmall),
      ],
    ],
  );
}

class AppStatusBadge extends StatelessWidget {
  const AppStatusBadge({
    required this.label,
    required this.icon,
    this.color = AppColors.primary,
    super.key,
  });
  final String label;
  final IconData icon;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.sm,
      vertical: AppSpacing.xs,
    ),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(AppRadius.small),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: AppSpacing.xs),
        Flexible(
          child: Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(color: color),
          ),
        ),
      ],
    ),
  );
}

class AppDetailRow extends StatelessWidget {
  const AppDetailRow({required this.label, required this.value, super.key});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final labelWidget = Text(label, style: AppTextStyles.bodySmall);
        final valueWidget = Text(value, style: AppTextStyles.labelLarge);
        if (constraints.maxWidth < 360 ||
            MediaQuery.textScalerOf(context).scale(16) > 22) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              labelWidget,
              const SizedBox(height: AppSpacing.xs),
              valueWidget,
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 2, child: labelWidget),
            const SizedBox(width: AppSpacing.lg),
            Expanded(flex: 3, child: valueWidget),
          ],
        );
      },
    ),
  );
}

/// An intrinsic-height collection avoids clipping long or enlarged labels.
class AppAdaptiveCollection extends StatelessWidget {
  const AppAdaptiveCollection({
    required this.children,
    this.minItemWidth = 280,
    this.maxColumns = 2,
    super.key,
  });
  final List<Widget> children;
  final double minItemWidth;
  final int maxColumns;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final scale = MediaQuery.textScalerOf(context).scale(16) / 16;
      final columns =
          ((constraints.maxWidth + 16) / (minItemWidth * scale + 16))
              .floor()
              .clamp(1, maxColumns);
      final width = (constraints.maxWidth - (columns - 1) * 16) / columns;
      return Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [
          for (final child in children) SizedBox(width: width, child: child),
        ],
      );
    },
  );
}

class AppActionGroup extends StatelessWidget {
  const AppActionGroup({required this.children, super.key});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      if (constraints.maxWidth < 380 ||
          MediaQuery.textScalerOf(context).scale(16) > 20) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0) const SizedBox(height: AppSpacing.md),
              children[i],
            ],
          ],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(width: AppSpacing.lg),
            Expanded(child: children[i]),
          ],
        ],
      );
    },
  );
}
