import '../../domain/models/update_classroom_request.dart';

class UpdateClassroomRequestDto {
  const UpdateClassroomRequestDto({
    required this.name,
    required this.gradeLevel,
    required this.section,
    required this.schoolYear,
  });

  factory UpdateClassroomRequestDto.fromDomain(UpdateClassroomRequest request) {
    return UpdateClassroomRequestDto(
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
      'school_year': DateTime(
        schoolYear.year,
      ).toIso8601String().split('T').first,
    };
  }
}
