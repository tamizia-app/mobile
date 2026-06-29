import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../../../../core/network/api_exception.dart';
import '../../domain/models/assessment_response.dart';
import '../../domain/models/attempt_exercise_args.dart';
import '../../domain/repositories/assessment_repository.dart';

class ReadingAssessmentViewModel extends ChangeNotifier {
  ReadingAssessmentViewModel({
    required AssessmentRepository assessmentRepository,
  }) : _assessmentRepository = assessmentRepository;

  final AssessmentRepository _assessmentRepository;
  final AudioRecorder _recorder = AudioRecorder();

  AttemptExerciseArgs? args;
  SpeakingResponse? response;
  bool isLoading = false;
  bool isRecording = false;
  bool isPaused = false;
  bool isUploading = false;
  int elapsedSeconds = 0;
  String? audioPath;
  String? errorMessage;
  Timer? _timer;

  String get minutes => (elapsedSeconds ~/ 60).toString().padLeft(2, '0');

  String get seconds => (elapsedSeconds % 60).toString().padLeft(2, '0');

  String get prompt =>
      args?.exerciseAttempt.prompt ??
      args?.exerciseAttempt.instructions ??
      'Lee el texto en voz alta';

  String get textToRead =>
      args?.exerciseAttempt.textToShow ??
      args?.exerciseAttempt.expectedText ??
      prompt;

  String get progressText {
    final current = (args?.exerciseIndex ?? 0) + 1;
    final total = args?.totalExercises ?? 0;
    return 'Ejercicio $current de $total';
  }

  Future<void> load(AttemptExerciseArgs value) async {
    args = value;
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      response = await _assessmentRepository.getSpeakingResponse(
        value.exerciseAttempt.id,
      );
    } catch (error) {
      errorMessage = _messageFor(error);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleRecording() async {
    if (isRecording) {
      await stopRecording();
      return;
    }
    await startRecording();
  }

  Future<void> startRecording() async {
    if (isRecording) {
      return;
    }
    errorMessage = null;
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      errorMessage = 'Activa el permiso de microfono para grabar.';
      notifyListeners();
      return;
    }
    final directory = await getTemporaryDirectory();
    final file = File(
      '${directory.path}${Platform.pathSeparator}speaking_${DateTime.now().millisecondsSinceEpoch}.m4a',
    );
    audioPath = file.path;
    elapsedSeconds = 0;
    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        sampleRate: 44100,
        numChannels: 1,
      ),
      path: file.path,
    );
    isRecording = true;
    isPaused = false;
    _startTimer();
    notifyListeners();
  }

  Future<void> stopRecording() async {
    if (!isRecording) {
      return;
    }
    final path = await _recorder.stop();
    audioPath = path ?? audioPath;
    isRecording = false;
    isPaused = false;
    _stopTimer();
    notifyListeners();
  }

  Future<void> togglePause() async {
    if (!isRecording) {
      return;
    }
    if (isPaused) {
      await _recorder.resume();
      isPaused = false;
      _startTimer();
    } else {
      await _recorder.pause();
      isPaused = true;
      _stopTimer();
    }
    notifyListeners();
  }

  Future<bool> upload() async {
    final exerciseAttemptId = args?.exerciseAttempt.id;
    if (exerciseAttemptId == null) {
      return false;
    }
    if (isRecording) {
      await stopRecording();
    }
    final path = audioPath;
    if (path == null || !File(path).existsSync()) {
      errorMessage = 'Graba un audio antes de continuar.';
      notifyListeners();
      return false;
    }
    isUploading = true;
    errorMessage = null;
    notifyListeners();
    try {
      response = await _assessmentRepository.uploadSpeakingResponse(
        exerciseAttemptId: exerciseAttemptId,
        filePath: path,
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

  void _startTimer() {
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

  String _messageFor(Object error) {
    if (error is ApiException) {
      return error.message;
    }
    return 'No se pudo procesar el audio.';
  }

  @override
  void dispose() {
    _stopTimer();
    _recorder.dispose();
    super.dispose();
  }
}
