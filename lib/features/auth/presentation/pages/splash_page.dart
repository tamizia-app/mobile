import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

import '../../../../core/theme/app_text_styles.dart';

import '../../../../core/theme/app_tokens.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/widgets/primary_button.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.surface,
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: AppSpacing.page,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppSizes.formWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: AppLogo(size: 240),
                ),
                const SizedBox(height: AppSpacing.xxl),
                const Text(
                  'Cada aprendizaje merece atención.',
                  style: AppTextStyles.display,
                ),
                const SizedBox(height: AppSpacing.lg),
                const Text(
                  AppStrings.splashDescription,
                  style: AppTextStyles.bodyLarge,
                ),
                const SizedBox(height: AppSpacing.xxxl),
                PrimaryButton(
                  text: AppStrings.start,
                  icon: Icons.arrow_forward_rounded,
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, AppRoutes.login),
                ),
                const SizedBox(height: AppSpacing.xl),
                const Text(
                  'Un espacio para docentes de educación primaria.',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
