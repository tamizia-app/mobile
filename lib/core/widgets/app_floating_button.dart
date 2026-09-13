import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';

import '../theme/app_colors.dart';

class AppFloatingButton extends StatelessWidget {
  const AppFloatingButton({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      backgroundColor: AppColors.primaryBlue,
      foregroundColor: Colors.white,
      elevation: AppElevation.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.control),
      ),
      icon: const Icon(Icons.add),
      label: const Text('Crear aula'),
    );
  }
}
