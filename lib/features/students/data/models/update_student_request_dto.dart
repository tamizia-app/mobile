import '../../domain/models/update_student_request.dart';

class UpdateStudentRequestDto {
  const UpdateStudentRequestDto({
    required this.code,
    required this.age,
    required this.gender,
  });

  factory UpdateStudentRequestDto.fromDomain(UpdateStudentRequest request) {
    return UpdateStudentRequestDto(
      code: request.code,
      age: request.age,
      gender: request.gender,
    );
  }

  final String code;
  final int age;
  final String gender;

  Map<String, dynamic> toJson() {
    return {'code': code, 'age': age, 'gender': gender};
  }
}
