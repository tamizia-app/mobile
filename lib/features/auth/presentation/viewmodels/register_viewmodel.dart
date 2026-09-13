import 'package:flutter/foundation.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/session/auth_session_manager.dart';
import '../../../../core/validators/auth_validators.dart';
import '../../domain/models/register_request.dart';

class RegisterViewModel extends ChangeNotifier {
  RegisterViewModel({required AuthSessionManager sessionManager})
    : _sessionManager = sessionManager;

  final AuthSessionManager _sessionManager;

  String names = '';
  String lastNames = '';
  String email = '';
  String password = '';
  String confirmPassword = '';
  String institution = '';
  String phone = '';
  bool acceptedTerms = false;
  bool isLoading = false;
  String? termsError;
  String? generalError;
  Map<String, String> fieldErrors = const {};

  void setNames(String value) => names = value;
  void setLastNames(String value) => lastNames = value;
  void setEmail(String value) => email = value;
  void setPassword(String value) => password = value;
  void setConfirmPassword(String value) => confirmPassword = value;
  void setInstitution(String value) => institution = value;
  void setPhone(String value) => phone = value;

  void setAcceptedTerms(bool value) {
    acceptedTerms = value;
    if (value) {
      termsError = null;
    }
    notifyListeners();
  }

  bool validateRegister() {
    generalError = null;
    fieldErrors = const {};
    termsError = AuthValidators.validateAcceptedTerms(acceptedTerms);
    return AuthValidators.validateNames(
              names,
              'Los nombres son obligatorios.',
            ) ==
            null &&
        AuthValidators.validateNames(
              lastNames,
              'Los apellidos son obligatorios.',
            ) ==
            null &&
        AuthValidators.validateEmail(email) == null &&
        AuthValidators.validatePhone(phone) == null &&
        AuthValidators.validateMinimumPassword(password) == null &&
        AuthValidators.validateConfirmPassword(confirmPassword, password) ==
            null &&
        AuthValidators.validateRequiredField(
              institution,
              'La institución educativa es obligatoria.',
            ) ==
            null &&
        termsError == null;
  }

  Future<bool> register() async {
    if (isLoading) {
      return false;
    }
    if (!validateRegister()) {
      notifyListeners();
      return false;
    }

    isLoading = true;
    notifyListeners();

    try {
      await _sessionManager.signUp(
        RegisterRequest(
          names: names.trim(),
          lastNames: lastNames.trim(),
          email: email.trim(),
          password: password,
          confirmPassword: confirmPassword,
          institution: institution.trim(),
          phone: AuthValidators.normalizePhone(phone),
        ),
      );
      isLoading = false;
      generalError = null;
      fieldErrors = const {};
      notifyListeners();
      return true;
    } on ApiException catch (error) {
      isLoading = false;
      generalError = error.message;
      fieldErrors = error.fieldErrors;
      notifyListeners();
      return false;
    }
  }

  String get successMessage => AppStrings.registerSuccess;
}
