import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_tokens.dart';
import '../theme/app_text_styles.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    required this.controller,
    required this.label,
    required this.hintText,
    this.keyboardType,
    this.validator,
    this.inputFormatters,
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
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    keyboardType: keyboardType,
    inputFormatters: inputFormatters,
    validator: validator,
    obscureText: obscureText,
    onChanged: onChanged,
    autovalidateMode: AutovalidateMode.onUserInteraction,
    style: AppTextStyles.bodyMedium,
    decoration: InputDecoration(
      labelText: label,
      hintText: hintText,
      suffixIcon: suffixIcon,
    ),
  );
}

OutlineInputBorder inputBorder(Color color, {double width = 1}) =>
    OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.control),
      borderSide: BorderSide(color: color, width: width),
    );
