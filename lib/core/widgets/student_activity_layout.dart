import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_tokens.dart';
import 'student_companion.dart';

/// A quiet, scrollable workspace; it does not own evaluation state or timing.
class StudentActivityLayout extends StatelessWidget {
  const StudentActivityLayout({
    required this.title,
    required this.onBack,
    required this.child,
    super.key,
  });
  final String title;
  final VoidCallback onBack;
  final Widget child;
  @override
  Widget build(BuildContext context) => Theme(
    data: Theme.of(context).copyWith(
      colorScheme: Theme.of(context).colorScheme.copyWith(
        primary: AppColors.secondary,
        primaryContainer: AppColors.secondaryContainer,
        onPrimary: AppColors.surface,
        onPrimaryContainer: AppColors.secondary,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.secondary,
        linearTrackColor: AppColors.secondaryContainer,
      ),
    ),
    child: Scaffold(
      backgroundColor: AppColors.studentBackground,
      body: Column(
        children: [
          _StudentActivityHeader(title: title, onBack: onBack),
          Expanded(
            child: SafeArea(
              top: false,
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppSizes.readingWidth,
                  ),
                  child: child,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class StudentTaskHeading extends StatelessWidget {
  const StudentTaskHeading({
    required this.progress,
    required this.instruction,
    super.key,
  });
  final String progress;
  final String instruction;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.secondaryContainer,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.route_rounded,
              size: 18,
              color: AppColors.secondary,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                progress,
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.secondary,
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: AppSpacing.md),
      StudentInstructionBubble(instruction: instruction),
    ],
  );
}

class StudentInstructionBubble extends StatelessWidget {
  const StudentInstructionBubble({required this.instruction, super.key});
  final String instruction;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final stacked =
          constraints.maxWidth < 300 ||
          MediaQuery.textScalerOf(context).scale(23) > 32;
      final message = Semantics(
        header: true,
        child: Text(instruction, style: AppTextStyles.studentInstruction),
      );
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.studentMint,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(24),
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
          border: Border.all(
            color: AppColors.studentTeal.withValues(alpha: 0.18),
          ),
        ),
        child: stacked
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const StudentCompanion(size: 56),
                  const SizedBox(height: AppSpacing.sm),
                  message,
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const StudentCompanion(),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: message),
                ],
              ),
      );
    },
  );
}

class _StudentActivityHeader extends StatelessWidget {
  const _StudentActivityHeader({required this.title, required this.onBack});
  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: AppColors.surface,
    child: SafeArea(
      bottom: false,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                IconButton.filledTonal(
                  tooltip: 'Volver',
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.secondaryContainer,
                    foregroundColor: AppColors.secondary,
                  ),
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(title, style: AppTextStyles.studentTitle),
                  ),
                ),
              ],
            ),
          ),
          const ExcludeSemantics(
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: ColoredBox(
                    color: AppColors.brandOrange,
                    child: SizedBox(height: 4),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: ColoredBox(
                    color: AppColors.studentYellow,
                    child: SizedBox(height: 4),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: ColoredBox(
                    color: AppColors.studentTeal,
                    child: SizedBox(height: 4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
