import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppFloatingButton extends StatelessWidget {
  const AppFloatingButton({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: AppColors.primaryBlue,
      foregroundColor: Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: const Icon(Icons.add, size: 32),
    );
  }
}
