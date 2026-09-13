import 'package:flutter/material.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/primary_button.dart';

class AssessmentErrorPage extends StatelessWidget {
  const AssessmentErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final argument = ModalRoute.of(context)?.settings.arguments;
    final message = argument is String && argument.trim().isNotEmpty
        ? argument
        : 'No se pudo completar la sesión.';
    return Scaffold(
      backgroundColor: AppColors.teacherBackground,
      body: Column(
        children: [
          AppHeader(
            title: 'Sesión fallida',
            showBack: true,
            centerTitle: true,
            onBack: () => Navigator.pushReplacementNamed(
              context,
              AppRoutes.templateCatalog,
            ),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: AppColors.errorRed,
                      size: 58,
                    ),
                    const SizedBox(height: 18),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 28),
                    PrimaryButton(
                      text: 'Volver a plantillas',
                      icon: Icons.assignment_outlined,
                      onPressed: () => Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.templateCatalog,
                        (route) => false,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
