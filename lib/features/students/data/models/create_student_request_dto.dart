import '../../domain/models/create_student_request.dart';

class CreateStudentRequestDto {
  const CreateStudentRequestDto({
    required this.code,
    required this.age,
    required this.gender,
  });

  factory CreateStudentRequestDto.fromDomain(CreateStudentRequest request) {
    return CreateStudentRequestDto(
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
