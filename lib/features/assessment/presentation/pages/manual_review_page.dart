import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/assessment_labels.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/app_states.dart';
import '../../../../core/widgets/assessment_result_summary.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../domain/models/manual_review.dart';
import '../../domain/repositories/assessment_repository.dart';
import '../viewmodels/manual_review_viewmodel.dart';
import '../widgets/manual_review_status_badge.dart';
import '../widgets/review_evidence_media.dart';

class ManualReviewPage extends StatefulWidget {
  const ManualReviewPage({
    required this.assessmentRepository,
    required this.args,
    super.key,
  });
  final AssessmentRepository assessmentRepository;
  final ManualReviewArgs args;

  @override
  State<ManualReviewPage> createState() => _ManualReviewPageState();
}

class _ManualReviewPageState extends State<ManualReviewPage> {
  late final ManualReviewViewModel _model;
  final _text = TextEditingController();
  final _observation = TextEditingController();
  final _metricControllers = <String, TextEditingController>{};
  int _generation = -1;
  bool _allowPop = false;
  bool _exitDialogOpen = false;
  String? _lastFeedback;

  @override
  void initState() {
    super.initState();
    _model = ManualReviewViewModel(
      assessmentRepository: widget.assessmentRepository,
      attemptId: widget.args.attemptId,
      exerciseAttemptId: widget.args.exerciseAttemptId,
    )..addListener(_syncDraft);
    _model.load();
  }

  void _syncDraft() {
    if (!_allowPop &&
        !_model.isSaving &&
        !_model.isLoading &&
        _model.hasMutated &&
        !_model.isDirty &&
        !_model.requiresReload &&
        _model.errorMessage == null &&
        _model.notice != null) {
      final message = _model.notice!;
      setState(() => _allowPop = true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final messenger = ScaffoldMessenger.of(context);
        Navigator.pop(context, true);
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
      });
      return;
    }
    final feedback = _model.errorMessage ?? _model.notice;
    if (!_model.isSaving &&
        !_model.isLoading &&
        _model.exercise != null &&
        feedback != null &&
        feedback != _lastFeedback) {
      _lastFeedback = feedback;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(feedback)));
      });
    } else if (feedback == null) {
      _lastFeedback = null;
    }
    if (_generation == _model.draftGeneration) return;
    _generation = _model.draftGeneration;
    _text.text = _model.editedText;
    _observation.text = _model.observation;
    for (final entry in _model.metricDrafts.entries) {
      (_metricControllers[entry.key] ??= TextEditingController()).text =
          entry.value;
    }
  }

  Future<bool> _discardChanges() async {
    if (!_model.isDirty) return true;
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Cambios sin guardar'),
            content: const Text(
              'Los cambios pendientes se descartarán. Las revisiones ya guardadas se conservan.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Seguir editando'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Descartar cambios'),
              ),
            ],
          ),
        ) ==
        true;
  }

  Future<void> _leave() async {
    if (_model.isSaving || _exitDialogOpen) return;
    _exitDialogOpen = true;
    final leave = await _discardChanges();
    _exitDialogOpen = false;
    if (!mounted || !leave) return;
    setState(() => _allowPop = true);
    // Let PopScope adopt the new canPop value before popping.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.pop(context, _model.hasMutated);
    });
  }

  Future<void> _reload() async {
    if (_model.isLoading || _model.isSaving) return;
    if (!await _discardChanges() || !mounted) return;
    await _model.load();
  }

  Future<void> _revert() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Revertir al resultado automático'),
        content: const Text(
          'Se restaurarán el texto y las métricas automáticas originales. Se descartarán los cambios sin guardar y el historial permanecerá disponible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Revertir'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) await _model.revert();
  }

  @override
  void dispose() {
    _model.removeListener(_syncDraft);
    _model.dispose();
    _text.dispose();
    _observation.dispose();
    for (final controller in _metricControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _model,
    builder: (context, _) => PopScope<bool>(
      canPop: _allowPop || (!_model.isDirty && !_model.isSaving),
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _leave();
      },
      child: Scaffold(
        backgroundColor: AppColors.teacherBackground,
        body: Column(
          children: [
            AppHeader(
              title: 'Revisión manual',
              showBack: true,
              onBack: _leave,
              trailing: IconButton(
                tooltip: 'Recargar revisión y evidencia',
                onPressed: _model.isLoading || _model.isSaving ? null : _reload,
                icon: const Icon(Icons.refresh),
              ),
            ),
            Expanded(child: _body()),
          ],
        ),
      ),
    ),
  );

  Widget _body() {
    if (_model.isLoading) {
      return const AppLoadingState(message: 'Cargando revisión…');
    }
    final exercise = _model.exercise;
    if (exercise == null) {
      return AppEmptyState(
        title: 'No se pudo abrir la revisión',
        message: _model.errorMessage ?? 'El ejercicio no está disponible.',
        icon: Icons.error_outline,
        actionLabel: 'Reintentar',
        onAction: _model.load,
      );
    }
    final details = exercise.manualReview;
    final evidence = details.evidence;
    final metrics = _model.isWriting
        ? const ['char_accuracy', 'word_accuracy', 'similarity_score']
        : const [
            'accuracy_score',
            'fluency_score',
            'pronunciation_score',
            'completeness_score',
            'lexical_match',
          ];
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(exercise.title, style: AppTextStyles.headingSmall),
              if (exercise.instructions?.isNotEmpty == true) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(exercise.instructions!, style: AppTextStyles.bodyMedium),
              ],
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ManualReviewStatusBadge(
                    status: details.status,
                    requiredReview: exercise.reviewRequired,
                  ),
                  AppStatusBadge(
                    label:
                        'Evidencia: ${translateTechnicalStatus(exercise.technicalStatus.apiValue)}',
                    icon: Icons.fact_check_outlined,
                    color: AppColors.mutedText,
                  ),
                ],
              ),
              if (_model.readOnlyReason != null)
                _notice(_model.readOnlyReason!, warning: true),
              if (_model.errorMessage != null)
                _notice(_model.errorMessage!, warning: true),
              if (_model.notice != null) _notice(_model.notice!),
              if (_model.requiresReload)
                PrimaryButton(
                  text: 'Recargar datos',
                  icon: Icons.refresh,
                  onPressed: _reload,
                ),
              const SizedBox(height: AppSpacing.xl),
              _section('Evidencia del estudiante', [
                if (_model.isWriting)
                  if (_isRemoteUrl(evidence.imageUrl))
                    ReviewImagePreview(url: evidence.imageUrl!)
                  else
                    const Text(
                      'La imagen no está disponible. Intenta renovar la evidencia.',
                    )
                else if (_isRemoteUrl(evidence.audioUrl))
                  ReviewAudioPlayer(url: evidence.audioUrl!)
                else
                  const Text(
                    'El audio no está disponible. Intenta renovar la evidencia.',
                  ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Renovar imagen o audio'),
                    onPressed: _model.isSaving ? null : _reload,
                  ),
                ),
                _textBlock('Texto esperado', exercise.referenceText),
                if (_model.isWriting)
                  _textBlock('Texto OCR automático', evidence.recognizedText)
                else ...[
                  _textBlock(
                    'Transcripción automática (Whisper)',
                    evidence.freeTranscriptionText ?? evidence.recognizedText,
                  ),
                  if (evidence.assessmentRecognizedText != null)
                    _textBlock(
                      'Texto reconocido por Azure',
                      evidence.assessmentRecognizedText,
                    ),
                ],
                if ((_model.isWriting
                        ? evidence.reviewedRecognizedText
                        : evidence.reviewedFreeTranscriptionText) !=
                    null)
                  _textBlock(
                    'Texto revisado guardado',
                    _model.isWriting
                        ? evidence.reviewedRecognizedText
                        : evidence.reviewedFreeTranscriptionText,
                  ),
                TextFormField(
                  key: const Key('reviewed-text'),
                  controller: _text,
                  enabled: _model.canEdit,
                  minLines: 3,
                  maxLines: 8,
                  decoration: InputDecoration(
                    labelText: _model.isWriting
                        ? 'Texto revisado de la escritura'
                        : 'Transcripción revisada',
                    alignLabelWithHint: true,
                    helperText: _model.isWriting
                        ? 'Escribe exactamente lo que se ve en la imagen.'
                        : 'Escribe exactamente lo que se escucha en el audio.',
                    helperMaxLines: 3,
                    errorText:
                        _model.hasTextCorrection && _text.text.trim().isEmpty
                        ? 'El texto revisado no puede quedar vacío.'
                        : null,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: _model.setText,
                ),
                const SizedBox(height: AppSpacing.md),
                const Text(
                  'Los indicadores y puntajes se actualizarán al guardar.',
                  style: AppTextStyles.bodySmall,
                ),
                if (details.automaticAnalysis?.alignment.isNotEmpty == true)
                  _alignment(
                    'Comparación automática por palabras',
                    details.automaticAnalysis!,
                  ),
                if (details.reviewedAnalysis?.alignment.isNotEmpty == true)
                  _alignment(
                    'Comparación revisada por palabras',
                    details.reviewedAnalysis!,
                  ),
              ]),
              _section('Resultado automático y vigente', [
                _comparison(
                  'Puntaje del ejercicio',
                  details.originalScore,
                  details.currentScore,
                ),
                const Divider(),
                for (final key in metrics) ...[
                  _comparison(
                    reviewMetricLabel(key),
                    details.originalMetrics[key],
                    details.currentMetrics[key],
                  ),
                  Text(
                    reviewSourceLabel(
                      details.metricSources[key] ??
                          (details.reviewVersion == 0
                              ? MetricSource.automatic
                              : null),
                    ),
                    style: AppTextStyles.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
                if (details.automaticAnalysis != null ||
                    details.reviewedAnalysis != null)
                  ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    title: const Text('Detalle del análisis de texto'),
                    children: [
                      if (details.automaticAnalysis != null)
                        _analysisRates(
                          'Automático',
                          details.automaticAnalysis!,
                        ),
                      if (details.reviewedAnalysis != null)
                        _analysisRates('Revisado', details.reviewedAnalysis!),
                    ],
                  ),
              ]),
              if (!_model.isWriting && exercise.supportsManualReview)
                _section('Ajuste docente de métricas', [
                  const Text(
                    'Ajusta sólo los valores que has contrastado con el audio. La coincidencia léxica se actualiza corrigiendo la transcripción.',
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  for (final key
                      in ManualReviewViewModel.editableSpeakingMetrics)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                      child: TextFormField(
                        key: Key('override-$key'),
                        controller: _metricControllers[key],
                        enabled: _model.canEdit,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: reviewMetricLabel(key),
                          suffixText: '/ 100',
                          hintText: 'No disponible',
                          errorText: _model.metricError(key),
                          border: const OutlineInputBorder(),
                        ),
                        onChanged: (value) => _model.setMetric(key, value),
                      ),
                    ),
                ]),
              _section('Guardar revisión', [
                if (details.observation != null)
                  _textBlock(
                    'Motivo de la última revisión',
                    details.observation,
                  ),
                TextFormField(
                  key: const Key('review-observation'),
                  controller: _observation,
                  enabled: _model.canEdit,
                  minLines: 3,
                  maxLines: 6,
                  autovalidateMode: _model.isDirty
                      ? AutovalidateMode.onUserInteraction
                      : AutovalidateMode.disabled,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Escribe el motivo de la revisión.'
                      : null,
                  decoration: const InputDecoration(
                    labelText: 'Motivo de la revisión (obligatorio)',
                    alignLabelWithHint: true,
                    helperText:
                        'Justifica la confirmación, corrección o reversión.',
                    helperMaxLines: 2,
                    border: OutlineInputBorder(),
                  ),
                  onChanged: _model.setObservation,
                ),
                const SizedBox(height: AppSpacing.lg),
                if (_model.hasTextCorrection && _model.hasMetricOverrides)
                  _notice(
                    'Se guardará primero el texto y después el ajuste de métricas. Ambas revisiones quedarán en el historial.',
                  ),
                PrimaryButton(
                  key: const Key('save-review'),
                  text: details.hasReview
                      ? 'Guardar nueva revisión'
                      : 'Guardar corrección',
                  icon: Icons.save_outlined,
                  isLoading: _model.isSaving,
                  onPressed: _model.canSave ? _model.saveEdits : null,
                ),
                if (!details.hasReview) ...[
                  const SizedBox(height: AppSpacing.md),
                  PrimaryButton(
                    key: const Key('confirm-review'),
                    text: 'Confirmar resultado automático',
                    icon: Icons.verified_outlined,
                    variant: AppButtonVariant.secondary,
                    onPressed: _model.canConfirm ? _model.confirm : null,
                  ),
                ],
                if (details.hasReview) ...[
                  const SizedBox(height: AppSpacing.md),
                  PrimaryButton(
                    key: const Key('revert-review'),
                    text: 'Revertir al resultado automático',
                    icon: Icons.restore,
                    variant: AppButtonVariant.secondary,
                    onPressed: _model.canRevert ? _revert : null,
                  ),
                ],
                if (!_model.hasObservation && _model.canEdit) ...[
                  const SizedBox(height: AppSpacing.sm),
                  const Text(
                    'Completa el motivo para habilitar las acciones.',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ]),
              if (_model.review?.result case final result?) ...[
                const AppSectionHeader(
                  title: 'Resultado vigente de la evaluación',
                ),
                const SizedBox(height: AppSpacing.md),
                AssessmentResultSummary(
                  score: result.finalScore,
                  level: result.interventionLevel,
                  pending: result.pendingExercises,
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
              _history(details),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(String title, List<Widget> children) => Container(
    margin: const EdgeInsets.only(bottom: AppSpacing.xl),
    padding: const EdgeInsets.all(AppSpacing.lg),
    decoration: AppSurfaces.card,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSectionHeader(title: title),
        const SizedBox(height: AppSpacing.lg),
        ...children,
      ],
    ),
  );

  Widget _notice(String message, {bool warning = false}) => Semantics(
    liveRegion: true,
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: warning ? AppColors.warningContainer : AppColors.infoBlueLight,
        borderRadius: BorderRadius.circular(AppRadius.control),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            warning ? Icons.info_outline : Icons.check_circle_outline,
            size: 22,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(message)),
        ],
      ),
    ),
  );

  Widget _textBlock(String label, String? text) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.lg),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: AppTextStyles.labelLarge),
        const SizedBox(height: AppSpacing.sm),
        SelectableText(
          text == null
              ? 'No disponible'
              : text.isEmpty
              ? 'Sin texto reconocido'
              : text,
        ),
      ],
    ),
  );

  Widget _comparison(String label, double? original, double? current) =>
      Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(label, style: AppTextStyles.labelLarge),
            const SizedBox(height: AppSpacing.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text('Automático original\n${reviewScore(original)}'),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'Vigente\n${reviewScore(current)}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ],
        ),
      );

  Widget _analysisRates(String label, ReviewAnalysis analysis) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.md),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: AppTextStyles.labelLarge),
        if (analysis.cer != null)
          Text('Tasa de error de caracteres: ${analysis.cer}'),
        if (analysis.wer != null)
          Text('Tasa de error de palabras: ${analysis.wer}'),
        if (analysis.werPercentage != null)
          Text('Error de palabras: ${analysis.werPercentage}%'),
      ],
    ),
  );

  Widget _alignment(String title, ReviewAnalysis analysis) => ExpansionTile(
    tilePadding: EdgeInsets.zero,
    title: Text(title),
    children: [
      for (final item in analysis.alignment)
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(
            item.operation == 'match' ? Icons.check : Icons.compare_arrows,
            color: item.operation == 'match'
                ? AppColors.mutedText
                : AppColors.warning,
          ),
          title: Text(switch (item.operation) {
            'match' => 'Coincide',
            'substitution' => 'Sustitución',
            'omission' => 'Omisión',
            'insertion' => 'Inserción',
            _ => 'Detalle de palabra',
          }),
          subtitle: Text(
            'Esperado: ${item.expected ?? '—'} · Reconocido: ${item.recognized ?? '—'}',
          ),
        ),
    ],
  );

  Widget _history(ManualReviewDetails details) => Container(
    decoration: AppSurfaces.card,
    child: ExpansionTile(
      title: const Text('Historial de revisiones'),
      subtitle: Text('${details.history.length} revisiones registradas'),
      childrenPadding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        if (details.history.isEmpty)
          const Text('Aún no hay revisiones registradas.'),
        for (final event in details.history.reversed)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  reviewActionLabel(event.action),
                  style: AppTextStyles.labelLarge,
                ),
                if (event.createdAt != null) Text(_dateLabel(event.createdAt!)),
                if (event.teacherId != null)
                  SelectableText(
                    'Identificador del revisor: ${event.teacherId}',
                    style: AppTextStyles.bodySmall,
                  ),
                const SizedBox(height: AppSpacing.sm),
                Text(event.observation ?? 'Sin observación disponible'),
                if (event.correctedText != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text('Texto corregido: ${event.correctedText}'),
                ],
                for (final metric in event.manualMetrics.entries)
                  Text(
                    '${reviewMetricLabel(metric.key)}: ${reviewScore(metric.value)}',
                  ),
                const Divider(),
              ],
            ),
          ),
      ],
    ),
  );

  bool _isRemoteUrl(String? url) {
    final uri = Uri.tryParse(url ?? '');
    return uri != null &&
        uri.host.isNotEmpty &&
        (uri.scheme == 'http' || uri.scheme == 'https');
  }

  String _dateLabel(DateTime value) {
    final date = value.toLocal();
    return '${date.day}/${date.month}/${date.year} · ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
