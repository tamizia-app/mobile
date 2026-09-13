import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';
import '../theme/app_text_styles.dart';

class SelectableWordCard extends StatelessWidget {
  const SelectableWordCard({
    required this.text,
    required this.selected,
    required this.onTap,
    super.key,
  });
  final String text;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Semantics(
    selected: selected,
    button: true,
    inMutuallyExclusiveGroup: true,
    child: Material(
      color: selected ? AppColors.secondary : AppColors.secondaryContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: AppColors.secondary, width: selected ? 3 : 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 80),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.check_circle_outline
                    : Icons.radio_button_unchecked,
                color: selected ? AppColors.surface : AppColors.secondary,
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Text(
                  text,
                  style: AppTextStyles.studentStimulus.copyWith(
                    color: selected ? AppColors.surface : AppColors.secondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
