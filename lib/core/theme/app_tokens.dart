import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppSpacing {
  const AppSpacing._();
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
  static const xxxl = 40.0;
  static const huge = 48.0;
  static const page = EdgeInsets.all(xl);
}

class AppRadius {
  const AppRadius._();
  static const small = 4.0;
  static const control = 8.0;
  static const card = 12.0;
  static const panel = 16.0;
}

class AppSizes {
  const AppSizes._();
  static const touch = 48.0;
  static const button = 52.0;
  static const studentTouch = 64.0;
  static const formWidth = 520.0;
  static const readingWidth = 640.0;
}

class AppElevation {
  const AppElevation._();
  static const flat = 0.0;
  static const floating = 2.0;
}

class AppSurfaces {
  const AppSurfaces._();
  static BoxDecoration get card => BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(AppRadius.card),
    border: Border.all(color: AppColors.divider),
  );
}

class AppFontSizes {
  const AppFontSizes._();
  static const support = 14.0;
  static const body = 16.0;
  static const bodyLarge = 18.0;
  static const title = 20.0;
  static const section = 24.0;
  static const heading = 28.0;
  static const display = 32.0;
}
