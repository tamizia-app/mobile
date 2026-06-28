import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/validators/auth_validators.dart';
import '../../domain/repositories/auth_repository.dart';

class ResetPasswordViewModel extends ChangeNotifier {
  ResetPasswordViewModel({
    required AuthRepository authRepository,
    required this.token,
  }) : _authRepository = authRepository;

  final AuthRepository _authRepository;
  final String token;

  String newPassword = '';
  String confirmPassword = '';
  bool isLoading = false;
  String? errorMessage;

  void setNewPassword(String value) => newPassword = value;
  void setConfirmPassword(String value) => confirmPassword = value;

  String? validateToken() {
    if (token.trim().isEmpty) {
      return 'El enlace de recuperacion no contiene un token valido.';
    }
    return null;
  }

  bool validate() {
    errorMessage =
        validateToken() ??
        AuthValidators.validateMinimumPassword(newPassword) ??
        AuthValidators.validateConfirmPassword(confirmPassword, newPassword);
    return errorMessage == null;
  }

  Future<bool> resetPassword() async {
    if (isLoading) {
      return false;
    }
    if (!validate()) {
      notifyListeners();
      return false;
    }

    isLoading = true;
    notifyListeners();
    try {
      await _authRepository.resetPassword(
        token: token,
        newPassword: newPassword,
      );
      newPassword = '';
      confirmPassword = '';
      errorMessage = null;
      return true;
    } on ApiException catch (error) {
      errorMessage = error.message;
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
