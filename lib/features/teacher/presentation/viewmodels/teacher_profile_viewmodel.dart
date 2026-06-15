import 'package:flutter/foundation.dart';

import '../../../../core/validators/auth_validators.dart';
import '../../data/services/teacher_service.dart';
import '../../domain/models/teacher_profile.dart';

class TeacherProfileViewModel extends ChangeNotifier {
  TeacherProfileViewModel({required TeacherService teacherService})
    : _teacherService = teacherService;

  final TeacherService _teacherService;

  TeacherProfile? originalProfile;
  String firstName = '';
  String lastName = '';
  String email = '';
  String institution = '';
  bool isLoading = false;
  String? errorMessage;

  Future<void> load() async {
    isLoading = true;
    notifyListeners();
    originalProfile = await _teacherService.getTeacherProfile();
    restore();
    isLoading = false;
    notifyListeners();
  }

  void setFirstName(String value) => firstName = value;
  void setLastName(String value) => lastName = value;
  void setEmail(String value) => email = value;
  void setInstitution(String value) => institution = value;

  void restore() {
    final profile = originalProfile;
    if (profile == null) return;
    firstName = profile.firstName;
    lastName = profile.lastName;
    email = profile.email;
    institution = profile.institution;
    errorMessage = null;
    notifyListeners();
  }

  bool validate() {
    errorMessage =
        AuthValidators.validateRequiredField(
          firstName,
          'Los nombres son obligatorios.',
        ) ??
        AuthValidators.validateRequiredField(
          lastName,
          'Los apellidos son obligatorios.',
        ) ??
        AuthValidators.validateEmail(email) ??
        AuthValidators.validateRequiredField(
          institution,
          'La institución educativa es obligatoria.',
        );
    return errorMessage == null;
  }

  Future<bool> save() async {
    if (!validate()) {
      notifyListeners();
      return false;
    }
    isLoading = true;
    notifyListeners();
    final profile = TeacherProfile(
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      email: email.trim(),
      institution: institution.trim(),
    );
    await _teacherService.updateTeacherProfile(profile);
    originalProfile = profile;
    isLoading = false;
    notifyListeners();
    return true;
  }

  TeacherProfile get currentProfile {
    return TeacherProfile(
      firstName: firstName,
      lastName: lastName,
      email: email,
      institution: institution,
    );
  }
}
