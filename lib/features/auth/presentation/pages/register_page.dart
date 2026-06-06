import 'package:flutter/material.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/validators/auth_validators.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/auth_card.dart';
import '../../../../core/widgets/back_header.dart';
import '../../../../core/widgets/password_field.dart';
import '../../../../core/widgets/privacy_notice.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/terms_checkbox.dart';
import '../../../../core/widgets/text_link.dart';
import '../../data/services/auth_service.dart';
import '../viewmodels/register_viewmodel.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({required this.authService, super.key});

  final AuthService authService;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  late final RegisterViewModel _viewModel;
  final _formKey = GlobalKey<FormState>();
  final _namesController = TextEditingController();
  final _lastNamesController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _institutionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel = RegisterViewModel(authService: widget.authService);
  }

  @override
  void dispose() {
    _namesController.dispose();
    _lastNamesController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _institutionController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final formIsValid = _formKey.currentState!.validate();
    final success = await _viewModel.register();
    if (!mounted || !formIsValid || !success) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(_viewModel.successMessage)));
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
              child: AuthCard(
                borderRadius: 8,
                shadowOpacity: 0.12,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const BackHeader(title: AppStrings.registerTitle),
                    const Divider(height: 1, color: Color(0xFFE5E7EB)),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
                      child: Form(
                        key: _formKey,
                        child: AnimatedBuilder(
                          animation: _viewModel,
                          builder: (context, _) {
                            return Column(
                              children: [
                                const Text(
                                  AppStrings.registerDescription,
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
                                  label: AppStrings.namesLabel,
                                  hintText: AppStrings.namesHint,
                                  validator: (value) =>
                                      AuthValidators.validateNames(
                                        value,
                                        'Los nombres son obligatorios.',
                                      ),
                                  onChanged: _viewModel.setNames,
                                ),
                                const SizedBox(height: 14),
                                AppTextField(
                                  controller: _lastNamesController,
                                  label: AppStrings.lastNamesLabel,
                                  hintText: AppStrings.lastNamesHint,
                                  validator: (value) =>
                                      AuthValidators.validateNames(
                                        value,
                                        'Los apellidos son obligatorios.',
                                      ),
                                  onChanged: _viewModel.setLastNames,
                                ),
                                const SizedBox(height: 14),
                                AppTextField(
                                  controller: _emailController,
                                  label: AppStrings.institutionalEmailLabel,
                                  hintText: AppStrings.institutionalEmailHint,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: AuthValidators.validateEmail,
                                  onChanged: _viewModel.setEmail,
                                ),
                                const SizedBox(height: 14),
                                PasswordField(
                                  controller: _passwordController,
                                  label: AppStrings.passwordRequiredLabel,
                                  hintText: AppStrings.passwordMinHint,
                                  validator:
                                      AuthValidators.validateMinimumPassword,
                                  onChanged: _viewModel.setPassword,
                                ),
                                const SizedBox(height: 14),
                                PasswordField(
                                  controller: _confirmPasswordController,
                                  label: AppStrings.confirmPasswordLabel,
                                  hintText: AppStrings.confirmPasswordHint,
                                  validator: (value) =>
                                      AuthValidators.validateConfirmPassword(
                                        value,
                                        _passwordController.text,
                                      ),
                                  onChanged: _viewModel.setConfirmPassword,
                                ),
                                const SizedBox(height: 14),
                                AppTextField(
                                  controller: _institutionController,
                                  label: AppStrings.institutionLabel,
                                  hintText: AppStrings.institutionHint,
                                  onChanged: _viewModel.setInstitution,
                                ),
                                const SizedBox(height: 16),
                                TermsCheckbox(
                                  value: _viewModel.acceptedTerms,
                                  errorText: _viewModel.errorMessage,
                                  onChanged: (value) => _viewModel
                                      .setAcceptedTerms(value ?? false),
                                ),
                                const SizedBox(height: 14),
                                const PrivacyNotice(),
                                const SizedBox(height: 28),
                                PrimaryButton(
                                  text: AppStrings.registerButton,
                                  isLoading: _viewModel.isLoading,
                                  onPressed: _submit,
                                ),
                                const SizedBox(height: 20),
                                Wrap(
                                  alignment: WrapAlignment.center,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    const Text(
                                      AppStrings.alreadyHaveAccount,
                                      style: TextStyle(
                                        color: AppColors.neutralGray,
                                        fontSize: 12,
                                      ),
                                    ),
                                    TextLink(
                                      text: AppStrings.loginHere,
                                      fontSize: 12,
                                      onTap: () =>
                                          Navigator.pushReplacementNamed(
                                            context,
                                            AppRoutes.login,
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
