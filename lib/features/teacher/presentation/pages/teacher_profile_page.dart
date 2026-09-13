import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/session/auth_session_manager.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/validators/auth_validators.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../viewmodels/teacher_profile_viewmodel.dart';

class TeacherProfilePage extends StatefulWidget {
  const TeacherProfilePage({required this.sessionManager, super.key});

  final AuthSessionManager sessionManager;

  @override
  State<TeacherProfilePage> createState() => _TeacherProfilePageState();
}

class _TeacherProfilePageState extends State<TeacherProfilePage> {
  late final TeacherProfileViewModel _viewModel;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _institutionController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel = TeacherProfileViewModel(
      sessionManager: widget.sessionManager,
    );
    _viewModel.addListener(_syncControllers);
    _viewModel.load();
  }

  @override
  void dispose() {
    _viewModel.removeListener(_syncControllers);
    _viewModel.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _institutionController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _syncControllers() {
    _setText(_firstNameController, _viewModel.firstName);
    _setText(_lastNameController, _viewModel.lastName);
    _setText(_emailController, _viewModel.email);
    _setText(_institutionController, _viewModel.institution);
    _setText(_phoneController, _viewModel.phone);
  }

  void _setText(TextEditingController controller, String value) {
    if (controller.text == value) return;
    controller.text = value;
    controller.selection = TextSelection.collapsed(offset: value.length);
  }

  Future<void> _save() async {
    if (!_viewModel.canSave || !(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final saved = await _viewModel.save();
    if (!mounted || !saved) {
      return;
    }
    setState(() {
      _formKey = GlobalKey<FormState>();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perfil actualizado correctamente.')),
    );
  }

  void _cancel() {
    FocusScope.of(context).unfocus();
    _viewModel.restore();
    setState(() {
      _formKey = GlobalKey<FormState>();
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Datos restaurados')));
  }

  Future<void> _signOut() async {
    await _viewModel.signOut();
    if (!mounted) {
      return;
    }
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.teacherBackground,
          bottomNavigationBar: const AppBottomNav(
            currentItem: BottomNavItem.profile,
          ),
          body: Column(
            children: [
              AppHeader(
                title: 'Perfil del docente',
                showBack: true,
                centerTitle: true,
                onBack: () => Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.teacherHome,
                ),
              ),
              Expanded(
                child: !_viewModel.isInitialized
                    ? _ProfileLoadingState(
                        isLoading: _viewModel.isLoading,
                        errorMessage: _viewModel.errorMessage,
                        onRetry: _viewModel.load,
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(26, 32, 26, 28),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  Container(
                                    width: 128,
                                    height: 128,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(0xFFD6F1FF),
                                        width: 4,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.person,
                                      color: Color(0xFF35424F),
                                      size: 78,
                                    ),
                                  ),
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: AppColors.primaryBlue,
                                    child: const Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Text(
                                _viewModel.currentProfile?.fullName ?? '',
                                style: const TextStyle(
                                  color: Color(0xFF102532),
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _viewModel.currentProfile?.email ?? '',
                                style: const TextStyle(
                                  color: AppColors.neutralGray,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _viewModel.currentProfile?.instituteName ?? '',
                                style: const TextStyle(
                                  color: AppColors.neutralGray,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 70),
                              AppTextField(
                                controller: _firstNameController,
                                label: 'Nombres',
                                hintText: 'Juan',
                                validator: (value) =>
                                    AuthValidators.validateRequiredField(
                                      value,
                                      'Los nombres son obligatorios.',
                                    ),
                                onChanged: _viewModel.setFirstName,
                              ),
                              const SizedBox(height: 18),
                              AppTextField(
                                controller: _lastNameController,
                                label: 'Apellidos',
                                hintText: 'Pérez',
                                validator: (value) =>
                                    AuthValidators.validateRequiredField(
                                      value,
                                      'Los apellidos son obligatorios.',
                                    ),
                                onChanged: _viewModel.setLastName,
                              ),
                              const SizedBox(height: 18),
                              AppTextField(
                                controller: _emailController,
                                label: 'Correo electrónico',
                                hintText: 'juan.perez@email.com',
                                keyboardType: TextInputType.emailAddress,
                                validator: AuthValidators.validateEmail,
                                onChanged: _viewModel.setEmail,
                              ),
                              const SizedBox(height: 18),
                              AppTextField(
                                controller: _institutionController,
                                label: 'Institución educativa',
                                hintText: 'Institución educativa XYZ',
                                validator: (value) =>
                                    AuthValidators.validateRequiredField(
                                      value,
                                      'La institución educativa es obligatoria.',
                                    ),
                                onChanged: _viewModel.setInstitution,
                              ),
                              const SizedBox(height: 18),
                              AppTextField(
                                controller: _phoneController,
                                label: 'Teléfono',
                                hintText: '987654321',
                                keyboardType: TextInputType.phone,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9+\-()\s]'),
                                  ),
                                ],
                                validator: AuthValidators.validatePhone,
                                onChanged: _viewModel.setPhone,
                              ),
                              if (_viewModel.errorMessage != null) ...[
                                const SizedBox(height: 12),
                                Text(
                                  _viewModel.errorMessage!,
                                  style: const TextStyle(
                                    color: AppColors.errorRed,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: _viewModel.isLoading
                                          ? null
                                          : _cancel,
                                      style: OutlinedButton.styleFrom(
                                        fixedSize: const Size.fromHeight(48),
                                        foregroundColor: const Color(
                                          0xFF102532,
                                        ),
                                        side: const BorderSide(
                                          color: Color(0xFF697789),
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            7,
                                          ),
                                        ),
                                      ),
                                      child: const Text('Cancelar'),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: PrimaryButton(
                                      text: 'Guardar cambios',
                                      isLoading: _viewModel.isLoading,
                                      onPressed: _viewModel.canSave
                                          ? _save
                                          : null,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 26),
                              TextButton.icon(
                                onPressed: _viewModel.isSigningOut
                                    ? null
                                    : _signOut,
                                icon: const Icon(Icons.logout, size: 18),
                                label: const Text('Cerrar sesión'),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.errorRed,
                                  textStyle: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProfileLoadingState extends StatelessWidget {
  const _ProfileLoadingState({
    required this.isLoading,
    required this.errorMessage,
    required this.onRetry,
  });

  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              errorMessage ?? 'No se pudo cargar el perfil.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.errorRed),
            ),
            const SizedBox(height: 12),
            TextButton(onPressed: onRetry, child: const Text('Reintentar')),
          ],
        ),
      ),
    );
  }
}
