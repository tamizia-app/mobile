import '../../domain/models/assessment_attempt.dart';

class AssessmentAttemptDto {
  const AssessmentAttemptDto({
    required this.attemptId,
    this.assessmentId,
    this.studentId,
    this.status,
    this.startedAt,
    this.completedAt,
    this.exerciseAttempts = const [],
  });

  factory AssessmentAttemptDto.fromJson(Map<String, dynamic> json) {
    final attemptId =
        _optionalString(json, 'attempt_id') ?? _optionalString(json, 'id');
    if (attemptId == null || attemptId.isEmpty) {
      throw const FormatException('Invalid attempt response.');
    }
    return AssessmentAttemptDto(
      attemptId: attemptId,
      assessmentId: _optionalString(json, 'assessment_id'),
      studentId: _optionalString(json, 'student_id'),
      status: _optionalString(json, 'status'),
      startedAt: _optionalDateTime(json, 'started_at'),
      completedAt: _optionalDateTime(json, 'completed_at'),
      exerciseAttempts: _readExerciseAttempts(json),
    );
  }

  final String attemptId;
  final String? assessmentId;
  final String? studentId;
  final String? status;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final List<ExerciseAttemptDto> exerciseAttempts;

  AssessmentAttempt toDomain({
    required String assessmentIdFallback,
    required String studentIdFallback,
  }) {
    return AssessmentAttempt(
      attemptId: attemptId,
      assessmentId: assessmentId ?? assessmentIdFallback,
      studentId: studentId ?? studentIdFallback,
      status: status,
      startedAt: startedAt,
      completedAt: completedAt,
      exerciseAttempts: exerciseAttempts
          .map((item) => item.toDomain())
          .toList(growable: false),
    );
  }

  static List<ExerciseAttemptDto> _readExerciseAttempts(
    Map<String, dynamic> json,
  ) {
    final candidates = [
      json['exercise_attempts'],
      json['exerciseAttempts'],
      json['exercises'],
      json['items'],
    ];
    final list = _firstList(candidates);
    if (list == null) {
      return const [];
    }
    return list
        .whereType<Map<String, dynamic>>()
        .map(ExerciseAttemptDto.fromJson)
        .toList(growable: false);
  }
}

class ExerciseAttemptDto {
  const ExerciseAttemptDto({
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

  factory ExerciseAttemptDto.fromJson(Map<String, dynamic> json) {
    final exerciseJson = json['exercise'];
    final exerciseMap = exerciseJson is Map<String, dynamic>
        ? exerciseJson
        : const <String, dynamic>{};
    final promptExercise = _childMap(exerciseMap, 'prompt_exercise');
    final mcQuestion = _childMap(exerciseMap, 'mc_question');
    final osQuestion = _childMap(exerciseMap, 'os_question');
    final exerciseAttemptId =
        _optionalString(json, 'exercise_attempt_id') ??
        _optionalString(json, 'id');
    if (exerciseAttemptId == null || exerciseAttemptId.isEmpty) {
      throw const FormatException('Invalid exercise attempt response.');
    }
    return ExerciseAttemptDto(
      exerciseAttemptId: exerciseAttemptId,
      templateExerciseId: _optionalString(json, 'template_exercise_id'),
      exerciseId:
          _optionalString(json, 'exercise_id') ??
          _optionalString(exerciseMap, 'exercise_id') ??
          _optionalString(exerciseMap, 'id'),
      title:
          _optionalString(json, 'title') ??
          _optionalString(json, 'name') ??
          _optionalString(exerciseMap, 'title') ??
          _optionalString(exerciseMap, 'name'),
      type:
          _optionalString(json, 'type') ?? _optionalString(exerciseMap, 'type'),
      status: _optionalString(json, 'status'),
      instructions: _optionalString(exerciseMap, 'instructions'),
      prompt:
          _optionalString(mcQuestion, 'question_text') ??
          _optionalString(osQuestion, 'question_text') ??
          _optionalString(promptExercise, 'prompt_text'),
      textToShow: _optionalString(promptExercise, 'text_to_show'),
      expectedText: _optionalString(promptExercise, 'expected_text'),
      languageCode: _optionalString(promptExercise, 'language_code'),
      imageUrl:
          _optionalString(mcQuestion, 'image_url') ??
          _optionalString(mcQuestion, 'image_blob_path') ??
          _optionalString(osQuestion, 'image_blob_path') ??
          _optionalString(promptExercise, 'image_blob_path'),
      mcOptions: _readMCOptions(mcQuestion),
      syllables: _readStringList(osQuestion, 'syllables_json'),
      correctWord: _optionalString(osQuestion, 'correct_word'),
      startedAt: _optionalDateTime(json, 'started_at'),
      submittedAt: _optionalDateTime(json, 'submitted_at'),
    );
  }

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
  final List<MCOptionDto> mcOptions;
  final List<String> syllables;
  final String? correctWord;
  final DateTime? startedAt;
  final DateTime? submittedAt;

  ExerciseAttempt toDomain() {
    return ExerciseAttempt(
      exerciseAttemptId: exerciseAttemptId,
      exerciseId: exerciseId,
      templateExerciseId: templateExerciseId,
      title: title,
      type: type,
      status: status,
      instructions: instructions,
      prompt: prompt,
      textToShow: textToShow,
      expectedText: expectedText,
      languageCode: languageCode,
      imageUrl: imageUrl,
      mcOptions: mcOptions
          .map((item) => item.toDomain())
          .toList(growable: false),
      syllables: syllables,
      correctWord: correctWord,
      startedAt: startedAt,
      submittedAt: submittedAt,
    );
  }

  static List<MCOptionDto> _readMCOptions(Map<String, dynamic> json) {
    final value = json['options'];
    if (value is! List) {
      return const [];
    }
    final options = value
        .whereType<Map<String, dynamic>>()
        .map(MCOptionDto.fromJson)
        .toList(growable: false);
    options.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    return options;
  }
}

class MCOptionDto {
  const MCOptionDto({
    required this.optionId,
    required this.text,
    required this.orderIndex,
  });

  factory MCOptionDto.fromJson(Map<String, dynamic> json) {
    final optionId = _optionalString(json, 'option_id');
    final text = _optionalString(json, 'text');
    if (optionId == null || optionId.isEmpty || text == null || text.isEmpty) {
      throw const FormatException('Invalid MC option response.');
    }
    return MCOptionDto(
      optionId: optionId,
      text: text,
      orderIndex: _optionalInt(json, 'order_index') ?? 0,
    );
  }

  final String optionId;
  final String text;
  final int orderIndex;

  MCOption toDomain() {
    return MCOption(optionId: optionId, text: text, orderIndex: orderIndex);
  }
}

List<dynamic>? _firstList(List<dynamic> candidates) {
  for (final candidate in candidates) {
    if (candidate is List) {
      return candidate;
    }
  }
  return null;
}

Map<String, dynamic> _childMap(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is Map<String, dynamic>) {
    return value;
  }
  return const {};
}

List<String> _readStringList(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! List) {
    return const [];
  }
  return value.whereType<String>().toList(growable: false);
}

String? _optionalString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value == null) {
    return null;
  }
  if (value is String) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
  if (value is num || value is bool) {
    return value.toString();
  }
  return null;
}

int? _optionalInt(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return null;
}

DateTime? _optionalDateTime(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! String || value.trim().isEmpty) {
    return null;
  }
  return DateTime.tryParse(value);
}
