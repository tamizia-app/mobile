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
  static const int _speakingSampleRate = 16000;
  static const int _speakingChannels = 1;
  static const String _speakingExtension = 'wav';
  static const String _speakingContentType = 'audio/wav';

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
      errorMessage = 'Activa el permiso del micrófono para grabar.';
      notifyListeners();
      return;
    }
    final directory = await getTemporaryDirectory();
    final file = File(
      '${directory.path}${Platform.pathSeparator}speaking_${DateTime.now().millisecondsSinceEpoch}.$_speakingExtension',
    );
    audioPath = file.path;
    elapsedSeconds = 0;
    _logRecordingConfig(file.path);
    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.wav,
        sampleRate: _speakingSampleRate,
        numChannels: _speakingChannels,
        androidConfig: AndroidRecordConfig(useLegacy: false),
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
    await _logRecordedFile(audioPath);
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
    if (!await _isWaveFile(path)) {
      errorMessage =
          'El archivo grabado no es un WAV válido. Intenta grabar otra vez.';
      notifyListeners();
      return false;
    }
    isUploading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await _logUploadFile(path);
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

  void _logRecordingConfig(String path) {
    if (!kDebugMode) {
      return;
    }
    debugPrint(
      'Speaking recorder config: path=$path, extension=$_speakingExtension, '
      'encoder=wav, sampleRate=$_speakingSampleRate, channels=$_speakingChannels, '
      'pcm=16-bit, contentType=$_speakingContentType',
    );
  }

  Future<void> _logRecordedFile(String? path) async {
    if (!kDebugMode || path == null) {
      return;
    }
    final file = File(path);
    final exists = file.existsSync();
    final size = exists ? await file.length() : 0;
    final extension = path.contains('.') ? path.split('.').last : '';
    final isWave = exists && await _isWaveFile(path);
    debugPrint(
      'Speaking recorded file: path=$path, extension=$extension, '
      'sizeBytes=$size, isWave=$isWave, sampleRate=$_speakingSampleRate, '
      'channels=$_speakingChannels, contentType=$_speakingContentType',
    );
  }

  Future<void> _logUploadFile(String path) async {
    if (!kDebugMode) {
      return;
    }
    final file = File(path);
    final size = await file.length();
    final extension = path.contains('.') ? path.split('.').last : '';
    debugPrint(
      'Speaking upload file: path=$path, extension=$extension, '
      'sizeBytes=$size, multipartField=file, contentType=$_speakingContentType',
    );
  }

  Future<bool> _isWaveFile(String path) async {
    final file = File(path);
    if (!file.existsSync()) {
      return false;
    }
    final bytes = await file
        .openRead(0, 12)
        .fold<List<int>>(<int>[], (previous, chunk) => previous..addAll(chunk));
    if (bytes.length < 12) {
      return false;
    }
    final riff = String.fromCharCodes(bytes.sublist(0, 4));
    final wave = String.fromCharCodes(bytes.sublist(8, 12));
    return riff == 'RIFF' && wave == 'WAVE';
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
