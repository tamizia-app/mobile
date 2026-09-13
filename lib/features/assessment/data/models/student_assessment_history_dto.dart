import '../../domain/models/student_assessment_history.dart';

class StudentAssessmentHistoryDto {
  const StudentAssessmentHistoryDto({
    required this.studentId,
    this.student,
    required this.summary,
    this.chartPoints = const [],
    this.items = const [],
    this.total = 0,
    this.limit = 20,
    this.offset = 0,
  });

  factory StudentAssessmentHistoryDto.fromJson(Map<String, dynamic> json) {
    return StudentAssessmentHistoryDto(
      studentId: _requiredString(json, 'student_id'),
      student: json['student'] != null
          ? StudentBriefDto.fromJson(json['student'] as Map<String, dynamic>)
          : null,
      summary: StudentHistorySummaryDto.fromJson(
        json['summary'] as Map<String, dynamic>,
      ),
      chartPoints: _readChartPoints(json),
      items: _readHistoryItems(json),
      total: _optionalInt(json, 'total') ?? 0,
      limit: _optionalInt(json, 'limit') ?? 20,
      offset: _optionalInt(json, 'offset') ?? 0,
    );
  }

  final String studentId;
  final StudentBriefDto? student;
  final StudentHistorySummaryDto summary;
  final List<StudentHistoryChartPointDto> chartPoints;
  final List<StudentHistoryItemDto> items;
  final int total;
  final int limit;
  final int offset;

  StudentAssessmentHistory toDomain() {
    return StudentAssessmentHistory(
      studentId: studentId,
      student: student?.toDomain(),
      summary: summary.toDomain(),
      chartPoints: chartPoints.map((e) => e.toDomain()).toList(growable: false),
      items: items.map((e) => e.toDomain()).toList(growable: false),
      total: total,
      limit: limit,
      offset: offset,
    );
  }

  static List<StudentHistoryChartPointDto> _readChartPoints(
    Map<String, dynamic> json,
  ) {
    final value = json['chart_points'];
    if (value is! List) return const [];
    return value
        .whereType<Map<String, dynamic>>()
        .map(StudentHistoryChartPointDto.fromJson)
        .toList(growable: false);
  }

  static List<StudentHistoryItemDto> _readHistoryItems(
    Map<String, dynamic> json,
  ) {
    final value = json['items'];
    if (value is! List) return const [];
    return value
        .whereType<Map<String, dynamic>>()
        .map(StudentHistoryItemDto.fromJson)
        .toList(growable: false);
  }
}

class StudentBriefDto {
  const StudentBriefDto({
    required this.studentId,
    required this.code,
    required this.age,
    required this.gender,
    this.classroom,
  });

  factory StudentBriefDto.fromJson(Map<String, dynamic> json) {
    return StudentBriefDto(
      studentId: _requiredString(json, 'student_id'),
      code: _requiredString(json, 'code'),
      age: _optionalInt(json, 'age') ?? 0,
      gender: _requiredString(json, 'gender'),
      classroom: json['classroom'] != null
          ? ClassroomBriefDto.fromJson(
              json['classroom'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  final String studentId;
  final String code;
  final int age;
  final String gender;
  final ClassroomBriefDto? classroom;

  StudentBrief toDomain() {
    return StudentBrief(
      studentId: studentId,
      code: code,
      age: age,
      gender: gender,
      classroom: classroom?.toDomain(),
    );
  }
}

class ClassroomBriefDto {
  const ClassroomBriefDto({
    required this.classroomId,
    required this.name,
    required this.gradeLevel,
    required this.section,
  });

  factory ClassroomBriefDto.fromJson(Map<String, dynamic> json) {
    return ClassroomBriefDto(
      classroomId: _requiredString(json, 'classroom_id'),
      name: _requiredString(json, 'name'),
      gradeLevel: _requiredString(json, 'grade_level'),
      section: _requiredString(json, 'section'),
    );
  }

  final String classroomId;
  final String name;
  final String gradeLevel;
  final String section;

  ClassroomBrief toDomain() {
    return ClassroomBrief(
      classroomId: classroomId,
      name: name,
      gradeLevel: gradeLevel,
      section: section,
    );
  }
}

class StudentHistorySummaryDto {
  const StudentHistorySummaryDto({
    required this.attemptsCount,
    required this.completedAttemptsCount,
    this.latestScore,
    this.averageScore,
    this.bestScore,
    this.lowestScore,
    this.trendPercentage,
    this.latestInterventionLevel,
    this.latestCompletedAt,
  });

  factory StudentHistorySummaryDto.fromJson(Map<String, dynamic> json) {
    return StudentHistorySummaryDto(
      attemptsCount: _optionalInt(json, 'attempts_count') ?? 0,
      completedAttemptsCount:
          _optionalInt(json, 'completed_attempts_count') ?? 0,
      latestScore: _optionalDouble(json, 'latest_score'),
      averageScore: _optionalDouble(json, 'average_score'),
      bestScore: _optionalDouble(json, 'best_score'),
      lowestScore: _optionalDouble(json, 'lowest_score'),
      trendPercentage: _optionalDouble(json, 'trend_percentage'),
      latestInterventionLevel: _optionalString(
        json,
        'latest_intervention_level',
      ),
      latestCompletedAt: _optionalDateTime(json, 'latest_completed_at'),
    );
  }

  final int attemptsCount;
  final int completedAttemptsCount;
  final double? latestScore;
  final double? averageScore;
  final double? bestScore;
  final double? lowestScore;
  final double? trendPercentage;
  final String? latestInterventionLevel;
  final DateTime? latestCompletedAt;

  StudentHistorySummary toDomain() {
    return StudentHistorySummary(
      attemptsCount: attemptsCount,
      completedAttemptsCount: completedAttemptsCount,
      latestScore: latestScore,
      averageScore: averageScore,
      bestScore: bestScore,
      lowestScore: lowestScore,
      trendPercentage: trendPercentage,
      latestInterventionLevel: latestInterventionLevel,
      latestCompletedAt: latestCompletedAt,
    );
  }
}

class StudentHistoryChartPointDto {
  const StudentHistoryChartPointDto({
    required this.attemptId,
    required this.assessmentId,
    this.assessmentName,
    this.completedAt,
    this.finalScore,
    this.interventionLevel,
  });

  factory StudentHistoryChartPointDto.fromJson(Map<String, dynamic> json) {
    return StudentHistoryChartPointDto(
      attemptId: _requiredString(json, 'attempt_id'),
      assessmentId: _requiredString(json, 'assessment_id'),
      assessmentName: _optionalAssessmentName(json),
      completedAt: _optionalDateTime(json, 'completed_at'),
      finalScore: _optionalDouble(json, 'final_score'),
      interventionLevel: _optionalString(json, 'intervention_level'),
    );
  }

  final String attemptId;
  final String assessmentId;
  final String? assessmentName;
  final DateTime? completedAt;
  final double? finalScore;
  final String? interventionLevel;

  StudentHistoryChartPoint toDomain() {
    return StudentHistoryChartPoint(
      attemptId: attemptId,
      assessmentId: assessmentId,
      assessmentName: assessmentName,
      completedAt: completedAt,
      finalScore: finalScore,
      interventionLevel: interventionLevel,
    );
  }
}

class StudentHistoryItemDto {
  const StudentHistoryItemDto({
    required this.attemptId,
    required this.assessmentId,
    this.assessmentName,
    required this.status,
    this.startedAt,
    this.completedAt,
    this.finalScore,
    this.maxScore,
    this.interventionLevel,
    this.mcCorrectCount,
    this.osCorrectCount,
    this.speakingCompletedCount,
    this.speakingAverageScore,
    this.speakingReviewRequiredCount = 0,
    this.writingCompletedCount,
    this.writingAverageScore,
    this.writingReviewRequiredCount = 0,
    this.totalExercises = 0,
    this.evaluatedExercises = 0,
    this.pendingExercises = 0,
  });

  factory StudentHistoryItemDto.fromJson(Map<String, dynamic> json) {
    return StudentHistoryItemDto(
      attemptId: _requiredString(json, 'attempt_id'),
      assessmentId: _requiredString(json, 'assessment_id'),
      assessmentName: _optionalAssessmentName(json),
      status: _requiredString(json, 'status'),
      startedAt: _optionalDateTime(json, 'started_at'),
      completedAt: _optionalDateTime(json, 'completed_at'),
      finalScore: _optionalDouble(json, 'final_score'),
      maxScore: _optionalDouble(json, 'max_score'),
      interventionLevel: _optionalString(json, 'intervention_level'),
      mcCorrectCount: _optionalInt(json, 'mc_correct_count'),
      osCorrectCount: _optionalInt(json, 'os_correct_count'),
      speakingCompletedCount: _optionalInt(json, 'speaking_completed_count'),
      speakingAverageScore: _optionalDouble(json, 'speaking_average_score'),
      speakingReviewRequiredCount:
          _optionalInt(json, 'speaking_review_required_count') ?? 0,
      writingCompletedCount: _optionalInt(json, 'writing_completed_count'),
      writingAverageScore: _optionalDouble(json, 'writing_average_score'),
      writingReviewRequiredCount:
          _optionalInt(json, 'writing_review_required_count') ?? 0,
      totalExercises: _optionalInt(json, 'total_exercises') ?? 0,
      evaluatedExercises: _optionalInt(json, 'evaluated_exercises') ?? 0,
      pendingExercises: _optionalInt(json, 'pending_exercises') ?? 0,
    );
  }

  final String attemptId;
  final String assessmentId;
  final String? assessmentName;
  final String status;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final double? finalScore;
  final double? maxScore;
  final String? interventionLevel;
  final int? mcCorrectCount;
  final int? osCorrectCount;
  final int? speakingCompletedCount;
  final double? speakingAverageScore;
  final int speakingReviewRequiredCount;
  final int? writingCompletedCount;
  final double? writingAverageScore;
  final int writingReviewRequiredCount;
  final int totalExercises;
  final int evaluatedExercises;
  final int pendingExercises;

  StudentHistoryItem toDomain() {
    return StudentHistoryItem(
      attemptId: attemptId,
      assessmentId: assessmentId,
      assessmentName: assessmentName,
      status: status,
      startedAt: startedAt,
      completedAt: completedAt,
      finalScore: finalScore,
      maxScore: maxScore,
      interventionLevel: interventionLevel,
      mcCorrectCount: mcCorrectCount,
      osCorrectCount: osCorrectCount,
      speakingCompletedCount: speakingCompletedCount,
      speakingAverageScore: speakingAverageScore,
      speakingReviewRequiredCount: speakingReviewRequiredCount,
      writingCompletedCount: writingCompletedCount,
      writingAverageScore: writingAverageScore,
      writingReviewRequiredCount: writingReviewRequiredCount,
      totalExercises: totalExercises,
      evaluatedExercises: evaluatedExercises,
      pendingExercises: pendingExercises,
    );
  }
}

String _requiredString(Map<String, dynamic> json, String key) {
  final value = _optionalString(json, key);
  if (value == null || value.isEmpty) {
    throw FormatException('Invalid result field: $key.');
  }
  return value;
}

String? _optionalString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value == null) return null;
  if (value is String) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
  return value is num || value is bool ? value.toString() : null;
}

String? _optionalAssessmentName(Map<String, dynamic> json) {
  final name = _optionalString(json, 'assessment_name');
  if (name == null || name.toLowerCase() == 'untitled') {
    return null;
  }
  return name;
}

int? _optionalInt(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is int) return value;
  if (value is num) return value.toInt();
  return null;
}

double? _optionalDouble(Map<String, dynamic> json, String key) {
  final value = json[key];
  return value is num ? value.toDouble() : null;
}

DateTime? _optionalDateTime(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! String || value.trim().isEmpty) return null;
  return DateTime.tryParse(value);
}
