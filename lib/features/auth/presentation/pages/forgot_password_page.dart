import 'package:flutter/material.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/validators/auth_validators.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/back_header.dart';
import '../../../../core/widgets/error_message.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../data/services/auth_service.dart';
import '../viewmodels/forgot_password_viewmodel.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({required this.authService, super.key});

  final AuthService authService;

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  late final ForgotPasswordViewModel _viewModel;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel = ForgotPasswordViewModel(authService: widget.authService);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final success = await _viewModel.sendRecoveryLink();
    if (!mounted || !success) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(_viewModel.successMessage!)));
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
                child: AnimatedBuilder(
                  animation: _viewModel,
                  builder: (context, _) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const BackHeader(
                          title: AppStrings.forgotPasswordTitle,
                          outsideCard: true,
                        ),
                        const SizedBox(height: 78),
                        const _MailIllustration(),
                        const SizedBox(height: 44),
                        const Text(
                          AppStrings.checkEmail,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF102532),
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          AppStrings.forgotPasswordDescription,
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
                          label: AppStrings.recoveryEmailLabel,
                          hintText: AppStrings.recoveryEmailHint,
                          keyboardType: TextInputType.emailAddress,
                          validator: AuthValidators.validateEmail,
                          onChanged: _viewModel.setEmail,
                        ),
                        if (_viewModel.errorMessage != null) ...[
                          const SizedBox(height: 12),
                          ErrorMessage(text: _viewModel.errorMessage!),
                        ],
                        const SizedBox(height: 54),
                        PrimaryButton(
                          text: AppStrings.sendRecoveryLink,
                          isLoading: _viewModel.isLoading,
                          onPressed: _submit,
                        ),
                        const SizedBox(height: 26),
                        TextButton(
                          onPressed: () => Navigator.pushReplacementNamed(
                            context,
                            AppRoutes.login,
                          ),
                          child: const Text(
                            AppStrings.backToLogin,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
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

class _MailIllustration extends StatelessWidget {
  const _MailIllustration();

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
