class Classroom {
  const Classroom({
    required this.id,
    required this.name,
    required this.grade,
    required this.section,
    required this.schoolYear,
    required this.studentCount,
  });

  final String id;
  final String name;
  final String grade;
  final String section;
  final String schoolYear;
  final int studentCount;

  Classroom copyWith({
    String? id,
    String? name,
    String? grade,
    String? section,
    String? schoolYear,
    int? studentCount,
  }) {
    return Classroom(
      id: id ?? this.id,
      name: name ?? this.name,
      grade: grade ?? this.grade,
      section: section ?? this.section,
      schoolYear: schoolYear ?? this.schoolYear,
      studentCount: studentCount ?? this.studentCount,
    );
  }
}
