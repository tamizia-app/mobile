import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryBlue,
        primary: AppColors.primaryBlue,
      ),
      fontFamily: 'Inter',
      scaffoldBackgroundColor: AppColors.backgroundLight,
      useMaterial3: true,
    );
  }
}
