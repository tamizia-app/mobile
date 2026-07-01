class StudentAssessmentHistory {
  const StudentAssessmentHistory({
    required this.studentId,
    this.student,
    required this.summary,
    this.chartPoints = const [],
    this.items = const [],
    this.total = 0,
    this.limit = 20,
    this.offset = 0,
  });

  final String studentId;
  final StudentBrief? student;
  final StudentHistorySummary summary;
  final List<StudentHistoryChartPoint> chartPoints;
  final List<StudentHistoryItem> items;
  final int total;
  final int limit;
  final int offset;
}

class StudentBrief {
  const StudentBrief({
    required this.studentId,
    required this.code,
    required this.age,
    required this.gender,
    this.classroom,
  });

  final String studentId;
  final String code;
  final int age;
  final String gender;
  final ClassroomBrief? classroom;
}

class ClassroomBrief {
  const ClassroomBrief({
    required this.classroomId,
    required this.name,
    required this.gradeLevel,
    required this.section,
  });

  final String classroomId;
  final String name;
  final String gradeLevel;
  final String section;
}

class StudentHistorySummary {
  const StudentHistorySummary({
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

  final int attemptsCount;
  final int completedAttemptsCount;
  final double? latestScore;
  final double? averageScore;
  final double? bestScore;
  final double? lowestScore;
  final double? trendPercentage;
  final String? latestInterventionLevel;
  final DateTime? latestCompletedAt;
}

class StudentHistoryChartPoint {
  const StudentHistoryChartPoint({
    required this.attemptId,
    required this.assessmentId,
    this.assessmentName,
    this.completedAt,
    this.finalScore,
    this.interventionLevel,
  });

  final String attemptId;
  final String assessmentId;
  final String? assessmentName;
  final DateTime? completedAt;
  final double? finalScore;
  final String? interventionLevel;
}

class StudentHistoryItem {
  const StudentHistoryItem({
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
}
