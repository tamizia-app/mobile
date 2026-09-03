import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../domain/models/assessment_attempt.dart';
import '../../domain/models/assessment_result.dart';
import '../../domain/repositories/assessment_repository.dart';

class AttemptSessionViewModel extends ChangeNotifier {
  AttemptSessionViewModel({required AssessmentRepository assessmentRepository})
    : _assessmentRepository = assessmentRepository;

  final AssessmentRepository _assessmentRepository;

  AssessmentAttempt? attempt;
  AssessmentResult? result;
  int currentIndex = 0;
  bool isLoading = false;
  bool isFinishing = false;
  String? errorMessage;

  List<ExerciseAttempt> get exerciseAttempts =>
      attempt?.exerciseAttempts ?? const [];

  ExerciseAttempt? get currentExercise {
    final items = exerciseAttempts;
    if (items.isEmpty || currentIndex < 0 || currentIndex >= items.length) {
      return null;
    }
    return items[currentIndex];
  }

  String get progressText => exerciseAttempts.isEmpty
      ? '0 de 0'
      : '${currentIndex + 1} de ${exerciseAttempts.length}';

  bool get isLastExercise => currentIndex >= exerciseAttempts.length - 1;

  Future<void> load(String attemptId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      attempt = await _assessmentRepository.getAttemptById(attemptId);
      currentIndex = _firstPendingIndex(attempt!.exerciseAttempts);
    } catch (error) {
      errorMessage = _messageFor(error);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void markCurrentCompleted() {
    if (!isLastExercise) {
      currentIndex++;
    }
    notifyListeners();
  }

  Future<AssessmentResult?> finish() async {
    final currentAttempt = attempt;
    if (currentAttempt == null) {
      return null;
    }
    isFinishing = true;
    errorMessage = null;
    notifyListeners();
    try {
      result = await _assessmentRepository.finishAttempt(currentAttempt.id);
      return result;
    } catch (_) {
      try {
        result = await _assessmentRepository.getResult(currentAttempt.id);
        return result;
      } catch (error) {
        errorMessage = _messageFor(error);
        return null;
      }
    } finally {
      isFinishing = false;
      notifyListeners();
    }
  }

  int _firstPendingIndex(List<ExerciseAttempt> items) {
    for (var index = 0; index < items.length; index++) {
      final status = items[index].status?.toLowerCase();
      if (status == null ||
          status == 'pending' ||
          status == 'started' ||
          status == 'in_progress') {
        return index;
      }
    }
    return 0;
  }

  String _messageFor(Object error) {
    if (error is ApiException) {
      return error.message;
    }
    return 'No se pudo cargar el intento.';
  }
}
