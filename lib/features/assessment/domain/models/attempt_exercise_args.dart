import 'assessment_attempt.dart';

class AttemptExerciseArgs {
  const AttemptExerciseArgs({
    required this.attemptId,
    required this.exerciseAttempt,
    required this.exerciseIndex,
    required this.totalExercises,
  });

  final String attemptId;
  final ExerciseAttempt exerciseAttempt;
  final int exerciseIndex;
  final int totalExercises;
}
