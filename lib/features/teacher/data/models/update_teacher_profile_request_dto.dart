import '../../domain/models/update_teacher_profile_request.dart';

class UpdateTeacherProfileRequestDto {
  const UpdateTeacherProfileRequestDto({
    required this.name,
    required this.lastname,
    required this.email,
    required this.instituteName,
    required this.phone,
  });

  factory UpdateTeacherProfileRequestDto.fromDomain(
    UpdateTeacherProfileRequest request,
  ) {
    return UpdateTeacherProfileRequestDto(
      name: request.name,
      lastname: request.lastname,
      email: request.email,
      instituteName: request.instituteName,
      phone: request.phone,
    );
  }

  final String name;
  final String lastname;
  final String email;
  final String? instituteName;
  final String? phone;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'lastname': lastname,
      'email': email,
      'institute_name': instituteName,
      'phone': phone,
    };
  }
}
