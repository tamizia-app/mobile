import 'package:flutter/material.dart';
import '../../../../core/theme/app_tokens.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/validators/auth_validators.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/back_header.dart';
import '../../../../core/widgets/error_message.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../domain/repositories/auth_repository.dart';
import '../viewmodels/forgot_password_viewmodel.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({required this.authRepository, super.key});

  final AuthRepository authRepository;

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
    _viewModel = ForgotPasswordViewModel(authRepository: widget.authRepository);
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
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.xl,
              AppSpacing.lg,
              AppSpacing.xxl,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: AppSizes.formWidth),
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
                        const SizedBox(height: AppSpacing.xxl),
                        const _MailIllustration(),
                        const SizedBox(height: AppSpacing.xxxl),
                        const Text(
                          AppStrings.checkEmail,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: AppFontSizes.bodyLarge,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        const Text(
                          AppStrings.forgotPasswordDescription,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.neutralGray,
                            fontSize: AppFontSizes.bodyLarge,
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        AppTextField(
                          controller: _emailController,
                          label: AppStrings.recoveryEmailLabel,
                          hintText: AppStrings.recoveryEmailHint,
                          keyboardType: TextInputType.emailAddress,
                          validator: AuthValidators.validateEmail,
                          onChanged: _viewModel.setEmail,
                        ),
                        if (_viewModel.errorMessage != null) ...[
                          const SizedBox(height: AppSpacing.md),
                          ErrorMessage(text: _viewModel.errorMessage!),
                        ],
                        const SizedBox(height: AppSpacing.xxl),
                        PrimaryButton(
                          text: AppStrings.sendRecoveryLink,
                          isLoading: _viewModel.isLoading,
                          onPressed: _submit,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        TextButton(
                          onPressed: () => Navigator.pushReplacementNamed(
                            context,
                            AppRoutes.login,
                          ),
                          child: const Text(
                            AppStrings.backToLogin,
                            style: TextStyle(
                              fontSize: AppFontSizes.body,
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
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.all(AppSpacing.xl),
    child: Icon(
      Icons.mark_email_unread_outlined,
      size: 64,
      color: AppColors.primary,
    ),
  );
}
