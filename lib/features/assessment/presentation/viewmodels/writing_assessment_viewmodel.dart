import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../core/network/api_exception.dart';
import '../../domain/models/assessment_response.dart';
import '../../domain/models/attempt_exercise_args.dart';
import '../../domain/models/writing_stroke.dart';
import '../../domain/repositories/assessment_repository.dart';

class WritingAssessmentViewModel extends ChangeNotifier {
  WritingAssessmentViewModel({
    required AssessmentRepository assessmentRepository,
  }) : _assessmentRepository = assessmentRepository;

  final AssessmentRepository _assessmentRepository;

  AttemptExerciseArgs? args;
  WritingResponse? response;
  List<WritingStroke> _strokes = const [];
  bool isLoading = false;
  bool isUploading = false;
  String? errorMessage;
  DateTime? _startedAt;
  DateTime? _endedAt;

  List<WritingStroke> get strokes => List<WritingStroke>.unmodifiable(_strokes);

  bool get hasStrokes => _strokes.any((stroke) => stroke.points.isNotEmpty);

  String get progressText {
    final current = (args?.exerciseIndex ?? 0) + 1;
    final total = args?.totalExercises ?? 0;
    return 'Ejercicio $current de $total';
  }

  String get prompt =>
      args?.exerciseAttempt.prompt ??
      args?.exerciseAttempt.instructions ??
      'Escribe el texto indicado';

  String get textToWrite =>
      args?.exerciseAttempt.textToShow ??
      args?.exerciseAttempt.expectedText ??
      prompt;

  Future<void> load(AttemptExerciseArgs value) async {
    args = value;
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      response = await _assessmentRepository.getWritingResponse(
        value.exerciseAttempt.id,
      );
    } catch (error) {
      errorMessage = _messageFor(error);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _strokes = const [];
    _startedAt = null;
    _endedAt = null;
    notifyListeners();
  }

  void startStroke(Offset point) {
    _startedAt ??= DateTime.now();
    _strokes = [
      ..._strokes,
      WritingStroke(
        points: [StrokePoint(offset: point, timestamp: DateTime.now())],
      ),
    ];
    notifyListeners();
  }

  void appendStroke(Offset point) {
    if (_strokes.isEmpty) {
      return;
    }
    final currentStroke = _strokes.last;
    final updatedStroke = WritingStroke(
      points: [
        ...currentStroke.points,
        StrokePoint(offset: point, timestamp: DateTime.now()),
      ],
    );
    _strokes = [..._strokes.take(_strokes.length - 1), updatedStroke];
    notifyListeners();
  }

  void endStroke() {
    _endedAt = DateTime.now();
    notifyListeners();
  }

  Future<bool> upload({
    required String imagePath,
    required Size canvasSize,
  }) async {
    final exerciseAttemptId = args?.exerciseAttempt.id;
    if (exerciseAttemptId == null) {
      return false;
    }
    if (!hasStrokes) {
      errorMessage = 'Escribe antes de continuar.';
      notifyListeners();
      return false;
    }
    isUploading = true;
    errorMessage = null;
    notifyListeners();
    try {
      response = await _assessmentRepository.uploadWritingResponse(
        exerciseAttemptId: exerciseAttemptId,
        filePath: imagePath,
        payloadJson: buildPayloadJson(canvasSize),
      );
      return true;
    } catch (error) {
      errorMessage = _messageFor(error);
      return false;
    } finally {
      isUploading = false;
      notifyListeners();
    }
  }

  String buildPayloadJson(Size canvasSize) {
    final metrics = _metrics(canvasSize);
    final payload = {
      'strokes': _strokes
          .map(
            (stroke) => {
              'points': stroke.points
                  .map(
                    (point) => {
                      'x': point.offset.dx,
                      'y': point.offset.dy,
                      't': point.timestamp.toIso8601String(),
                    },
                  )
                  .toList(growable: false),
            },
          )
          .toList(growable: false),
      'canvas': {
        'width': canvasSize.width,
        'height': canvasSize.height,
        'device_pixel_ratio': WidgetsBinding
            .instance
            .platformDispatcher
            .views
            .first
            .devicePixelRatio,
      },
      'input': {
        'expected_text': args?.exerciseAttempt.expectedText,
        'text_to_show': args?.exerciseAttempt.textToShow,
        'prompt': args?.exerciseAttempt.prompt,
        'language_code': args?.exerciseAttempt.languageCode,
      },
      'metrics': metrics,
    };
    return jsonEncode(payload);
  }

  Map<String, dynamic> _metrics(Size canvasSize) {
    final points = _strokes.expand((stroke) => stroke.points).toList();
    final startedAt =
        _startedAt ?? (points.isEmpty ? null : points.first.timestamp);
    final endedAt = _endedAt ?? (points.isEmpty ? null : points.last.timestamp);
    final durationMs = startedAt == null || endedAt == null
        ? null
        : endedAt.difference(startedAt).inMilliseconds;
    final bounds = _bounds(points);
    final areaUsage =
        bounds == null || canvasSize.width == 0 || canvasSize.height == 0
        ? null
        : ((bounds.width * bounds.height) /
                  (canvasSize.width * canvasSize.height))
              .clamp(0, 1);
    return {
      'duration_ms': durationMs,
      'stroke_count': _strokes.length,
      'point_count': points.length,
      'bounding_box': bounds == null
          ? null
          : {
              'left': bounds.left,
              'top': bounds.top,
              'right': bounds.right,
              'bottom': bounds.bottom,
              'width': bounds.width,
              'height': bounds.height,
            },
      'writing_area_usage': areaUsage,
    };
  }

  Rect? _bounds(List<StrokePoint> points) {
    if (points.isEmpty) {
      return null;
    }
    var left = points.first.offset.dx;
    var top = points.first.offset.dy;
    var right = points.first.offset.dx;
    var bottom = points.first.offset.dy;
    for (final point in points) {
      left = min(left, point.offset.dx);
      top = min(top, point.offset.dy);
      right = max(right, point.offset.dx);
      bottom = max(bottom, point.offset.dy);
    }
    return Rect.fromLTRB(left, top, right, bottom);
  }

  String _messageFor(Object error) {
    if (error is ApiException) {
      return error.message;
    }
    return 'No se pudo subir la escritura.';
  }
}
