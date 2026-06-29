import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../domain/models/assessment_attempt.dart';
import '../../domain/models/assessment_response.dart';
import '../../domain/models/attempt_exercise_args.dart';
import '../../domain/repositories/assessment_repository.dart';

class ChooseWordViewModel extends ChangeNotifier {
  ChooseWordViewModel({required AssessmentRepository assessmentRepository})
    : _assessmentRepository = assessmentRepository;

  final AssessmentRepository _assessmentRepository;

  AttemptExerciseArgs? args;
  ExerciseAttempt? get exerciseAttempt => args?.exerciseAttempt;
  MCResponse? response;
  String? selectedOptionId;
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
      exerciseAttempt?.title ??
      'Elige la opcion correcta';

  List<MCOption> get options => exerciseAttempt?.mcOptions ?? const [];

  Future<void> load(AttemptExerciseArgs value) async {
    args = value;
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      response = await _assessmentRepository.getMCResponse(
        value.exerciseAttempt.id,
      );
      selectedOptionId = response?.selectedOptionId;
    } catch (error) {
      errorMessage = _messageFor(error);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void selectOption(String optionId) {
    selectedOptionId = optionId;
    validationMessage = null;
    notifyListeners();
  }

  Future<bool> submit() async {
    final exerciseAttemptId = exerciseAttempt?.id;
    final optionId = selectedOptionId;
    if (exerciseAttemptId == null || optionId == null) {
      validationMessage = 'Selecciona una respuesta para continuar.';
      notifyListeners();
      return false;
    }
    isSubmitting = true;
    errorMessage = null;
    notifyListeners();
    try {
      response = await _assessmentRepository.submitMCResponse(
        exerciseAttemptId: exerciseAttemptId,
        selectedOptionId: optionId,
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
