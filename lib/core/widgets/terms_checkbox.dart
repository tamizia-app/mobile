import 'package:flutter/material.dart';

import '../constants/app_strings.dart';
import '../theme/app_colors.dart';

class TermsCheckbox extends StatelessWidget {
  const TermsCheckbox({
    required this.value,
    required this.onChanged,
    this.errorText,
    super.key,
  });

  final bool value;
  final String? errorText;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: Checkbox(
                value: value,
                onChanged: onChanged,
                activeColor: AppColors.primaryBlue,
                side: const BorderSide(color: AppColors.borderGray),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: RichText(
                text: const TextSpan(
                  style: TextStyle(
                    color: AppColors.neutralGray,
                    fontSize: 12,
                    height: 1.35,
                  ),
                  children: [
                    TextSpan(text: AppStrings.acceptTermsStart),
                    TextSpan(
                      text: AppStrings.termsAndConditions,
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextSpan(text: AppStrings.andPrivacy),
                    TextSpan(
                      text: AppStrings.privacyPolicy,
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Text(
            errorText!,
            style: const TextStyle(color: AppColors.errorRed, fontSize: 11),
          ),
        ],
      ],
    );
  }
}
