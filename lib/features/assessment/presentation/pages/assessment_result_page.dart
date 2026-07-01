import 'package:flutter/material.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/assessment_labels.dart';
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
            title: 'Evaluacion completada',
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
                  _ScoreCard(score: result.finalScore, interventionLevel: result.interventionLevel),
                  const SizedBox(height: 18),
                  _SummaryCard(result: result),
                  if (result.exerciseSummaries.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    _ExerciseSummariesCard(summaries: result.exerciseSummaries),
                  ],
                  const SizedBox(height: 26),
                  PrimaryButton(
                    text: 'Ver detalle del intento',
                    icon: Icons.visibility_outlined,
                    onPressed: () => Navigator.pushNamed(
                      context,
                      AppRoutes.attemptReview,
                      arguments: result.attemptId,
                    ),
                  ),
                  const SizedBox(height: 12),
                  PrimaryButton(
                    text: 'Volver a evaluaciones',
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
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({required this.score, required this.interventionLevel});

  final double? score;
  final String? interventionLevel;

  @override
  Widget build(BuildContext context) {
    final scoreText = score != null ? '${score!.toStringAsFixed(1)}%' : '—';
    final levelLabel = translateInterventionLevel(interventionLevel);
    return Container(
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
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          Text(
            scoreText,
            style: const TextStyle(
              color: AppColors.primaryBlue,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (interventionLevel != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: _levelColor(interventionLevel).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                levelLabel,
                style: TextStyle(
                  color: _levelColor(interventionLevel),
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.result});

  final AssessmentResult result;

  @override
  Widget build(BuildContext context) {
    final hasMC = result.mcCorrectCount != null;
    final hasOS = result.osCorrectCount != null;
    final hasSpeaking = _hasType('READING_SPEAKING') || _hasType('LISTENING_SPEAKING');
    final hasWriting = _hasType('READING_WRITING') || _hasType('LISTENING_WRITING');
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          _Row(label: 'Ejercicios', value: '${result.evaluatedExercises}/${result.totalExercises}'),
          _Row(label: 'Pendientes', value: '${result.pendingExercises}'),
          if (hasMC) _Row(label: 'MC correctas', value: '${result.mcCorrectCount ?? 0}'),
          if (hasOS) _Row(label: 'OS correctas', value: '${result.osCorrectCount ?? 0}'),
          if (hasSpeaking)
            _Row(
              label: 'Speaking',
              value: '${result.speakingCompletedCount ?? 0} completados | promedio ${_num(result.speakingAverageScore)}',
            ),
          if (hasWriting)
            _Row(
              label: 'Writing',
              value: '${result.writingCompletedCount ?? 0} completados | promedio ${_num(result.writingAverageScore)}',
            ),
        ],
      ),
    );
  }

  bool _hasType(String type) {
    return result.exerciseSummaries.any(
      (e) => e.type.trim().toUpperCase() == type,
    );
  }

  String _num(double? value) =>
      value == null ? 'N/D' : value.toStringAsFixed(1);
}

class _ExerciseSummariesCard extends StatelessWidget {
  const _ExerciseSummariesCard({required this.summaries});

  final List<ExerciseSummary> summaries;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumen por ejercicio',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 14),
          ...summaries.asMap().entries.map((entry) {
            final index = entry.key;
            final summary = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                summary.title,
                                style: const TextStyle(fontWeight: FontWeight.w800),
                              ),
                            ),
                            if (summary.reviewRequired)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.secondaryOrange.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  'Revisar',
                                  style: TextStyle(
                                    color: AppColors.secondaryOrange,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              translateExerciseType(summary.type),
                              style: const TextStyle(
                                color: AppColors.mutedText,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              translateExerciseStatus(summary.status),
                              style: const TextStyle(
                                color: AppColors.mutedText,
                                fontSize: 13,
                              ),
                            ),
                            if (summary.score != null) ...[
                              const SizedBox(width: 12),
                              Text(
                                '${summary.score!.toStringAsFixed(1)}%',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
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

Color _levelColor(String? level) {
  switch (level?.toUpperCase()) {
    case 'LOW':
      return const Color(0xFF16A34A);
    case 'MEDIUM':
      return AppColors.secondaryOrange;
    case 'HIGH':
      return AppColors.errorRed;
    default:
      return AppColors.mutedText;
  }
}