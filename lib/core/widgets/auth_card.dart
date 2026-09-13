import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';

class AuthCard extends StatelessWidget {
  const AuthCard({
    required this.child,
    this.borderRadius = AppRadius.card,
    this.shadowOpacity = 0,
    super.key,
  });
  final Widget child;
  final double borderRadius;
  final double shadowOpacity;
  @override
  Widget build(BuildContext context) => Container(
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: AppColors.divider),
    ),
    child: child,
  );
}
