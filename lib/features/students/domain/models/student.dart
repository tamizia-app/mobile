class Student {
  const Student({
    required this.id,
    required this.code,
    required this.alias,
    required this.age,
    required this.grade,
    required this.classroomId,
    required this.classroomName,
    required this.lastEvaluation,
    required this.consentStatus,
    required this.revisionLevel,
    this.hasParentAuthorization = false,
    this.needsReview = false,
  });

  final String id;
  final String code;
  final String alias;
  final int age;
  final String grade;
  final String classroomId;
  final String classroomName;
  final String lastEvaluation;
  final String consentStatus;
  final String revisionLevel;
  final bool hasParentAuthorization;
  final bool needsReview;

  Student copyWith({
    String? id,
    String? code,
    String? alias,
    int? age,
    String? grade,
    String? classroomId,
    String? classroomName,
    String? lastEvaluation,
    String? consentStatus,
    String? revisionLevel,
    bool? hasParentAuthorization,
    bool? needsReview,
  }) {
    return Student(
      id: id ?? this.id,
      code: code ?? this.code,
      alias: alias ?? this.alias,
      age: age ?? this.age,
      grade: grade ?? this.grade,
      classroomId: classroomId ?? this.classroomId,
      classroomName: classroomName ?? this.classroomName,
      lastEvaluation: lastEvaluation ?? this.lastEvaluation,
      consentStatus: consentStatus ?? this.consentStatus,
      revisionLevel: revisionLevel ?? this.revisionLevel,
      hasParentAuthorization:
          hasParentAuthorization ?? this.hasParentAuthorization,
      needsReview: needsReview ?? this.needsReview,
    );
  }
}
