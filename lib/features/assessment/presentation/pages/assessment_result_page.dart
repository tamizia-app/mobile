import 'package:flutter/material.dart';
import '../../../../core/widgets/app_states.dart';
import '../../../../core/widgets/assessment_result_summary.dart';
import '../../../../core/theme/app_tokens.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/assessment_labels.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../domain/models/assessment_result.dart';

class AssessmentResultPage extends StatefulWidget {
  const AssessmentResultPage({super.key});

  @override
  State<AssessmentResultPage> createState() => _AssessmentResultPageState();
}

class _AssessmentResultPageState extends State<AssessmentResultPage> {
  bool _showTeacherResult = false;
  @override
  Widget build(BuildContext context) {
    final argument = ModalRoute.of(context)?.settings.arguments;
    if (argument is! AssessmentResult) {
      return const _MissingResultPage();
    }
    final result = argument;
    if (!_showTeacherResult) {
      return Scaffold(
        backgroundColor: AppColors.studentBackground,
        body: SafeArea(
          child: AppEmptyState(
            title: '¡Terminaste las actividades!',
            message:
                'Gracias por participar. Ahora entrega el dispositivo a tu docente.',
            icon: Icons.check_circle_outline,
            actionLabel: 'Docente: ver resultados',
            onAction: () => setState(() => _showTeacherResult = true),
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: AppColors.teacherBackground,
      body: Column(
        children: [
          AppHeader(
            title: 'Resultados de la evaluación',
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
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.xl,
                AppSpacing.lg,
                AppSpacing.xxl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AssessmentResultSummary(
                    score: result.finalScore,
                    level: result.interventionLevel,
                    pending: result.pendingExercises,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _SummaryCard(result: result),
                  if (result.exerciseSummaries.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.lg),
                    _ExerciseSummariesCard(summaries: result.exerciseSummaries),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  PrimaryButton(
                    text: 'Ver detalle del intento',
                    icon: Icons.visibility_outlined,
                    onPressed: () => Navigator.pushNamed(
                      context,
                      AppRoutes.attemptReview,
                      arguments: result.attemptId,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  PrimaryButton(
                    text: 'Volver a evaluaciones',
                    variant: AppButtonVariant.secondary,
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

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.result});

  final AssessmentResult result;

  @override
  Widget build(BuildContext context) {
    final hasMC = result.mcCorrectCount != null;
    final hasOS = result.osCorrectCount != null;
    final hasSpeaking =
        _hasType('READING_SPEAKING') || _hasType('LISTENING_SPEAKING');
    final hasWriting =
        _hasType('READING_WRITING') || _hasType('LISTENING_WRITING');
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.control),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          _Row(
            label: 'Ejercicios',
            value: '${result.evaluatedExercises}/${result.totalExercises}',
          ),
          _Row(label: 'Pendientes', value: '${result.pendingExercises}'),
          if (hasMC)
            _Row(
              label: 'Selección múltiple',
              value: '${result.mcCorrectCount ?? 0} correctas',
            ),
          if (hasOS)
            _Row(
              label: 'Orden de sílabas',
              value: '${result.osCorrectCount ?? 0} correctas',
            ),
          if (hasSpeaking)
            _Row(
              label: 'Expresión oral',
              value:
                  '${result.speakingCompletedCount ?? 0} completados | promedio ${_num(result.speakingAverageScore)}',
            ),
          if (hasWriting)
            _Row(
              label: 'Escritura',
              value:
                  '${result.writingCompletedCount ?? 0} completados | promedio ${_num(result.writingAverageScore)}',
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
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.control),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumen por ejercicio',
            style: TextStyle(
              fontSize: AppFontSizes.bodyLarge,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
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
                      borderRadius: BorderRadius.circular(AppRadius.card),
                    ),
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w700,
                        fontSize: AppFontSizes.support,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                summary.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            if (summary.reviewRequired)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.secondaryOrange.withValues(
                                    alpha: 0.15,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.card,
                                  ),
                                ),
                                child: const Text(
                                  'Revisar',
                                  style: TextStyle(
                                    color: AppColors.secondaryOrange,
                                    fontSize: AppFontSizes.support,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          children: [
                            Text(
                              translateExerciseType(summary.type),
                              style: const TextStyle(
                                color: AppColors.mutedText,
                                fontSize: AppFontSizes.support,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Text(
                              translateExerciseStatus(summary.status),
                              style: const TextStyle(
                                color: AppColors.mutedText,
                                fontSize: AppFontSizes.support,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Text(
                              'Calidad: ${summary.technicalStatus.apiValue}',
                              style: TextStyle(
                                color: summary.scoreEligible
                                    ? AppColors.successGreen
                                    : AppColors.secondaryOrange,
                                fontSize: AppFontSizes.support,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (summary.score != null) ...[
                              const SizedBox(width: AppSpacing.md),
                              Text(
                                '${summary.score!.toStringAsFixed(1)}%',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: AppFontSizes.support,
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
              style: const TextStyle(fontWeight: FontWeight.w700),
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
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: AppEmptyState(
        title: 'No hay un resultado disponible',
        message: 'Vuelve a las evaluaciones para consultar el intento.',
        icon: Icons.assignment_outlined,
        actionLabel: 'Ver evaluaciones',
        onAction: () =>
            Navigator.pushReplacementNamed(context, AppRoutes.templateCatalog),
      ),
    ),
  );
}
