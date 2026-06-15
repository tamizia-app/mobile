import 'package:flutter/foundation.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/validators/auth_validators.dart';
import '../../data/services/auth_service.dart';
import '../../domain/models/register_request.dart';

class RegisterViewModel extends ChangeNotifier {
  RegisterViewModel({required AuthService authService})
    : _authService = authService;

  final AuthService _authService;

  String names = '';
  String lastNames = '';
  String email = '';
  String password = '';
  String confirmPassword = '';
  String institution = '';
  bool acceptedTerms = false;
  bool isLoading = false;
  String? errorMessage;

  void setNames(String value) => names = value;
  void setLastNames(String value) => lastNames = value;
  void setEmail(String value) => email = value;
  void setPassword(String value) => password = value;
  void setConfirmPassword(String value) => confirmPassword = value;
  void setInstitution(String value) => institution = value;

  void setAcceptedTerms(bool value) {
    acceptedTerms = value;
    if (value) {
      errorMessage = null;
    }
    notifyListeners();
  }

  bool validateRegister() {
    errorMessage = AuthValidators.validateAcceptedTerms(acceptedTerms);
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
        AuthValidators.validateMinimumPassword(password) == null &&
        AuthValidators.validateConfirmPassword(confirmPassword, password) ==
            null &&
        errorMessage == null;
  }

  Future<bool> register() async {
    if (!validateRegister()) {
      notifyListeners();
      return false;
    }

    isLoading = true;
    notifyListeners();

    final success = await _authService.register(
      RegisterRequest(
        names: names.trim(),
        lastNames: lastNames.trim(),
        email: email.trim(),
        password: password,
        confirmPassword: confirmPassword,
        institution: institution.trim(),
      ),
    );

    isLoading = false;
    errorMessage = success ? null : 'No se pudo completar el registro.';
    notifyListeners();
    return success;
  }

  String get successMessage => AppStrings.registerSuccess;
}
