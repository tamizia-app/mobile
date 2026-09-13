import '../../domain/models/classroom.dart';

class ClassroomDto {
  const ClassroomDto({
    required this.classroomId,
    required this.homeroomTeacherId,
    required this.name,
    required this.gradeLevel,
    required this.section,
    required this.schoolYear,
  });

  factory ClassroomDto.fromJson(Map<String, dynamic> json) {
    final schoolYearValue = _requiredString(json, 'school_year');
    final schoolYear = DateTime.tryParse(schoolYearValue);
    if (schoolYear == null ||
        !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(schoolYearValue)) {
      throw const FormatException('Invalid classroom school_year.');
    }
    return ClassroomDto(
      classroomId: _requiredString(json, 'classroom_id'),
      homeroomTeacherId: _requiredString(json, 'homeroom_teacher_id'),
      name: _requiredString(json, 'name'),
      gradeLevel: _requiredString(json, 'grade_level'),
      section: _requiredString(json, 'section'),
      schoolYear: schoolYear,
    );
  }

  final String classroomId;
  final String homeroomTeacherId;
  final String name;
  final String gradeLevel;
  final String section;
  final DateTime schoolYear;

  Classroom toDomain() {
    return Classroom(
      classroomId: classroomId,
      homeroomTeacherId: homeroomTeacherId,
      name: name,
      gradeLevel: gradeLevel,
      section: section,
      schoolYear: schoolYear,
    );
  }

  static String _requiredString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('Invalid classroom field: $key.');
    }
    return value;
  }
}
