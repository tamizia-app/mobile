import 'package:flutter/material.dart';
import '../../../../core/widgets/info_banner.dart';
import '../../../../core/widgets/app_states.dart';
import '../../../../core/theme/app_tokens.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/assessment_labels.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/error_message.dart';
import '../../domain/models/student_assessment_history.dart';
import '../../domain/repositories/assessment_repository.dart';

class StudentHistoryPage extends StatefulWidget {
  const StudentHistoryPage({
    required this.assessmentRepository,
    required this.studentId,
    super.key,
  });

  final AssessmentRepository assessmentRepository;
  final String studentId;

  @override
  State<StudentHistoryPage> createState() => _StudentHistoryPageState();
}

class _StudentHistoryPageState extends State<StudentHistoryPage> {
  StudentAssessmentHistory? _history;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final history = await widget.assessmentRepository.getStudentHistory(
        widget.studentId,
      );
      setState(() {
        _history = history;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'No se pudo cargar el historial del estudiante.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.teacherBackground,
      body: Column(
        children: [
          AppHeader(
            title: 'Historial del estudiante',
            showBack: true,
            centerTitle: true,
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const AppLoadingState(message: 'Cargando historial…');
    }
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: AppColors.errorRed,
                size: 48,
              ),
              const SizedBox(height: AppSpacing.lg),
              ErrorMessage(text: _errorMessage!),
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(
                text: 'Reintentar',
                icon: Icons.refresh,
                onPressed: _loadData,
              ),
            ],
          ),
        ),
      );
    }
    final history = _history!;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (history.student != null) ...[
            _StudentHeader(student: history.student!),
            const SizedBox(height: AppSpacing.lg),
          ],
          _SummaryCards(summary: history.summaryForLoadedAttempts),
          const SizedBox(height: AppSpacing.xl),
          if (history.chartPoints.isNotEmpty)
            _ChartSection(points: history.chartPoints),
          if (history.chartPoints.isNotEmpty)
            const SizedBox(height: AppSpacing.xl),
          _HistorySection(items: history.items),
          const SizedBox(height: AppSpacing.xl),
          const InfoBanner(
            text:
                'Los resultados orientan el seguimiento pedagógico y no constituyen un diagnóstico clínico.',
          ),
        ],
      ),
    );
  }
}

class _StudentHeader extends StatelessWidget {
  const _StudentHeader({required this.student});

  final StudentBrief student;

  @override
  Widget build(BuildContext context) {
    final classroomStr = student.classroom != null
        ? '${student.classroom!.name} - ${student.classroom!.gradeLevel} ${student.classroom!.section}'
        : null;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.control),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
            child: const Icon(
              Icons.person_outline,
              color: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.code,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: AppFontSizes.body,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${student.age} años · ${translateGender(student.gender)}',
                  style: const TextStyle(
                    color: AppColors.mutedText,
                    fontSize: AppFontSizes.support,
                  ),
                ),
                if (classroomStr != null)
                  Text(
                    'Aula: $classroomStr',
                    style: const TextStyle(
                      color: AppColors.mutedText,
                      fontSize: AppFontSizes.support,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCards extends StatelessWidget {
  const _SummaryCards({required this.summary});

  final StudentHistorySummary summary;

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
            'Resumen',
            style: TextStyle(
              fontSize: AppFontSizes.bodyLarge,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Los puntajes se expresan como porcentajes sobre un máximo de 100 puntos. '
            'Por ejemplo, 80% equivale a 80 de 100 puntos. '
            'Un puntaje mayor indica un mejor resultado en los ejercicios.',
            style: TextStyle(
              color: AppColors.mutedText,
              fontSize: AppFontSizes.support,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Resumen de ${summary.completedAttemptsCount} intentos completados '
            'con puntaje en este historial.',
            style: const TextStyle(
              color: AppColors.mutedText,
              fontSize: AppFontSizes.support,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _chip('Último puntaje', _fmt(summary.latestScore)),
              _chip('Puntaje promedio', _fmt(summary.averageScore)),
              _chip('Puntaje más alto', _fmt(summary.bestScore)),
              _chip('Puntaje más bajo', _fmt(summary.lowestScore)),
              if (summary.latestInterventionLevel != null)
                _chip(
                  'Último nivel de intervención',
                  translateInterventionLevel(summary.latestInterventionLevel),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _chip(
            'Variación respecto al intento anterior',
            summary.trendPercentage == null
                ? 'No disponible'
                : '${summary.trendPercentage! > 0 ? '+' : ''}'
                      '${summary.trendPercentage!.toStringAsFixed(1)}%',
            color:
                summary.trendPercentage == null || summary.trendPercentage == 0
                ? AppColors.mutedText
                : summary.trendPercentage! > 0
                ? AppColors.successGreen
                : AppColors.errorRed,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            summary.trendPercentage == null
                ? 'La variación necesita dos intentos completados con puntaje '
                      'y que el puntaje anterior sea mayor que 0.'
                : 'Compara los dos últimos intentos completados con puntaje: '
                      '+ indica aumento, âˆ’ indica disminución y 0% indica que no hubo cambio. '
                      'Pasar de 50% a 60% equivale a un aumento relativo de 20% '
                      '(10 puntos porcentuales).',
            style: const TextStyle(
              color: AppColors.mutedText,
              fontSize: AppFontSizes.support,
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, String value, {Color? color}) {
    return Container(
      constraints: const BoxConstraints(minWidth: 90),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: (color ?? AppColors.primaryBlue).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.control),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.mutedText,
              fontSize: AppFontSizes.support,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: TextStyle(
              color: color ?? AppColors.primaryBlue,
              fontWeight: FontWeight.w700,
              fontSize: AppFontSizes.support,
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(double? value) =>
      value == null ? 'Sin puntaje' : '${value.toStringAsFixed(1)}%';
}

class _ChartSection extends StatelessWidget {
  const _ChartSection({required this.points});

  final List<StudentHistoryChartPoint> points;

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
            'Puntajes por intento (%)',
            style: TextStyle(
              fontSize: AppFontSizes.bodyLarge,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: points.map((point) {
                final dateStr = point.completedAt != null
                    ? '${point.completedAt!.day}/${point.completedAt!.month}/${point.completedAt!.year}'
                    : '';
                return Container(
                  constraints: const BoxConstraints(minWidth: 90),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(AppRadius.control),
                    border: Border.all(
                      color: AppColors.primaryBlue.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        point.finalScore != null
                            ? '${point.finalScore!.toStringAsFixed(1)}%'
                            : 'Sin puntaje',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: AppFontSizes.support,
                        ),
                      ),
                      if (dateStr.isNotEmpty)
                        Text(
                          dateStr,
                          style: const TextStyle(
                            color: AppColors.mutedText,
                            fontSize: AppFontSizes.support,
                          ),
                        ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistorySection extends StatelessWidget {
  const _HistorySection({required this.items});

  final List<StudentHistoryItem> items;

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
            'Historial',
            style: TextStyle(
              fontSize: AppFontSizes.bodyLarge,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'No hay historial disponible.',
                style: TextStyle(color: AppColors.mutedText),
              ),
            )
          else
            ...items.map((item) => _HistoryItemTile(item: item)),
        ],
      ),
    );
  }
}

class _HistoryItemTile extends StatelessWidget {
  const _HistoryItemTile({required this.item});

  final StudentHistoryItem item;

  @override
  Widget build(BuildContext context) {
    final dateStr = item.completedAt != null
        ? '${item.completedAt!.day}/${item.completedAt!.month}/${item.completedAt!.year}'
        : '—';
    return InkWell(
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.attemptReview,
        arguments: item.attemptId,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.assessmentName ?? 'Evaluación',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                const Icon(Icons.chevron_right, color: AppColors.mutedText),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              dateStr,
              style: const TextStyle(
                color: AppColors.mutedText,
                fontSize: AppFontSizes.support,
              ),
            ),
            AppDetailRow(
              label: 'Puntaje final',
              value: item.finalScore == null
                  ? 'Sin puntaje'
                  : '${item.finalScore!.toStringAsFixed(1)}%',
            ),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                AppStatusBadge(
                  label: translateAttemptStatus(item.status),
                  icon: Icons.assignment_outlined,
                ),
                if (item.interventionLevel != null)
                  AppStatusBadge(
                    label:
                        'Intervención: ${translateInterventionLevel(item.interventionLevel)}',
                    icon: Icons.info_outline,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
