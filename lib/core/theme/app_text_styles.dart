import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  const AppTextStyles._();
  static const display = TextStyle(
    fontSize: 32,
    height: 1.25,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );
  static const headingLarge = TextStyle(
    fontSize: 28,
    height: 1.3,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );
  static const headingMedium = TextStyle(
    fontSize: 24,
    height: 1.3,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );
  static const headingSmall = TextStyle(
    fontSize: 20,
    height: 1.35,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );
  static const bodyLarge = TextStyle(
    fontSize: 18,
    height: 1.5,
    color: AppColors.textPrimary,
  );
  static const bodyMedium = TextStyle(
    fontSize: 16,
    height: 1.5,
    color: AppColors.textPrimary,
  );
  static const bodySmall = TextStyle(
    fontSize: 14,
    height: 1.5,
    color: AppColors.textSecondary,
  );
  static const labelLarge = TextStyle(
    fontSize: 16,
    height: 1.35,
    fontWeight: FontWeight.w600,
  );
  static const labelMedium = TextStyle(
    fontSize: 14,
    height: 1.4,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );
  static const studentInstruction = TextStyle(
    fontFamily: 'Fredoka',
    fontSize: 23,
    height: 1.35,
    color: AppColors.textPrimary,
    fontWeight: FontWeight.w500,
  );
  static const studentTitle = TextStyle(
    fontFamily: 'Fredoka',
    fontSize: 22,
    height: 1.25,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );
  static const studentButton = TextStyle(
    fontFamily: 'Fredoka',
    fontSize: 20,
    height: 1.3,
    fontWeight: FontWeight.w500,
  );
  static const studentStimulus = TextStyle(
    fontSize: 28,
    height: 1.5,
    color: AppColors.textPrimary,
    fontWeight: FontWeight.w500,
  );
  static const appTitle = headingLarge;
  static const splashTitle = display;
  static const pageTitle = headingSmall;
  static const body = bodyMedium;
  static const label = labelMedium;
  static const helper = bodySmall;
  static const button = labelLarge;
}
