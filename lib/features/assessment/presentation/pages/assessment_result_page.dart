import 'package:flutter/material.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../domain/models/assessment_result.dart';

class AssessmentResultPage extends StatelessWidget {
  const AssessmentResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    final argument = ModalRoute.of(context)?.settings.arguments;
    if (argument is! AssessmentResult) {
      return const _MissingResultPage();
    }
    final result = argument;
    return Scaffold(
      backgroundColor: AppColors.teacherBackground,
      body: Column(
        children: [
          AppHeader(
            title: 'Resultado',
            showBack: true,
            centerTitle: true,
            onBack: () => Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.templateCatalog,
              (route) => false,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 28, 18, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.stars_rounded,
                          color: AppColors.secondaryOrange,
                          size: 52,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Sesion finalizada',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _scoreText(result),
                          style: const TextStyle(
                            color: AppColors.primaryBlue,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  _ResultCard(result: result),
                  const SizedBox(height: 26),
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
        ],
      ),
    );
  }

  String _scoreText(AssessmentResult result) {
    final finalScore = result.finalScore;
    final maxScore = result.maxScore;
    if (finalScore == null || maxScore == null) {
      return 'Resultado generado';
    }
    return '${finalScore.toStringAsFixed(1)} / ${maxScore.toStringAsFixed(1)}';
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result});

  final AssessmentResult result;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          _Row(label: 'Nivel', value: result.interventionLevel ?? 'N/D'),
          _Row(
            label: 'Ejercicios',
            value: '${result.evaluatedExercises}/${result.totalExercises}',
          ),
          _Row(label: 'Pendientes', value: '${result.pendingExercises}'),
          _Row(label: 'MC correctas', value: '${result.mcCorrectCount ?? 0}'),
          _Row(label: 'OS correctas', value: '${result.osCorrectCount ?? 0}'),
          _Row(
            label: 'Speaking',
            value:
                '${result.speakingCompletedCount ?? 0} completados | promedio ${_num(result.speakingAverageScore)}',
          ),
          _Row(
            label: 'Writing',
            value:
                '${result.writingCompletedCount ?? 0} completados | promedio ${_num(result.writingAverageScore)}',
          ),
        ],
      ),
    );
  }

  String _num(double? value) =>
      value == null ? 'N/D' : value.toStringAsFixed(1);
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.mutedText),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _MissingResultPage extends StatelessWidget {
  const _MissingResultPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('No se recibio el resultado.')),
    );
  }
}
