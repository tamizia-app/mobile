import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';
import '../theme/app_text_styles.dart';

enum AppButtonVariant { primary, secondary, tertiary, danger }

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.text,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.student = false,
    this.variant = AppButtonVariant.primary,
    super.key,
  });
  final String text;
  final IconData? icon;
  final bool isLoading;
  final bool student;
  final AppButtonVariant variant;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          const SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: AppSpacing.md),
        ],
        Flexible(
          child: Text(
            isLoading ? 'Un momento…' : text,
            textAlign: TextAlign.center,
          ),
        ),
        if (!isLoading && icon != null) ...[
          const SizedBox(width: AppSpacing.sm),
          Icon(icon, size: 24),
        ],
      ],
    );
    final style = ButtonStyle(
      shape: student
          ? WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
            )
          : null,
      minimumSize: WidgetStatePropertyAll(
        Size(48, student ? AppSizes.studentTouch : AppSizes.button),
      ),
      textStyle: WidgetStatePropertyAll(
        Theme.of(context).textTheme.labelLarge!.merge(
          student ? AppTextStyles.studentButton : AppTextStyles.button,
        ),
      ),
    );
    final action = isLoading ? null : onPressed;
    final Widget button = switch (variant) {
      AppButtonVariant.secondary => OutlinedButton(
        style: style,
        onPressed: action,
        child: content,
      ),
      AppButtonVariant.tertiary => TextButton(
        style: style,
        onPressed: action,
        child: content,
      ),
      AppButtonVariant.danger => FilledButton(
        style: style.copyWith(
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled)
                ? AppColors.surfaceVariant
                : AppColors.error,
          ),
        ),
        onPressed: action,
        child: content,
      ),
      AppButtonVariant.primary => FilledButton(
        style: style,
        onPressed: action,
        child: content,
      ),
    };
    return Semantics(
      liveRegion: isLoading,
      label: isLoading ? '$text. En proceso' : null,
      child: SizedBox(width: double.infinity, child: button),
    );
  }
}
