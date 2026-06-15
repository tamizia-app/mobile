import 'package:flutter/foundation.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/validators/auth_validators.dart';
import '../../data/services/auth_service.dart';
import '../../domain/models/login_request.dart';

class LoginViewModel extends ChangeNotifier {
  LoginViewModel({required AuthService authService})
    : _authService = authService;

  final AuthService _authService;

  String email = '';
  String password = 'password123';
  bool isLoading = false;
  String? errorMessage;

  void setEmail(String value) {
    email = value;
  }

  void setPassword(String value) {
    password = value;
  }

  bool validateLogin() {
    errorMessage = null;
    final emailError = AuthValidators.validateEmail(email);
    final passwordError = AuthValidators.validateRequiredPassword(password);
    if (emailError != null || passwordError != null) {
      return false;
    }
    return true;
  }

  Future<bool> login() async {
    if (!validateLogin()) {
      notifyListeners();
      return false;
    }

    isLoading = true;
    notifyListeners();

    final success = await _authService.login(
      LoginRequest(email: email.trim(), password: password),
    );

    isLoading = false;
    errorMessage = success
        ? null
        : 'La contraseña ingresada no es correcta. Por favor, inténtalo de nuevo.';
    notifyListeners();
    return success;
  }

  String get successMessage => AppStrings.loginSuccess;
}
