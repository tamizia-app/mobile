import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../domain/models/assessment_attempt.dart';
import '../../domain/models/assessment_response.dart';
import '../../domain/models/attempt_exercise_args.dart';
import '../../domain/repositories/assessment_repository.dart';

class BuildWordViewModel extends ChangeNotifier {
  BuildWordViewModel({required AssessmentRepository assessmentRepository})
    : _assessmentRepository = assessmentRepository;

  final AssessmentRepository _assessmentRepository;

  AttemptExerciseArgs? args;
  ExerciseAttempt? get exerciseAttempt => args?.exerciseAttempt;
  OSResponse? response;
  List<String?> placedSyllables = const [];
  bool isLoading = false;
  bool isSubmitting = false;
  String? errorMessage;
  String? validationMessage;

  String get progressText {
    final current = (args?.exerciseIndex ?? 0) + 1;
    final total = args?.totalExercises ?? 0;
    return 'Ejercicio $current de $total';
  }

  String get prompt =>
      exerciseAttempt?.prompt ??
      exerciseAttempt?.instructions ??
      'Ordena las sílabas';

  List<String> get syllables => exerciseAttempt?.syllables ?? const [];

  List<String> get selectedSyllables =>
      placedSyllables.whereType<String>().toList(growable: false);

  List<String> get availableSyllables => syllables
      .where((syllable) => !placedSyllables.contains(syllable))
      .toList();

  String get formedWord => selectedSyllables.join();

  Future<void> load(AttemptExerciseArgs value) async {
    args = value;
    isLoading = true;
    errorMessage = null;
    placedSyllables = List<String?>.filled(
      value.exerciseAttempt.syllables.length,
      null,
    );
    notifyListeners();
    try {
      response = await _assessmentRepository.getOSResponse(
        value.exerciseAttempt.id,
      );
      if (response != null && response!.selectedSyllables.isNotEmpty) {
        placedSyllables = List<String?>.from(response!.selectedSyllables);
      }
    } catch (error) {
      errorMessage = _messageFor(error);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void selectSyllable(String syllable) {
    final index = placedSyllables.indexWhere((item) => item == null);
    if (index == -1 || placedSyllables.contains(syllable)) {
      return;
    }
    placedSyllables[index] = syllable;
    validationMessage = null;
    notifyListeners();
  }

  void placeSyllableAt(String syllable, int index) {
    if (placedSyllables.contains(syllable) ||
        index < 0 ||
        index >= placedSyllables.length) {
      return;
    }
    placedSyllables[index] = syllable;
    validationMessage = null;
    notifyListeners();
  }

  void removePlacedSyllable(int index) {
    if (index < 0 || index >= placedSyllables.length) {
      return;
    }
    placedSyllables[index] = null;
    validationMessage = null;
    notifyListeners();
  }

  void clear() {
    placedSyllables = List<String?>.filled(syllables.length, null);
    validationMessage = null;
    notifyListeners();
  }

  Future<bool> submit() async {
    final exerciseAttemptId = exerciseAttempt?.id;
    if (exerciseAttemptId == null ||
        selectedSyllables.length != syllables.length) {
      validationMessage = 'Ordena todas las sílabas para continuar.';
      notifyListeners();
      return false;
    }
    isSubmitting = true;
    errorMessage = null;
    notifyListeners();
    try {
      response = await _assessmentRepository.submitOSResponse(
        exerciseAttemptId: exerciseAttemptId,
        selectedSyllables: selectedSyllables,
        formedWord: formedWord,
      );
      return true;
    } catch (error) {
      errorMessage = _messageFor(error);
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  String _messageFor(Object error) {
    if (error is ApiException) {
      return error.message;
    }
    return 'No se pudo guardar la respuesta.';
  }
}
