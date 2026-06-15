import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    required this.controller,
    required this.label,
    required this.hintText,
    this.keyboardType,
    this.validator,
    this.obscureText = false,
    this.suffixIcon,
    this.onChanged,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final String hintText;
  final TextInputType? keyboardType;
  final FormFieldValidator<String>? validator;
  final bool obscureText;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final labelParts = label.split('*');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: AppTextStyles.label,
            children: [
              TextSpan(text: labelParts.first),
              if (label.contains('*'))
                const TextSpan(
                  text: '*',
                  style: TextStyle(color: AppColors.errorRed),
                ),
              if (labelParts.length > 1 && labelParts.last.isNotEmpty)
                TextSpan(text: labelParts.last),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          obscureText: obscureText,
          onChanged: onChanged,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          style: const TextStyle(
            color: AppColors.neutralDark,
            fontSize: 16,
            letterSpacing: 0,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 16),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: const Color(0xFFFCFDFF),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 15,
            ),
            enabledBorder: inputBorder(AppColors.borderGray),
            focusedBorder: inputBorder(AppColors.primaryBlue, width: 1.5),
            errorBorder: inputBorder(AppColors.errorRed),
            focusedErrorBorder: inputBorder(AppColors.errorRed, width: 1.5),
            errorStyle: const TextStyle(
              color: AppColors.errorRed,
              fontSize: 11,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}

OutlineInputBorder inputBorder(Color color, {double width = 1}) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: color, width: width),
  );
}
