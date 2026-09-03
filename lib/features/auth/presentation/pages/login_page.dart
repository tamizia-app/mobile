import 'package:flutter/material.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/session/auth_session_manager.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/validators/auth_validators.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/auth_card.dart';
import '../../../../core/widgets/circle_icon.dart';
import '../../../../core/widgets/error_message.dart';
import '../../../../core/widgets/password_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/text_link.dart';
import '../viewmodels/login_viewmodel.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({required this.sessionManager, super.key});

  final AuthSessionManager sessionManager;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final LoginViewModel _viewModel;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _viewModel = LoginViewModel(sessionManager: widget.sessionManager);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_viewModel.isLoading) {
      return;
    }
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final success = await _viewModel.login();
    if (!mounted || !success) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(_viewModel.successMessage)));
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.teacherHome,
      (route) => false,
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
              child: AuthCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(26, 34, 26, 32),
                      child: Form(
                        key: _formKey,
                        child: AnimatedBuilder(
                          animation: _viewModel,
                          builder: (context, _) {
                            return Column(
                              children: [
                                const CircleIcon(
                                  icon: Icons.school_rounded,
                                  size: 66,
                                  iconSize: 34,
                                ),
                                const SizedBox(height: 18),
                                const Text(
                                  AppStrings.loginTitle,
                                  style: AppTextStyles.appTitle,
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  AppStrings.loginSubtitle,
                                  style: TextStyle(
                                    color: AppColors.mutedText,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 22),
                                AppTextField(
                                  controller: _emailController,
                                  label: AppStrings.emailLabel,
                                  hintText: AppStrings.emailHint,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: AuthValidators.validateEmail,
                                  onChanged: _viewModel.setEmail,
                                ),
                                const SizedBox(height: 18),
                                PasswordField(
                                  controller: _passwordController,
                                  label: AppStrings.passwordLabel,
                                  hintText: AppStrings.passwordHint,
                                  validator:
                                      AuthValidators.validateRequiredPassword,
                                  onChanged: _viewModel.setPassword,
                                ),
                                if (_viewModel.errorMessage != null) ...[
                                  const SizedBox(height: 12),
                                  ErrorMessage(text: _viewModel.errorMessage!),
                                ],
                                const SizedBox(height: 28),
                                PrimaryButton(
                                  text: AppStrings.loginButton,
                                  isLoading: _viewModel.isLoading,
                                  onPressed: _submit,
                                ),
                                const SizedBox(height: 22),
                                TextButton(
                                  onPressed: () => Navigator.pushNamed(
                                    context,
                                    AppRoutes.forgotPassword,
                                  ),
                                  child: const Text(
                                    AppStrings.forgotPasswordLink,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  alignment: WrapAlignment.center,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    const Text(
                                      AppStrings.noAccount,
                                      style: TextStyle(
                                        color: AppColors.neutralGray,
                                        fontSize: 14,
                                      ),
                                    ),
                                    TextLink(
                                      text: AppStrings.createTeacherAccount,
                                      onTap: () => Navigator.pushNamed(
                                        context,
                                        AppRoutes.register,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
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
                              AppStrings.loginPrivacy,
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
