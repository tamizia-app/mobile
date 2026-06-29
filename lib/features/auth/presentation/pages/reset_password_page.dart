import 'package:flutter/material.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/validators/auth_validators.dart';
import '../../../../core/widgets/back_header.dart';
import '../../../../core/widgets/error_message.dart';
import '../../../../core/widgets/password_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../domain/repositories/auth_repository.dart';
import '../viewmodels/reset_password_viewmodel.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({
    required this.authRepository,
    required this.token,
    super.key,
  });

  final AuthRepository authRepository;
  final String token;

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  late final ResetPasswordViewModel _viewModel;
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel = ResetPasswordViewModel(
      authRepository: widget.authRepository,
      token: widget.token,
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmationController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final success = await _viewModel.resetPassword();
    if (!mounted || !success) {
      return;
    }
    _passwordController.clear();
    _confirmationController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Contrasena restablecida correctamente.')),
    );
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 390),
              child: Form(
                key: _formKey,
                child: AnimatedBuilder(
                  animation: _viewModel,
                  builder: (context, _) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const BackHeader(
                          title: 'Restablecer contrasena',
                          outsideCard: true,
                        ),
                        const SizedBox(height: 64),
                        const Icon(
                          Icons.lock_reset_rounded,
                          size: 92,
                          color: AppColors.primaryBlue,
                        ),
                        const SizedBox(height: 32),
                        PasswordField(
                          controller: _passwordController,
                          label: 'Nueva contrasena',
                          hintText: 'Minimo 8 caracteres',
                          validator: AuthValidators.validateMinimumPassword,
                          onChanged: _viewModel.setNewPassword,
                        ),
                        const SizedBox(height: 18),
                        PasswordField(
                          controller: _confirmationController,
                          label: 'Confirmar nueva contrasena',
                          hintText: 'Repite tu contrasena',
                          validator: (value) =>
                              AuthValidators.validateConfirmPassword(
                                value,
                                _viewModel.newPassword,
                              ),
                          onChanged: _viewModel.setConfirmPassword,
                        ),
                        if (_viewModel.errorMessage != null) ...[
                          const SizedBox(height: 12),
                          ErrorMessage(text: _viewModel.errorMessage!),
                        ],
                        const SizedBox(height: 32),
                        PrimaryButton(
                          text: 'Restablecer contrasena',
                          isLoading: _viewModel.isLoading,
                          onPressed: _submit,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
