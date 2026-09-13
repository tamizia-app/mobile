import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_tokens.dart';
import '../utils/assessment_labels.dart';
import 'app_states.dart';
import 'info_banner.dart';

/// Describes the server's intervention level without calculating risk from score.
class AssessmentResultSummary extends StatelessWidget {
  const AssessmentResultSummary({
    required this.score,
    required this.level,
    this.pending = 0,
    super.key,
  });
  final double? score;
  final String? level;
  final int pending;
  @override
  Widget build(BuildContext context) {
    final normalized = level?.trim().toUpperCase();
    final (color, icon, meaning) = switch (normalized) {
      'LOW' => (
        AppColors.success,
        Icons.check_circle_outline,
        'El resultado indica un nivel bajo de intervención. Continúa observando el aprendizaje en el aula.',
      ),
      'MEDIUM' => (
        AppColors.warning,
        Icons.info_outline,
        'El resultado indica un nivel medio de intervención. Revisa los indicadores y planifica el seguimiento pedagógico.',
      ),
      'HIGH' => (
        AppColors.error,
        Icons.flag_outlined,
        'El resultado indica un nivel alto de intervención. Revisa la evidencia y coordina el seguimiento con el equipo de apoyo.',
      ),
      _ => (
        AppColors.textSecondary,
        Icons.help_outline,
        'No hay una interpretación disponible para este resultado. Revisa la evidencia antes de tomar decisiones.',
      ),
    };
    return Container(
      decoration: AppSurfaces.card,
      padding: AppSpacing.page,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Resultado orientativo', style: AppTextStyles.labelMedium),
          const SizedBox(height: AppSpacing.lg),
          Align(
            alignment: Alignment.centerLeft,
            child: AppStatusBadge(
              label: 'Intervención: ${translateInterventionLevel(level)}',
              icon: icon,
              color: color,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(meaning, style: AppTextStyles.bodyMedium),
          const SizedBox(height: AppSpacing.xl),
          AppDetailRow(
            label: 'Puntaje de los ejercicios',
            value: score == null
                ? 'Sin puntaje disponible'
                : '${score!.toStringAsFixed(1)}%',
          ),
          const Text(
            'El puntaje resume el desempeño en estas actividades; no es una probabilidad de dislexia.',
            style: AppTextStyles.bodySmall,
          ),
          if (pending > 0) ...[
            const SizedBox(height: AppSpacing.lg),
            InfoBanner(
              text:
                  'Hay $pending ejercicios pendientes. Revisa su estado en el detalle del intento.',
            ),
          ],
          const Divider(),
          const Text(
            'Este resultado es orientativo y no constituye un diagnóstico clínico.',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }
}
