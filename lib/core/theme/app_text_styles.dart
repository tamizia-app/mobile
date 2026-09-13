import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTextStyles {
  const AppTextStyles._();

  static const appTitle = TextStyle(
    color: AppColors.neutralDark,
    fontSize: 26,
    fontWeight: FontWeight.w800,
    letterSpacing: 0,
  );

  static const splashTitle = TextStyle(
    color: AppColors.neutralDark,
    fontSize: 34,
    fontWeight: FontWeight.w800,
    letterSpacing: 0,
  );

  static const pageTitle = TextStyle(
    color: Color(0xFF1F2937),
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
  );

  static const body = TextStyle(
    color: AppColors.neutralGray,
    fontSize: 14,
    height: 1.45,
  );

  static const label = TextStyle(
    color: Color(0xFF374151),
    fontSize: 13,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
  );

  static const helper = TextStyle(color: AppColors.mutedText, fontSize: 12);

  static const button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
  );
}
