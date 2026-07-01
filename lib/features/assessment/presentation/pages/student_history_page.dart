import 'package:flutter/material.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/assessment_labels.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/error_message.dart';
import '../../domain/models/student_assessment_history.dart';
import '../../domain/models/student_attempt_list.dart';
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
  StudentAttemptList? _attempts;
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
      final results = await Future.wait([
        widget.assessmentRepository.getStudentHistory(widget.studentId),
        widget.assessmentRepository.getAttemptsByStudent(widget.studentId),
      ]);
      setState(() {
        _history = results[0] as StudentAssessmentHistory;
        _attempts = results[1] as StudentAttemptList;
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
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: AppColors.errorRed, size: 48),
              const SizedBox(height: 16),
              ErrorMessage(text: _errorMessage!),
              const SizedBox(height: 20),
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
    final attempts = _attempts!;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SummaryCards(summary: history.summary),
          const SizedBox(height: 22),
          if (history.chartPoints.isNotEmpty) _ChartSection(points: history.chartPoints),
          if (history.chartPoints.isNotEmpty) const SizedBox(height: 22),
          _HistorySection(items: history.items),
          const SizedBox(height: 22),
          _AttemptsSection(
            items: attempts.items,
            onTapAttempt: _onAttemptTap,
          ),
        ],
      ),
    );
  }

  void _onAttemptTap(StudentAttemptListItem item) {
    final status = item.status.trim().toUpperCase();
    if (status == 'COMPLETED' || status == 'FINISHED') {
      Navigator.pushNamed(
        context,
        AppRoutes.attemptReview,
        arguments: item.attemptId,
      );
    } else if (status == 'IN_PROGRESS' || status == 'STARTED') {
      Navigator.pushNamed(
        context,
        AppRoutes.assessmentAttemptSession,
        arguments: item.attemptId,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Intento pendiente')),
      );
    }
  }
}

class _SummaryCards extends StatelessWidget {
  const _SummaryCards({required this.summary});

  final StudentHistorySummary summary;

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
            'Resumen',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _chip('Ultimo score', _fmt(summary.latestScore)),
              _chip('Promedio', _fmt(summary.averageScore)),
              _chip('Mejor', _fmt(summary.bestScore)),
              _chip('Menor', _fmt(summary.lowestScore)),
              if (summary.trendPercentage != null)
                _chip(
                  'Tendencia',
                  '${summary.trendPercentage! >= 0 ? '+' : ''}${summary.trendPercentage!.toStringAsFixed(1)}%',
                  color: summary.trendPercentage! >= 0
                      ? AppColors.successGreen
                      : AppColors.errorRed,
                ),
              if (summary.latestInterventionLevel != null)
                _chip(
                  'Nivel',
                  translateInterventionLevel(summary.latestInterventionLevel),
                ),
            ],
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
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: AppColors.mutedText, fontSize: 11)),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: color ?? AppColors.primaryBlue,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(double? value) =>
      value == null ? '—' : '${value.toStringAsFixed(1)}%';
}

class _ChartSection extends StatelessWidget {
  const _ChartSection({required this.points});

  final List<StudentHistoryChartPoint> points;

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
          const Text('Puntajes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          SizedBox(
            height: 60,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: points.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final point = points[index];
                final dateStr = point.completedAt != null
                    ? '${point.completedAt!.day}/${point.completedAt!.month}'
                    : '';
                return Container(
                  width: 70,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: AppColors.primaryBlue.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        point.finalScore != null
                            ? '${point.finalScore!.toStringAsFixed(0)}%'
                            : '—',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                      ),
                      if (dateStr.isNotEmpty)
                        Text(dateStr, style: const TextStyle(color: AppColors.mutedText, fontSize: 10)),
                    ],
                  ),
                );
              },
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Historial', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('No hay historial disponible.', style: TextStyle(color: AppColors.mutedText)),
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
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.assessmentName ?? 'Evaluacion',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 2),
                  Text(dateStr, style: const TextStyle(color: AppColors.mutedText, fontSize: 12)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (item.finalScore != null)
                  Text(
                    '${item.finalScore!.toStringAsFixed(1)}%',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                  ),
                Text(
                  translateAttemptStatus(item.status),
                  style: const TextStyle(color: AppColors.mutedText, fontSize: 12),
                ),
                if (item.interventionLevel != null)
                  Text(
                    translateInterventionLevel(item.interventionLevel),
                    style: const TextStyle(color: AppColors.mutedText, fontSize: 11),
                  ),
              ],
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, color: AppColors.mutedText, size: 20),
          ],
        ),
      ),
    );
  }
}

class _AttemptsSection extends StatelessWidget {
  const _AttemptsSection({required this.items, required this.onTapAttempt});

  final List<StudentAttemptListItem> items;
  final void Function(StudentAttemptListItem) onTapAttempt;

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
          const Text('Intentos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('No hay intentos registrados.', style: TextStyle(color: AppColors.mutedText)),
            )
          else
            ...items.map((item) => _AttemptItemTile(item: item, onTap: () => onTapAttempt(item))),
        ],
      ),
    );
  }
}

class _AttemptItemTile extends StatelessWidget {
  const _AttemptItemTile({required this.item, required this.onTap});

  final StudentAttemptListItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dateStr = item.completedAt ?? item.startedAt;
    final formattedDate = dateStr != null
        ? '${dateStr.day}/${dateStr.month}/${dateStr.year}'
        : '—';
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.assessmentName ?? 'Evaluacion',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 2),
                  Text(formattedDate, style: const TextStyle(color: AppColors.mutedText, fontSize: 12)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  translateAttemptStatus(item.status),
                  style: const TextStyle(color: AppColors.mutedText, fontSize: 12),
                ),
                if (item.finalScore != null)
                  Text(
                    '${item.finalScore!.toStringAsFixed(1)}%',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                  ),
                Text(
                  '${item.totalExercises} ejercicios',
                  style: const TextStyle(color: AppColors.mutedText, fontSize: 11),
                ),
              ],
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, color: AppColors.mutedText, size: 20),
          ],
        ),
      ),
    );
  }
}
