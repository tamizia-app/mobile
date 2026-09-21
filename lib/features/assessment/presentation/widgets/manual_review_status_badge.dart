import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_states.dart';
import '../../domain/models/manual_review.dart';

class ManualReviewStatusBadge extends StatelessWidget {
  const ManualReviewStatusBadge({
    required this.status,
    required this.requiredReview,
    super.key,
  });
  final ManualReviewStatus status;
  final bool requiredReview;

  @override
  Widget build(BuildContext context) {
    final (label, icon, color) = switch (status) {
      ManualReviewStatus.confirmed => (
        'Confirmado por docente',
        Icons.verified_outlined,
        AppColors.success,
      ),
      ManualReviewStatus.overridden => (
        'Ajustado manualmente',
        Icons.edit_note,
        AppColors.primary,
      ),
      ManualReviewStatus.reverted => (
        'Revertido al resultado automático',
        Icons.history,
        AppColors.mutedText,
      ),
      ManualReviewStatus.pending => (
        'Pendiente de revisión',
        Icons.flag_outlined,
        AppColors.warning,
      ),
      _ when requiredReview => (
        'Pendiente de revisión',
        Icons.flag_outlined,
        AppColors.warning,
      ),
      ManualReviewStatus.notRequired => (
        'Sin revisión requerida',
        Icons.check_circle_outline,
        AppColors.mutedText,
      ),
      _ => (
        'Estado de revisión no disponible',
        Icons.help_outline,
        AppColors.mutedText,
      ),
    };
    return AppStatusBadge(label: label, icon: icon, color: color);
  }
}

String reviewMetricLabel(String name) => switch (name) {
  'char_accuracy' => 'Precisión de caracteres',
  'word_accuracy' => 'Precisión de palabras',
  'similarity_score' => 'Similitud de escritura',
  'accuracy_score' => 'Precisión',
  'fluency_score' => 'Fluidez',
  'pronunciation_score' => 'Pronunciación',
  'completeness_score' => 'Completitud',
  'lexical_match' => 'Coincidencia léxica',
  _ => 'Métrica adicional',
};

String reviewSourceLabel(MetricSource? source) => switch (source) {
  MetricSource.automatic => 'Automática',
  MetricSource.reviewedEvidence => 'Recalculada desde texto revisado',
  MetricSource.teacherOverride => 'Ajustada por docente',
  _ => 'Origen no informado',
};

String reviewActionLabel(String action) => switch (action) {
  'confirm' => 'Confirmación del resultado',
  'correct_evidence' => 'Corrección de texto',
  'override_metrics' => 'Ajuste de métricas',
  'revert' => 'Reversión al automático',
  _ => 'Revisión',
};

String reviewScore(double? value) =>
    value == null ? 'No disponible' : '${value.toStringAsFixed(1)} / 100';
