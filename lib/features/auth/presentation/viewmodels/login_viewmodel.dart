import 'package:flutter/foundation.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/session/auth_session_manager.dart';
import '../../../../core/validators/auth_validators.dart';

class LoginViewModel extends ChangeNotifier {
  LoginViewModel({required AuthSessionManager sessionManager})
    : _sessionManager = sessionManager;

  final AuthSessionManager _sessionManager;

  String email = '';
  String password = '';
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
    if (isLoading) {
      return false;
    }
    if (!validateLogin()) {
      notifyListeners();
      return false;
    }

    isLoading = true;
    notifyListeners();

    try {
      await _sessionManager.signIn(email.trim(), password);
      isLoading = false;
      errorMessage = null;
      notifyListeners();
      return true;
    } on ApiException catch (error) {
      isLoading = false;
      errorMessage = error.message;
      notifyListeners();
      return false;
    }
  }

  String get successMessage => AppStrings.loginSuccess;
}
