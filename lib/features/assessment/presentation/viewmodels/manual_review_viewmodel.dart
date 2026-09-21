import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../domain/models/attempt_review.dart';
import '../../domain/models/exercise_integrity.dart';
import '../../domain/models/manual_review.dart';
import '../../domain/repositories/assessment_repository.dart';

class ManualReviewViewModel extends ChangeNotifier {
  ManualReviewViewModel({
    required AssessmentRepository assessmentRepository,
    required this.attemptId,
    required this.exerciseAttemptId,
  }) : _repository = assessmentRepository;

  static const editableSpeakingMetrics = [
    'accuracy_score',
    'fluency_score',
    'pronunciation_score',
    'completeness_score',
  ];

  final AssessmentRepository _repository;
  final String attemptId;
  final String exerciseAttemptId;
  AttemptReview? review;
  ExerciseReview? exercise;
  bool isLoading = false;
  bool isSaving = false;
  bool requiresReload = false;
  bool hasMutated = false;
  bool _disposed = false;
  String? errorMessage;
  String? notice;
  String editedText = '';
  String observation = '';
  String _initialText = '';
  final Map<String, String> _metricDrafts = {};
  final Map<String, String> _initialMetrics = {};
  int draftGeneration = 0;

  Map<String, String> get metricDrafts => Map.unmodifiable(_metricDrafts);
  bool get isWriting => exercise?.type == 'READING_WRITING';
  bool get hasTextCorrection => editedText.trim() != _initialText.trim();
  bool get hasMetricOverrides =>
      _metricDrafts.entries.any((entry) => _metricChanged(entry.key));
  bool _metricChanged(String key) {
    final draft = _metricDrafts[key]?.trim() ?? '';
    final initial = _initialMetrics[key] ?? '';
    if (draft == initial) return false;
    final value = double.tryParse(draft.replaceAll(',', '.'));
    return value == null || value != double.tryParse(initial);
  }

  bool get hasChanges => hasTextCorrection || hasMetricOverrides;
  bool get isDirty => hasChanges || observation.trim().isNotEmpty;
  bool get hasObservation => observation.trim().isNotEmpty;
  bool get canEdit =>
      !isLoading &&
      !isSaving &&
      !requiresReload &&
      exercise?.supportsManualReview == true &&
      review?.status == 'COMPLETED' &&
      exercise?.technicalStatus != TechnicalStatus.invalid &&
      exercise?.manualReview.reviewVersion != null;
  bool get canSave =>
      canEdit &&
      hasChanges &&
      hasObservation &&
      (!hasTextCorrection || editedText.trim().isNotEmpty) &&
      _metricDrafts.keys.every((key) => metricError(key) == null);
  bool get canConfirm =>
      canEdit &&
      !hasChanges &&
      hasObservation &&
      exercise?.manualReview.manualAdjustmentApplied == false;
  bool get canRevert =>
      canEdit && hasObservation && exercise?.manualReview.hasReview == true;

  String? get readOnlyReason {
    if (review?.status != 'COMPLETED') {
      return 'La revisión manual está disponible al terminar la evaluación.';
    }
    if (exercise?.supportsManualReview != true) {
      return 'Este tipo de ejercicio no admite revisión manual.';
    }
    if (exercise?.technicalStatus == TechnicalStatus.invalid) {
      return 'La evidencia no permite una revisión manual. Se necesita un nuevo intento con evidencia válida.';
    }
    if (exercise?.manualReview.reviewVersion == null) {
      return 'No se recibió la versión de la revisión. Recarga antes de guardar.';
    }
    return null;
  }

  void setText(String value) {
    editedText = value;
    _notify();
  }

  void setObservation(String value) {
    observation = value;
    _notify();
  }

  void setMetric(String key, String value) {
    if (!_metricDrafts.containsKey(key)) return;
    _metricDrafts[key] = value;
    _notify();
  }

  String? metricError(String key) {
    final draft = _metricDrafts[key]?.trim();
    if (draft == null || !_metricChanged(key)) return null;
    final value = double.tryParse(draft.replaceAll(',', '.'));
    if (value == null || !value.isFinite || value < 0 || value > 100) {
      return 'Ingresa un número de 0 a 100.';
    }
    return null;
  }

  Map<String, double> _changedMetrics() => {
    for (final entry in _metricDrafts.entries)
      if (_metricChanged(entry.key))
        entry.key: double.parse(entry.value.trim().replaceAll(',', '.')),
  };

  Future<void> load() async {
    if (isLoading || isSaving) return;
    isLoading = true;
    errorMessage = null;
    _notify();
    try {
      await _fetchReview();
      requiresReload = false;
    } catch (error) {
      errorMessage = _message(error);
      requiresReload = true;
    } finally {
      isLoading = false;
      _notify();
    }
  }

  Future<void> _fetchReview() async {
    final latest = await _repository.getAttemptReview(attemptId);
    final matches = latest.exerciseReviews.where(
      (item) => item.exerciseAttemptId == exerciseAttemptId,
    );
    if (matches.isEmpty) {
      throw const NotFoundException(
        'El ejercicio no está disponible en esta evaluación.',
      );
    }
    review = latest;
    exercise = matches.first;
    final evidence = exercise!.manualReview.evidence;
    _initialText = isWriting
        ? evidence.reviewedRecognizedText ?? evidence.recognizedText ?? ''
        : evidence.reviewedFreeTranscriptionText ??
              evidence.freeTranscriptionText ??
              evidence.recognizedText ??
              '';
    editedText = _initialText;
    observation = '';
    _initialMetrics.clear();
    _metricDrafts.clear();
    if (!isWriting && exercise!.supportsManualReview) {
      for (final key in editableSpeakingMetrics) {
        final value = exercise!.manualReview.currentMetrics[key];
        final text = value == null ? '' : value.toString();
        _initialMetrics[key] = text;
        _metricDrafts[key] = text;
      }
    }
    draftGeneration++;
  }

  Future<ManualReviewResponse> _patch(ManualReviewRequest request) async {
    final response = await _repository.manualReviewExercise(
      exerciseAttemptId,
      request,
    );
    if (response.exerciseAttemptId != exerciseAttemptId ||
        response.reviewVersion <= request.baseReviewVersion) {
      throw const UnknownApiException(
        'No se pudo verificar la revisión guardada. Recarga los datos.',
      );
    }
    hasMutated = true;
    return response;
  }

  Future<void> saveEdits() async {
    if (!canSave) return;
    final metrics = _changedMetrics();
    final textChanged = hasTextCorrection;
    final text = editedText.trim();
    final reason = observation.trim();
    var version = exercise!.manualReview.reviewVersion!;
    var textSaved = false;
    isSaving = true;
    errorMessage = null;
    notice = null;
    _notify();
    try {
      if (textChanged) {
        final response = await _patch(
          ManualReviewRequest(
            action: ManualReviewAction.correctEvidence,
            observation: reason,
            baseReviewVersion: version,
            recognizedText: isWriting ? text : null,
            freeTranscriptionText: isWriting ? null : text,
          ),
        );
        textSaved = true;
        // Use the server version, including when it skips a local number.
        version = response.reviewVersion;
      }
      if (metrics.isNotEmpty) {
        await _patch(
          ManualReviewRequest(
            action: ManualReviewAction.overrideMetrics,
            observation: reason,
            baseReviewVersion: version,
            metrics: metrics,
          ),
        );
      }
      await _refreshAfterSuccess(
        'Revisión guardada. Los resultados están actualizados.',
      );
    } catch (error) {
      await _recover(
        error,
        textSaved: textSaved,
        pendingMetrics: metrics,
        reason: reason,
        lastKnownVersion: version,
      );
    } finally {
      isSaving = false;
      _notify();
    }
  }

  Future<void> confirm() async {
    if (!canConfirm) return;
    await _singleAction(ManualReviewAction.confirm);
  }

  Future<void> revert() async {
    if (!canRevert) return;
    await _singleAction(ManualReviewAction.revert);
  }

  Future<void> _singleAction(ManualReviewAction action) async {
    isSaving = true;
    errorMessage = null;
    notice = null;
    _notify();
    try {
      await _patch(
        ManualReviewRequest(
          action: action,
          observation: observation.trim(),
          baseReviewVersion: exercise!.manualReview.reviewVersion!,
        ),
      );
      await _refreshAfterSuccess(
        action == ManualReviewAction.revert
            ? 'Se restauró el resultado automático. El historial se conserva.'
            : 'Resultado confirmado. Los resultados están actualizados.',
      );
    } catch (error) {
      await _recover(error);
    } finally {
      isSaving = false;
      _notify();
    }
  }

  Future<void> _refreshAfterSuccess(String message) async {
    // A successful PATCH must not be submitted again if the subsequent GET fails.
    observation = '';
    editedText = _initialText;
    _metricDrafts
      ..clear()
      ..addAll(_initialMetrics);
    draftGeneration++;
    try {
      await _fetchReview();
      requiresReload = false;
      notice = message;
    } catch (_) {
      requiresReload = true;
      errorMessage =
          'La revisión se guardó, pero no pudimos actualizar los resultados. Recarga los datos; no vuelvas a enviarla.';
    }
  }

  Future<void> _recover(
    Object error, {
    bool textSaved = false,
    Map<String, double> pendingMetrics = const {},
    String? reason,
    int? lastKnownVersion,
  }) async {
    final conflict = error is ConflictException;
    final uncertain =
        error is NetworkException ||
        error is ApiTimeoutException ||
        error is ServerException ||
        error is UnknownApiException;
    errorMessage = _message(error);
    if (textSaved) {
      errorMessage =
          'La corrección del texto ya se guardó. No se confirmó el guardado de las métricas. ${_message(error)}';
    }
    if (conflict || uncertain || textSaved) {
      requiresReload = true;
      try {
        await _fetchReview();
        requiresReload = false;
        if (textSaved &&
            !conflict &&
            exercise!.manualReview.reviewVersion == lastKnownVersion) {
          // Keep only the failed second operation; never resend corrected text.
          for (final entry in pendingMetrics.entries) {
            _metricDrafts[entry.key] = entry.value.toString();
          }
          observation = reason ?? '';
          draftGeneration++;
          notice =
              'El texto está guardado. Revisa y guarda sólo las métricas pendientes.';
        } else if (conflict) {
          notice =
              'Datos recargados. Revisa la versión vigente antes de decidir nuevamente.';
        } else if (uncertain) {
          notice =
              'Consulta los valores y el historial actualizados antes de volver a guardar.';
        }
      } catch (_) {
        errorMessage =
            '${errorMessage!} No se pudo recargar. Recarga antes de continuar.';
      }
    }
  }

  static String _message(Object error) => error is ApiException
      ? error.message
      : 'No se pudo completar la operación. Inténtalo nuevamente.';

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
