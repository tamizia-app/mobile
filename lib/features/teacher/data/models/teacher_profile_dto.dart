import '../../domain/models/teacher_profile.dart';

class TeacherProfileDto {
  const TeacherProfileDto({
    required this.teacherId,
    required this.name,
    required this.lastname,
    required this.email,
    required this.instituteName,
    required this.phone,
  });

  factory TeacherProfileDto.fromJson(Map<String, dynamic> json) {
    return TeacherProfileDto(
      teacherId: json['teacher_id'] as String,
      name: json['name'] as String,
      lastname: json['lastname'] as String,
      email: json['email'] as String,
      instituteName: json['institute_name'] as String?,
      phone: json['phone'] as String?,
    );
  }

  final String teacherId;
  final String name;
  final String lastname;
  final String email;
  final String? instituteName;
  final String? phone;

  TeacherProfile toDomain() {
    return TeacherProfile(
      teacherId: teacherId,
      name: name,
      lastname: lastname,
      email: email,
      instituteName: instituteName,
      phone: phone,
    );
  }
}
