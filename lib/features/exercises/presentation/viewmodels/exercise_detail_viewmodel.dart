import 'package:flutter/foundation.dart';

import '../../data/services/exercise_service.dart';
import '../../domain/models/exercise.dart';

class ExerciseDetailViewModel extends ChangeNotifier {
  ExerciseDetailViewModel({required ExerciseService exerciseService})
    : _exerciseService = exerciseService;

  final ExerciseService _exerciseService;

  Exercise? exercise;
  bool isLoading = false;
  String? errorMessage;

  Future<void> load(String exerciseId) async {
    isLoading = true;
    notifyListeners();
    exercise = await _exerciseService.getExerciseById(exerciseId);
    isLoading = false;
    notifyListeners();
  }
}
