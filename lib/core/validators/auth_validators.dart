class AuthValidators {
  const AuthValidators._();

  static final RegExp _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return 'El correo electrónico es obligatorio.';
    }
    if (!_emailRegex.hasMatch(email)) {
      return 'Ingresa un correo electrónico válido.';
    }
    return null;
  }

  static String? validateRequiredPassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'La contraseña es obligatoria.';
    }
    return null;
  }

  static String? validateMinimumPassword(String? value) {
    final requiredError = validateRequiredPassword(value);
    if (requiredError != null) {
      return requiredError;
    }
    if (value!.length < 8) {
      return 'La contraseña debe tener mínimo 8 caracteres.';
    }
    return null;
  }

  static String? validateNames(String? value, String message) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.trim().isEmpty) {
      return 'Confirma tu contraseña.';
    }
    if (value != password) {
      return 'Las contraseñas no coinciden.';
    }
    return null;
  }

  static String? validateAcceptedTerms(bool acceptedTerms) {
    if (!acceptedTerms) {
      return 'Debes aceptar los términos y condiciones.';
    }
    return null;
  }

  static String? validateRequiredField(String? value, String message) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  }

  static String? validateAge(String? value) {
    final ageText = value?.trim() ?? '';
    if (ageText.isEmpty) {
      return 'La edad es obligatoria.';
    }
    final age = int.tryParse(ageText);
    if (age == null || age <= 0 || age > 120) {
      return 'Ingresa una edad válida.';
    }
    return null;
  }
}
