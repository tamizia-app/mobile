import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/app_states.dart';
import '../../domain/models/exercise_integrity.dart';

/// Displays server metrics without inferring clinical thresholds or a score.
class ExerciseMetricsPanel extends StatelessWidget {
  const ExerciseMetricsPanel({
    required this.metrics,
    required this.writing,
    super.key,
  });
  final ScoringComponents metrics;
  final bool writing;

  @override
  Widget build(BuildContext context) {
    final rows = writing
        ? [
            _Metric(
              'Similitud con el texto',
              metrics.similarityScore,
              'Compara el texto reconocido con el texto de referencia.',
              unit: ' / 100',
            ),
            _Metric(
              'Error por caracteres (CER)',
              metrics.cer,
              'Diferencias de letras y otros caracteres respecto a la referencia.',
              ratio: true,
              lower: true,
            ),
            _Metric(
              'Error por palabras (WER)',
              metrics.wer,
              'Palabras sustituidas, omitidas o añadidas respecto a la referencia.',
              ratio: true,
              lower: true,
            ),
          ]
        : [
            _Metric(
              'Pronunciación',
              metrics.pronunciationScore,
              'Valoración global de la pronunciación realizada por el sistema.',
              unit: ' / 100',
            ),
            _Metric(
              'Precisión',
              metrics.accuracyScore,
              'Qué tan próximos son los sonidos pronunciados a los esperados.',
              unit: ' / 100',
            ),
            _Metric(
              'Fluidez',
              metrics.fluencyScore,
              'Continuidad de la lectura y distribución de las pausas.',
              unit: ' / 100',
            ),
            _Metric(
              'Lectura completa',
              metrics.completenessScore,
              'Cobertura de las palabras del texto de referencia.',
              unit: ' / 100',
            ),
            if (metrics.prosodyScore != null)
              _Metric(
                'Prosodia',
                metrics.prosodyScore,
                'Entonación, ritmo y acentuación de la lectura.',
                unit: ' / 100',
              ),
            _Metric(
              'Coincidencia de palabras',
              metrics.lexicalMatch,
              'Coincidencia del contenido reconocido con el texto esperado.',
            ),
          ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSectionHeader(
          title: writing
              ? 'Indicadores de escritura'
              : 'Indicadores de lectura',
          description:
              'Valores del análisis automático. Contrástalos con la respuesta del estudiante.',
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: AppColors.divider),
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            children: [
              for (var i = 0; i < rows.length; i++) ...[
                if (i > 0) const Divider(height: 1),
                _MetricRow(metric: rows[i]),
              ],
            ],
          ),
        ),
        if (writing) ...[
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'CER y WER: un valor menor indica menos diferencias. Pueden superar el 100 % si hay muchas inserciones.',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          const AppSectionHeader(title: 'Calidad del reconocimiento'),
          _MetricRow(
            metric: _Metric(
              'Confianza del OCR',
              metrics.confidenceAvg,
              'Seguridad del sistema al reconocer la imagen. No mide la habilidad del estudiante.',
              ratio: true,
              technical: true,
            ),
          ),
        ],
        if (metrics.formula != null && metrics.formula!.trim().isNotEmpty)
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: const Text('Cálculo del puntaje'),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: SelectableText(metrics.formula!),
              ),
            ],
          ),
      ],
    );
  }
}

class _Metric {
  const _Metric(
    this.label,
    this.value,
    this.description, {
    this.ratio = false,
    this.lower = false,
    this.technical = false,
    this.unit = '%',
  });
  final String label;
  final double? value;
  final String description;
  final bool ratio;
  final bool lower;
  final bool technical;
  final String unit;
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.metric});
  final _Metric metric;

  @override
  Widget build(BuildContext context) {
    final available = metric.value != null && metric.value!.isFinite;
    final value = available
        ? '${(metric.value! * (metric.ratio ? 100 : 1)).toStringAsFixed(1)}${metric.unit}'
        : 'No disponible';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final label = Text(metric.label, style: AppTextStyles.labelLarge);
              final number = Text(
                value,
                style: AppTextStyles.headingSmall.copyWith(
                  color: available
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
              );
              if (constraints.maxWidth < 280 ||
                  MediaQuery.textScalerOf(context).scale(16) > 22) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    label,
                    const SizedBox(height: AppSpacing.xs),
                    number,
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: label),
                  const SizedBox(width: AppSpacing.lg),
                  number,
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(metric.description, style: AppTextStyles.bodySmall),
          if (available && !metric.technical) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              metric.lower
                  ? 'Menor valor: menos diferencias'
                  : 'Mayor valor: mejor resultado',
              style: AppTextStyles.labelMedium,
            ),
          ],
        ],
      ),
    );
  }
}
