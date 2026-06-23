import 'package:flutter/material.dart';

import '../../../exercises/data/services/exercise_service.dart';
import '../../../exercises/domain/models/exercise.dart';
import '../../data/services/assessment_service.dart';
import '../../domain/models/assessment_session.dart';
import '../../domain/models/writing_stroke.dart';

class WritingAssessmentViewModel extends ChangeNotifier {
  WritingAssessmentViewModel({
    required ExerciseService exerciseService,
    required AssessmentService assessmentService,
  }) : _exerciseService = exerciseService,
       _assessmentService = assessmentService;

  final ExerciseService _exerciseService;
  final AssessmentService _assessmentService;

  Exercise? exercise;
  AssessmentSession? session;
  List<WritingStroke> _strokes = const [];
  bool isPaused = false;

  List<WritingStroke> get strokes => List<WritingStroke>.unmodifiable(_strokes);

  bool get hasStrokes => _strokes.any((stroke) => stroke.points.isNotEmpty);

  Future<void> load(AssessmentSession assessmentSession) async {
    session = assessmentSession;
    exercise = await _exerciseService.getExerciseById(
      assessmentSession.exerciseId,
    );
    notifyListeners();
  }

  void clear() {
    clearStrokes();
  }

  void clearStrokes() {
    _strokes = const [];
    notifyListeners();
    // TODO: clear persisted digital strokes when canvas persistence exists.
  }

  void startStroke(Offset point) {
    if (isPaused) return;
    _strokes = [
      ..._strokes,
      WritingStroke(
        points: [StrokePoint(offset: point, timestamp: DateTime.now())],
      ),
    ];
    notifyListeners();
  }

  void appendStroke(Offset point) {
    addPointToCurrentStroke(point);
  }

  void addPointToCurrentStroke(Offset point) {
    if (isPaused || _strokes.isEmpty) return;
    final currentStroke = _strokes.last;
    final updatedStroke = WritingStroke(
      points: [
        ...currentStroke.points,
        StrokePoint(offset: point, timestamp: DateTime.now()),
      ],
    );
    _strokes = [..._strokes.take(_strokes.length - 1), updatedStroke];
    notifyListeners();
    // TODO: capture pressure when supported, export canvas as image,
    // and send writing evidence to backend/Azure OCR later.
  }

  void endStroke() {
    if (isPaused) return;
    notifyListeners();
  }

  Future<void> togglePause() async {
    final currentSession = session;
    if (currentSession == null) return;
    isPaused = !isPaused;
    if (isPaused) {
      await _assessmentService.pauseSession(currentSession.id);
    } else {
      await _assessmentService.resumeSession(currentSession.id);
    }
    notifyListeners();
  }

  Future<void> finish() async {
    final currentSession = session;
    if (currentSession == null) return;
    await _assessmentService.saveWritingEvidence(currentSession.id);
    await _assessmentService.finishSession(currentSession.id);
  }

  Future<void> cancel() async {
    final currentSession = session;
    if (currentSession != null) {
      await _assessmentService.cancelSession(currentSession.id);
    }
  }
}
