import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../exercises/data/services/exercise_service.dart';
import '../../../exercises/domain/models/exercise.dart';
import '../../data/services/assessment_service.dart';
import '../../domain/models/assessment_session.dart';

class ReadingAssessmentViewModel extends ChangeNotifier {
  ReadingAssessmentViewModel({
    required ExerciseService exerciseService,
    required AssessmentService assessmentService,
  }) : _exerciseService = exerciseService,
       _assessmentService = assessmentService;

  final ExerciseService _exerciseService;
  final AssessmentService _assessmentService;

  Exercise? exercise;
  AssessmentSession? session;
  bool isRecording = false;
  bool isPaused = false;
  int elapsedSeconds = 0;
  Timer? _timer;

  String get minutes => (elapsedSeconds ~/ 60).toString().padLeft(2, '0');

  String get seconds => (elapsedSeconds % 60).toString().padLeft(2, '0');

  Future<void> load(AssessmentSession assessmentSession) async {
    session = assessmentSession;
    exercise = await _exerciseService.getExerciseById(
      assessmentSession.exerciseId,
    );
    notifyListeners();
  }

  void toggleRecording() {
    if (isPaused) return;
    isRecording = !isRecording;
    if (isRecording) {
      _startTimer(reset: elapsedSeconds == 0);
    } else {
      _stopTimer();
    }
    notifyListeners();

    /// TODO: reemplazar grabación simulada por captura real de audio.
    /// Flujo futuro: request microphone permission -> start recorder -> save audio file -> upload to backend -> process with Azure Speech Pronunciation Assessment.
  }

  Future<void> togglePause() async {
    final currentSession = session;
    if (currentSession == null) return;
    if (isPaused) {
      isPaused = false;
      isRecording = true;
      await _assessmentService.resumeSession(currentSession.id);
      _startTimer(reset: false);
    } else {
      isPaused = true;
      isRecording = false;
      _stopTimer();
      await _assessmentService.pauseSession(currentSession.id);
    }
    notifyListeners();
  }

  Future<void> finish() async {
    final currentSession = session;
    if (currentSession == null) return;
    _stopTimer();
    isRecording = false;
    await _assessmentService.saveReadingEvidence(currentSession.id);
    await _assessmentService.finishSession(currentSession.id);
  }

  Future<void> cancel() async {
    final currentSession = session;
    _stopTimer();
    if (currentSession != null) {
      await _assessmentService.cancelSession(currentSession.id);
    }
  }

  void _startTimer({required bool reset}) {
    if (reset) elapsedSeconds = 0;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      elapsedSeconds++;
      notifyListeners();
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}
