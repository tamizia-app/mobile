import 'package:flutter/foundation.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/validators/auth_validators.dart';
import '../../domain/repositories/auth_repository.dart';

class ForgotPasswordViewModel extends ChangeNotifier {
  ForgotPasswordViewModel({required AuthRepository authRepository})
    : _authRepository = authRepository;

  final AuthRepository _authRepository;

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
    if (isLoading) {
      return false;
    }
    if (!validateEmail()) {
      notifyListeners();
      return false;
    }

    isLoading = true;
    notifyListeners();
    try {
      await _authRepository.forgotPassword(email.trim());
      successMessage = AppStrings.forgotPasswordSuccess;
      errorMessage = null;
      return true;
    } on ApiException catch (error) {
      errorMessage = error.message;
      successMessage = null;
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
