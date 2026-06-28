import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/session/auth_session_manager.dart';
import '../../../../core/validators/auth_validators.dart';
import '../../domain/models/teacher_profile.dart';
import '../../domain/models/update_teacher_profile_request.dart';

class TeacherProfileViewModel extends ChangeNotifier {
  TeacherProfileViewModel({required AuthSessionManager sessionManager})
    : _sessionManager = sessionManager;

  final AuthSessionManager _sessionManager;

  TeacherProfile? _originalProfile;
  bool _initialized = false;
  String firstName = '';
  String lastName = '';
  String email = '';
  String institution = '';
  String phone = '';
  bool isLoading = false;
  bool isSigningOut = false;
  String? errorMessage;

  bool get isInitialized => _initialized;

  bool get hasChanges {
    final original = _originalProfile;
    if (original == null) {
      return false;
    }
    return _normalize(firstName) != _normalize(original.name) ||
        _normalize(lastName) != _normalize(original.lastname) ||
        _normalize(email) != _normalize(original.email) ||
        _normalize(institution) != _normalize(original.instituteName) ||
        _normalize(phone) != _normalize(original.phone);
  }

  bool get isFormValid {
    return AuthValidators.validateRequiredField(
              firstName,
              'Los nombres son obligatorios.',
            ) ==
            null &&
        AuthValidators.validateRequiredField(
              lastName,
              'Los apellidos son obligatorios.',
            ) ==
            null &&
        AuthValidators.validateEmail(email) == null &&
        AuthValidators.validateRequiredField(
              institution,
              'La institucion educativa es obligatoria.',
            ) ==
            null &&
        AuthValidators.validatePhone(phone) == null;
  }

  bool get canSave => hasChanges && isFormValid && !isLoading;

  Future<void> load() async {
    if (_initialized || isLoading) {
      return;
    }
    isLoading = true;
    notifyListeners();
    try {
      final profile =
          _sessionManager.currentTeacher ?? await _loadRemoteProfile();
      if (profile != null) {
        initialize(profile);
      }
    } on ApiException catch (error) {
      errorMessage = error.message;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<TeacherProfile?> _loadRemoteProfile() async {
    await _sessionManager.loadCurrentTeacher();
    return _sessionManager.currentTeacher;
  }

  void initialize(TeacherProfile profile) {
    if (_initialized && _originalProfile?.teacherId == profile.teacherId) {
      return;
    }
    _originalProfile = profile;
    _initialized = true;
    _applyProfile(profile);
    errorMessage = null;
    notifyListeners();
  }

  void setFirstName(String value) {
    firstName = value;
    notifyListeners();
  }

  void setLastName(String value) {
    lastName = value;
    notifyListeners();
  }

  void setEmail(String value) {
    email = value;
    notifyListeners();
  }

  void setInstitution(String value) {
    institution = value;
    notifyListeners();
  }

  void setPhone(String value) {
    phone = value;
    notifyListeners();
  }

  void restore() {
    final profile = _originalProfile;
    if (profile == null) {
      return;
    }
    _applyProfile(profile);
    errorMessage = null;
    notifyListeners();
  }

  void _applyProfile(TeacherProfile profile) {
    firstName = profile.name;
    lastName = profile.lastname;
    email = profile.email;
    institution = profile.instituteName ?? '';
    phone = profile.phone ?? '';
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
          'La institucion educativa es obligatoria.',
        ) ??
        AuthValidators.validatePhone(phone);
    return errorMessage == null;
  }

  Future<bool> save() async {
    if (!hasChanges || isLoading) {
      return false;
    }
    if (!validate()) {
      notifyListeners();
      return false;
    }
    isLoading = true;
    notifyListeners();
    try {
      await _sessionManager.updateCurrentTeacher(
        UpdateTeacherProfileRequest(
          name: firstName.trim(),
          lastname: lastName.trim(),
          email: email.trim(),
          instituteName: institution.trim(),
          phone: AuthValidators.normalizePhone(phone),
        ),
      );
      _originalProfile = _sessionManager.currentTeacher;
      restore();
      return true;
    } on ApiException catch (error) {
      errorMessage = error.message;
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    if (isSigningOut) {
      return;
    }
    isSigningOut = true;
    notifyListeners();
    try {
      await _sessionManager.signOut();
    } finally {
      isSigningOut = false;
      notifyListeners();
    }
  }

  TeacherProfile? get currentProfile => _sessionManager.currentTeacher;

  String _normalize(String? value) => value?.trim() ?? '';
}
