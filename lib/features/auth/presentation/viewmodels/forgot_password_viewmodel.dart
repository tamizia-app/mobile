import 'package:flutter/foundation.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/validators/auth_validators.dart';
import '../../data/services/auth_service.dart';
import '../../domain/models/forgot_password_request.dart';

class ForgotPasswordViewModel extends ChangeNotifier {
  ForgotPasswordViewModel({required AuthService authService})
    : _authService = authService;

  final AuthService _authService;

  String email = '';
  bool isLoading = false;
  String? successMessage;
  String? errorMessage;

  void setEmail(String value) {
    email = value;
  }

  bool validateEmail() {
    errorMessage = AuthValidators.validateEmail(email);
    successMessage = null;
    return errorMessage == null;
  }

  Future<bool> sendRecoveryLink() async {
    if (!validateEmail()) {
      notifyListeners();
      return false;
    }

    isLoading = true;
    notifyListeners();

    final success = await _authService.sendPasswordRecovery(
      ForgotPasswordRequest(email: email.trim()),
    );

    isLoading = false;
    successMessage = success ? AppStrings.forgotPasswordSuccess : null;
    errorMessage = success ? null : 'No se pudo enviar el enlace.';
    notifyListeners();
    return success;
  }
}
