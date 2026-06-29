import '../../domain/models/create_classroom_request.dart';

class CreateClassroomRequestDto {
  const CreateClassroomRequestDto({
    required this.name,
    required this.gradeLevel,
    required this.section,
    required this.schoolYear,
  });

  factory CreateClassroomRequestDto.fromDomain(CreateClassroomRequest request) {
    return CreateClassroomRequestDto(
      name: request.name,
      gradeLevel: request.gradeLevel,
      section: request.section,
      schoolYear: request.schoolYear,
    );
  }

  final String name;
  final String gradeLevel;
  final String section;
  final DateTime schoolYear;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'grade_level': gradeLevel,
      'section': section,
      'school_year': _dateOnly(schoolYear),
    };
  }
}

String _dateOnly(DateTime date) {
  return DateTime(date.year).toIso8601String().split('T').first;
}
