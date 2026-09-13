import '../../domain/models/register_request.dart';

class SignupRequestDto {
  const SignupRequestDto({
    required this.name,
    required this.lastname,
    required this.email,
    required this.password,
    required this.instituteName,
    required this.phone,
  });

  factory SignupRequestDto.fromDomain(RegisterRequest request) {
    return SignupRequestDto(
      name: request.names,
      lastname: request.lastNames,
      email: request.email,
      password: request.password,
      instituteName: request.institution,
      phone: request.phone,
    );
  }

  final String name;
  final String lastname;
  final String email;
  final String password;
  final String instituteName;
  final String phone;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'lastname': lastname,
      'email': email,
      'password': password,
      'institute_name': instituteName,
      'phone': phone,
    };
  }
}
