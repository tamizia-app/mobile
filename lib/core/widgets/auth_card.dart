import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AuthCard extends StatelessWidget {
  const AuthCard({
    required this.child,
    this.borderRadius = 10,
    this.shadowOpacity = 0.06,
    super.key,
  });

  final Widget child;
  final double borderRadius;
  final double shadowOpacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: shadowOpacity),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}
