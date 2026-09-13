import 'package:flutter/material.dart';
import '../constants/app_strings.dart';
import '../theme/app_text_styles.dart';
import 'error_message.dart';

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
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      CheckboxListTile(
        contentPadding: EdgeInsets.zero,
        controlAffinity: ListTileControlAffinity.leading,
        value: value,
        onChanged: onChanged,
        title: const Text(
          '${AppStrings.acceptTermsStart}${AppStrings.termsAndConditions}${AppStrings.andPrivacy}${AppStrings.privacyPolicy}',
          style: AppTextStyles.bodySmall,
        ),
      ),
      if (errorText != null) ErrorMessage(text: errorText!),
    ],
  );
}
