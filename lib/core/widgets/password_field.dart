import 'package:flutter/material.dart';

import 'app_text_field.dart';

class PasswordField extends StatefulWidget {
  const PasswordField({
    required this.controller,
    required this.label,
    required this.hintText,
    this.validator,
    this.onChanged,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final String hintText;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: widget.controller,
      label: widget.label,
      hintText: widget.hintText,
      obscureText: _obscured,
      validator: widget.validator,
      onChanged: widget.onChanged,
      suffixIcon: IconButton(
        tooltip: _obscured ? 'Mostrar contraseña' : 'Ocultar contraseña',
        onPressed: () => setState(() => _obscured = !_obscured),
        icon: Icon(
          _obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: const Color(0xFF9CA3AF),
          size: 20,
        ),
      ),
    );
  }
}
