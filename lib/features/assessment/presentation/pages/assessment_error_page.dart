import 'package:flutter/material.dart';
import '../../../../core/widgets/app_states.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_header.dart';

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
            title: 'No se completó la sesión',
            showBack: true,
            centerTitle: true,
            onBack: () => Navigator.pushReplacementNamed(
              context,
              AppRoutes.templateCatalog,
            ),
          ),
          Expanded(
            child: AppEmptyState(
              title: 'No pudimos completar la actividad',
              message:
                  '$message Puedes volver a las plantillas para revisar la evaluación.',
              icon: Icons.error_outline,
              actionLabel: 'Volver a plantillas',
              onAction: () => Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.templateCatalog,
                (route) => false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
