import 'package:flutter/foundation.dart';

import '../../../exercises/data/services/exercise_service.dart';
import '../../../exercises/domain/models/exercise.dart';
import '../../data/services/assessment_service.dart';
import '../../domain/models/assessment_session.dart';
import '../../domain/models/assessment_type.dart';

class StudentInstructionsViewModel extends ChangeNotifier {
  StudentInstructionsViewModel({
    required ExerciseService exerciseService,
    required AssessmentService assessmentService,
  }) : _exerciseService = exerciseService,
       _assessmentService = assessmentService;

  final ExerciseService _exerciseService;
  final AssessmentService _assessmentService;

  Exercise? exercise;
  AssessmentSession? session;
  bool isLoading = false;

  Future<void> load(AssessmentSession assessmentSession) async {
    isLoading = true;
    session = assessmentSession;
    notifyListeners();
    exercise = await _exerciseService.getExerciseById(
      assessmentSession.exerciseId,
    );
    isLoading = false;
    notifyListeners();
  }

  Future<void> start() async {
    final currentSession = session;
    if (currentSession == null) return;
    await _assessmentService.startSession(currentSession.id);
  }

  String get instructionText {
    switch (exercise?.type) {
      case null:
        return 'Lee el texto en voz alta cuando el docente te lo indique';
      default:
        return exercise?.type.label == 'Escritura'
            ? 'Escribe la frase cuando el docente te lo indique'
            : 'Lee el texto en voz alta cuando el docente te lo indique';
    }
  }
}
