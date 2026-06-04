import 'package:flutter/material.dart';

void main() {
  runApp(const TamizAIApp());
}

class TamizAIApp extends StatelessWidget {
  const TamizAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TamizAI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryBlue,
          primary: AppColors.primaryBlue,
        ),
        fontFamily: 'Inter',
        scaffoldBackgroundColor: AppColors.backgroundLight,
        useMaterial3: true,
      ),
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (_) => const SplashScreen(),
        AppRoutes.login: (_) => const LoginScreen(),
        AppRoutes.register: (_) => const RegisterScreen(),
        AppRoutes.forgotPassword: (_) => const ForgotPasswordScreen(),
      },
    );
  }
}

class AppRoutes {
  static const splash = '/splash';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
}

class AppColors {
  static const primaryBlue = Color(0xFF0056B3);
  static const secondaryOrange = Color(0xFFEC5B13);
  static const neutralDark = Color(0xFF221610);
  static const neutralGray = Color(0xFF4B5563);
  static const backgroundLight = Color(0xFFF3F7FB);
  static const surfaceWhite = Color(0xFFFFFFFF);
  static const borderGray = Color(0xFFD1D5DB);
  static const mutedText = Color(0xFF6B7280);
  static const errorRed = Color(0xFFDC2626);
  static const privacyBackground = Color(0xFFFFF7ED);
  static const infoBlueLight = Color(0xFFEFF6FF);
}

final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 4),
              Container(
                width: 198,
                height: 198,
                decoration: BoxDecoration(
                  color: AppColors.surfaceWhite,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.secondaryOrange.withValues(alpha: 0.18),
                    width: 4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.10),
                      blurRadius: 26,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child: Center(
                  child: SizedBox(
                    width: 96,
                    height: 84,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          Icons.menu_book_rounded,
                          color: const Color(0xFF334B67),
                          size: 78,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 3,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        Positioned(
                          right: 12,
                          top: 10,
                          child: Icon(
                            Icons.search_rounded,
                            color: const Color(0xFF226F98),
                            size: 42,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.20),
                                blurRadius: 2,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 34),
              const Text(
                'TamizAI',
                style: TextStyle(
                  color: AppColors.neutralDark,
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Apoyo al tamizaje temprano de\ndificultades de lectoescritura',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF4A403C),
                  fontSize: 19,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 36),
              PrimaryButton(
                text: 'Comenzar',
                icon: Icons.arrow_forward_rounded,
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, AppRoutes.login),
              ),
              const Spacer(flex: 5),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController(text: 'password123');
  final _formKey = GlobalKey<FormState>();
  String? _simulatedError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    setState(() => _simulatedError = null);
    if (!_formKey.currentState!.validate()) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Inicio de sesión simulado correctamente.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 390),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(26, 34, 26, 32),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            const CircleIcon(
                              icon: Icons.school_rounded,
                              size: 66,
                              iconSize: 34,
                            ),
                            const SizedBox(height: 18),
                            const Text(
                              'TamizAI',
                              style: TextStyle(
                                color: AppColors.neutralDark,
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Iniciar sesión',
                              style: TextStyle(
                                color: AppColors.mutedText,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 22),
                            AppTextField(
                              controller: _emailController,
                              label: 'Email',
                              hintText: 'ejemplo@escuela.edu',
                              keyboardType: TextInputType.emailAddress,
                              validator: _validateEmail,
                            ),
                            const SizedBox(height: 18),
                            PasswordField(
                              controller: _passwordController,
                              label: 'Contraseña',
                              hintText: 'password123',
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'La contraseña es obligatoria.';
                                }
                                return null;
                              },
                            ),
                            if (_simulatedError != null) ...[
                              const SizedBox(height: 12),
                              ErrorMessage(text: _simulatedError!),
                            ],
                            const SizedBox(height: 28),
                            PrimaryButton(
                              text: 'Iniciar sesión',
                              onPressed: _submit,
                            ),
                            const SizedBox(height: 22),
                            TextButton(
                              onPressed: () => Navigator.pushNamed(
                                context,
                                AppRoutes.forgotPassword,
                              ),
                              child: const Text('¿Olvidaste tu contraseña?'),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                const Text(
                                  '¿No tienes cuenta? ',
                                  style: TextStyle(
                                    color: AppColors.neutralGray,
                                    fontSize: 14,
                                  ),
                                ),
                                TextLink(
                                  text: 'Crear cuenta docente',
                                  onTap: () => Navigator.pushNamed(
                                    context,
                                    AppRoutes.register,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 14,
                      ),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFBFCFE),
                        border: Border(
                          top: BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(10),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shield_outlined,
                            color: Color(0xFF94A3B8),
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'Tus datos y los de tus estudiantes serán protegidos',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.mutedText,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namesController = TextEditingController();
  final _lastNamesController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _institutionController = TextEditingController();
  bool _acceptedTerms = false;
  bool _showTermsError = false;

  @override
  void dispose() {
    _namesController.dispose();
    _lastNamesController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _institutionController.dispose();
    super.dispose();
  }

  void _submit() {
    setState(() => _showTermsError = !_acceptedTerms);
    if (!_formKey.currentState!.validate() || !_acceptedTerms) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Registro simulado correctamente.')),
    );
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 390),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const BackHeader(title: 'Crear cuenta docente'),
                    const Divider(height: 1, color: Color(0xFFE5E7EB)),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            const Text(
                              'Únete a TamizAI para gestionar la evaluación\ny progreso de tus estudiantes.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.neutralGray,
                                fontSize: 13,
                                height: 1.45,
                              ),
                            ),
                            const SizedBox(height: 18),
                            AppTextField(
                              controller: _namesController,
                              label: 'Nombres *',
                              hintText: 'Ingresa tus nombres',
                              validator: (value) => _required(
                                value,
                                'Los nombres son obligatorios.',
                              ),
                            ),
                            const SizedBox(height: 14),
                            AppTextField(
                              controller: _lastNamesController,
                              label: 'Apellidos *',
                              hintText: 'Ingresa tus apellidos',
                              validator: (value) => _required(
                                value,
                                'Los apellidos son obligatorios.',
                              ),
                            ),
                            const SizedBox(height: 14),
                            AppTextField(
                              controller: _emailController,
                              label: 'Correo Electrónico *',
                              hintText: 'ejemplo@institucion.edu',
                              keyboardType: TextInputType.emailAddress,
                              validator: _validateEmail,
                            ),
                            const SizedBox(height: 14),
                            PasswordField(
                              controller: _passwordController,
                              label: 'Contraseña *',
                              hintText: 'Mínimo 8 caracteres',
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'La contraseña es obligatoria.';
                                }
                                if (value.length < 8) {
                                  return 'La contraseña debe tener mínimo 8 caracteres.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                            PasswordField(
                              controller: _confirmPasswordController,
                              label: 'Confirmar Contraseña *',
                              hintText: 'Repite tu contraseña',
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Confirma tu contraseña.';
                                }
                                if (value != _passwordController.text) {
                                  return 'Las contraseñas no coinciden.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                            AppTextField(
                              controller: _institutionController,
                              label: 'Institución Educativa (Opcional)',
                              hintText: 'Nombre de la escuela o colegio',
                            ),
                            const SizedBox(height: 16),
                            TermsCheckbox(
                              value: _acceptedTerms,
                              showError: _showTermsError,
                              onChanged: (value) {
                                setState(() {
                                  _acceptedTerms = value ?? false;
                                  _showTermsError = false;
                                });
                              },
                            ),
                            const SizedBox(height: 14),
                            const PrivacyNotice(),
                            const SizedBox(height: 28),
                            PrimaryButton(
                              text: 'Registrarme',
                              onPressed: _submit,
                            ),
                            const SizedBox(height: 20),
                            Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                const Text(
                                  '¿Ya tienes una cuenta? ',
                                  style: TextStyle(
                                    color: AppColors.neutralGray,
                                    fontSize: 12,
                                  ),
                                ),
                                TextLink(
                                  text: 'Inicia sesión aquí',
                                  fontSize: 12,
                                  onTap: () => Navigator.pushReplacementNamed(
                                    context,
                                    AppRoutes.login,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Si el correo existe, enviaremos un enlace de recuperación.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 390),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const BackHeader(
                      title: 'Recuperar contraseña',
                      outsideCard: true,
                    ),
                    const SizedBox(height: 78),
                    const MailIllustration(),
                    const SizedBox(height: 44),
                    const Text(
                      'Revisa tu correo',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF102532),
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Si el correo electrónico coincide con una\ncuenta existente, recibirás un enlace seguro\npara restablecer tu acceso al sistema.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.neutralGray,
                        fontSize: 17,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 52),
                    AppTextField(
                      controller: _emailController,
                      label: 'Correo electrónico institucional',
                      hintText: 'docente@escuela.edu',
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
                    ),
                    const SizedBox(height: 54),
                    PrimaryButton(
                      text: 'Enviar enlace de recuperación',
                      onPressed: _submit,
                    ),
                    const SizedBox(height: 26),
                    TextButton(
                      onPressed: () => Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.login,
                      ),
                      child: const Text(
                        'Volver al inicio de sesión',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.text,
    required this.onPressed,
    this.icon,
    super.key,
  });

  final String text;
  final IconData? icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: FittedBox(fit: BoxFit.scaleDown, child: Text(text)),
            ),
            if (icon != null) ...[
              const SizedBox(width: 8),
              Icon(icon, size: 22),
            ],
          ],
        ),
      ),
    );
  }
}

class AppTextField extends StatelessWidget {
  const AppTextField({
    required this.controller,
    required this.label,
    required this.hintText,
    this.keyboardType,
    this.validator,
    this.obscureText = false,
    this.suffixIcon,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final String hintText;
  final TextInputType? keyboardType;
  final FormFieldValidator<String>? validator;
  final bool obscureText;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    final labelParts = label.split('*');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: const TextStyle(
              color: Color(0xFF374151),
              fontSize: 13,
              fontWeight: FontWeight.w500,
              letterSpacing: 0,
            ),
            children: [
              TextSpan(text: labelParts.first),
              if (label.contains('*'))
                const TextSpan(
                  text: '*',
                  style: TextStyle(color: AppColors.errorRed),
                ),
              if (labelParts.length > 1 && labelParts.last.isNotEmpty)
                TextSpan(text: labelParts.last),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          obscureText: obscureText,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          style: const TextStyle(
            color: AppColors.neutralDark,
            fontSize: 16,
            letterSpacing: 0,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 16),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: const Color(0xFFFCFDFF),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 15,
            ),
            enabledBorder: _inputBorder(AppColors.borderGray),
            focusedBorder: _inputBorder(AppColors.primaryBlue, width: 1.5),
            errorBorder: _inputBorder(AppColors.errorRed),
            focusedErrorBorder: _inputBorder(AppColors.errorRed, width: 1.5),
            errorStyle: const TextStyle(
              color: AppColors.errorRed,
              fontSize: 11,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}

class PasswordField extends StatefulWidget {
  const PasswordField({
    required this.controller,
    required this.label,
    required this.hintText,
    this.validator,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final String hintText;
  final FormFieldValidator<String>? validator;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: widget.controller,
      label: widget.label,
      hintText: widget.hintText,
      obscureText: _obscured,
      validator: widget.validator,
      suffixIcon: IconButton(
        tooltip: _obscured ? 'Mostrar contraseña' : 'Ocultar contraseña',
        onPressed: () => setState(() => _obscured = !_obscured),
        icon: Icon(
          _obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: Color(0xFF9CA3AF),
          size: 20,
        ),
      ),
    );
  }
}

class BackHeader extends StatelessWidget {
  const BackHeader({required this.title, this.outsideCard = false, super.key});

  final String title;
  final bool outsideCard;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: outsideCard ? 40 : 56,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: outsideCard
                  ? const Color(0xFF102532)
                  : const Color(0xFF1F2937),
              fontSize: outsideCard ? 19 : 18,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              tooltip: 'Volver',
              icon: Icon(
                Icons.arrow_back,
                color: outsideCard
                    ? const Color(0xFF0F2A36)
                    : const Color(0xFF4B5563),
                size: outsideCard ? 28 : 22,
              ),
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, AppRoutes.login),
            ),
          ),
        ],
      ),
    );
  }
}

class CircleIcon extends StatelessWidget {
  const CircleIcon({
    required this.icon,
    this.size = 64,
    this.iconSize = 32,
    super.key,
  });

  final IconData icon;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.infoBlueLight,
      ),
      child: Icon(icon, color: AppColors.primaryBlue, size: iconSize),
    );
  }
}

class ErrorMessage extends StatelessWidget {
  const ErrorMessage({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.error_outline, color: AppColors.errorRed, size: 16),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.errorRed,
              fontSize: 13,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}

class TermsCheckbox extends StatelessWidget {
  const TermsCheckbox({
    required this.value,
    required this.onChanged,
    required this.showError,
    super.key,
  });

  final bool value;
  final bool showError;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: Checkbox(
                value: value,
                onChanged: onChanged,
                activeColor: AppColors.primaryBlue,
                side: const BorderSide(color: AppColors.borderGray),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: RichText(
                text: const TextSpan(
                  style: TextStyle(
                    color: AppColors.neutralGray,
                    fontSize: 12,
                    height: 1.35,
                  ),
                  children: [
                    TextSpan(text: 'Acepto los '),
                    TextSpan(
                      text: 'Términos y Condiciones',
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextSpan(text: ' y la\n'),
                    TextSpan(
                      text: 'Política de Privacidad.',
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (showError) ...[
          const SizedBox(height: 6),
          const Text(
            'Debes aceptar los términos y condiciones.',
            style: TextStyle(color: AppColors.errorRed, fontSize: 11),
          ),
        ],
      ],
    );
  }
}

class PrivacyNotice extends StatelessWidget {
  const PrivacyNotice({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.privacyBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFED7AA)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.shield, color: AppColors.primaryBlue, size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Tus datos y los de tus estudiantes son tratados de manera confidencial y se utilizan exclusivamente para fines de gestión pedagógica dentro de TamizAI.',
              style: TextStyle(
                color: AppColors.neutralGray,
                fontSize: 11,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MailIllustration extends StatelessWidget {
  const MailIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 192,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF45BBDD), Color(0xFF17657D)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0E7490).withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 132,
              height: 90,
              decoration: BoxDecoration(
                color: const Color(0xFF67D3F3),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.28),
                    blurRadius: 14,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -30),
              child: Transform.rotate(
                angle: 0.78,
                child: Container(
                  width: 82,
                  height: 82,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const Icon(Icons.mail_rounded, color: Color(0xFF37AED0), size: 148),
          ],
        ),
      ),
    );
  }
}

class TextLink extends StatelessWidget {
  const TextLink({
    required this.text,
    required this.onTap,
    this.fontSize = 14,
    super.key,
  });

  final String text;
  final VoidCallback onTap;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(4),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          text,
          style: TextStyle(
            color: AppColors.primaryBlue,
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

String? _validateEmail(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'El correo electrónico es obligatorio.';
  }
  if (!_emailRegex.hasMatch(value.trim())) {
    return 'Ingresa un correo electrónico válido.';
  }
  return null;
}

String? _required(String? value, String message) {
  if (value == null || value.trim().isEmpty) {
    return message;
  }
  return null;
}

OutlineInputBorder _inputBorder(Color color, {double width = 1}) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: color, width: width),
  );
}
