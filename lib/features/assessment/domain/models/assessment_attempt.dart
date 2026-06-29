class AssessmentAttempt {
  const AssessmentAttempt({
    required this.attemptId,
    required this.assessmentId,
    required this.studentId,
    required this.exerciseAttempts,
    this.status,
    this.startedAt,
    this.completedAt,
  });

  final String attemptId;
  final String assessmentId;
  final String studentId;
  final String? status;
  final List<ExerciseAttempt> exerciseAttempts;
  final DateTime? startedAt;
  final DateTime? completedAt;

  String get id => attemptId;

  bool get isIncomplete {
    final value = status?.trim().toLowerCase();
    if (value == null || value.isEmpty) {
      return false;
    }
    return value != 'finished' &&
        value != 'completed' &&
        value != 'cancelled' &&
        value != 'canceled' &&
        value != 'failed';
  }
}

class ExerciseAttempt {
  const ExerciseAttempt({
    required this.exerciseAttemptId,
    this.exerciseId,
    this.templateExerciseId,
    this.title,
    this.type,
    this.status,
    this.instructions,
    this.prompt,
    this.textToShow,
    this.expectedText,
    this.languageCode,
    this.imageUrl,
    this.mcOptions = const [],
    this.syllables = const [],
    this.correctWord,
    this.startedAt,
    this.submittedAt,
  });

  final String exerciseAttemptId;
  final String? exerciseId;
  final String? templateExerciseId;
  final String? title;
  final String? type;
  final String? status;
  final String? instructions;
  final String? prompt;
  final String? textToShow;
  final String? expectedText;
  final String? languageCode;
  final String? imageUrl;
  final List<MCOption> mcOptions;
  final List<String> syllables;
  final String? correctWord;
  final DateTime? startedAt;
  final DateTime? submittedAt;

  String get id => exerciseAttemptId;
  String get displayName {
    final cleanTitle = title?.trim();
    if (cleanTitle != null && cleanTitle.isNotEmpty) {
      return cleanTitle;
    }
    final cleanExerciseId = exerciseId?.trim();
    if (cleanExerciseId != null && cleanExerciseId.isNotEmpty) {
      return 'Ejercicio $cleanExerciseId';
    }
    return 'Exercise attempt $exerciseAttemptId';
  }
}

class MCOption {
  const MCOption({
    required this.optionId,
    required this.text,
    required this.orderIndex,
  });

  final String optionId;
  final String text;
  final int orderIndex;
}
