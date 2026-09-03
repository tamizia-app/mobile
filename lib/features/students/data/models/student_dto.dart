import '../../domain/models/student.dart';

class StudentDto {
  const StudentDto({
    required this.studentId,
    required this.classroomId,
    required this.code,
    required this.age,
    required this.gender,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StudentDto.fromJson(Map<String, dynamic> json) {
    return StudentDto(
      studentId: _string(json, 'student_id'),
      classroomId: _string(json, 'classroom_id'),
      code: _string(json, 'code'),
      age: _integer(json, 'age'),
      gender: _string(json, 'gender'),
      isActive: _boolean(json, 'is_active'),
      createdAt: _dateTime(json, 'created_at'),
      updatedAt: _dateTime(json, 'updated_at'),
    );
  }

  final String studentId;
  final String classroomId;
  final String code;
  final int age;
  final String gender;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Student toDomain() {
    return Student(
      studentId: studentId,
      classroomId: classroomId,
      code: code,
      age: age,
      gender: gender,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

String _string(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('Invalid student field: $key.');
  }
  return value;
}

int _integer(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! int) {
    throw FormatException('Invalid student field: $key.');
  }
  return value;
}

bool _boolean(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! bool) {
    throw FormatException('Invalid student field: $key.');
  }
  return value;
}

DateTime _dateTime(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! String) {
    throw FormatException('Invalid student field: $key.');
  }
  final parsed = DateTime.tryParse(value);
  if (parsed == null) {
    throw FormatException('Invalid student field: $key.');
  }
  return parsed;
}
