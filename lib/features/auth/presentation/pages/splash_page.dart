import 'package:flutter/material.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/primary_button.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 4),
              Container(
                width: 198,
                height: 198,
                decoration: BoxDecoration(
                  color: AppColors.surfaceWhite,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.secondaryOrange.withValues(alpha: 0.18),
                    width: 4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.10),
                      blurRadius: 26,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child: Center(
                  child: SizedBox(
                    width: 96,
                    height: 84,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          Icons.menu_book_rounded,
                          color: const Color(0xFF334B67),
                          size: 78,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 3,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        Positioned(
                          right: 12,
                          top: 10,
                          child: Icon(
                            Icons.search_rounded,
                            color: const Color(0xFF226F98),
                            size: 42,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.20),
                                blurRadius: 2,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 34),
              const Text(
                AppStrings.splashName,
                style: AppTextStyles.splashTitle,
              ),
              const SizedBox(height: 16),
              const Text(
                AppStrings.splashDescription,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF4A403C),
                  fontSize: 19,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 36),
              PrimaryButton(
                text: AppStrings.start,
                icon: Icons.arrow_forward_rounded,
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, AppRoutes.login),
              ),
              const Spacer(flex: 5),
            ],
          ),
        ),
      ),
    );
  }
}
