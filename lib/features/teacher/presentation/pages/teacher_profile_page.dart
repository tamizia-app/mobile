import 'package:flutter/material.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/validators/auth_validators.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../data/services/teacher_service.dart';
import '../viewmodels/teacher_profile_viewmodel.dart';

class TeacherProfilePage extends StatefulWidget {
  const TeacherProfilePage({required this.teacherService, super.key});

  final TeacherService teacherService;

  @override
  State<TeacherProfilePage> createState() => _TeacherProfilePageState();
}

class _TeacherProfilePageState extends State<TeacherProfilePage> {
  late final TeacherProfileViewModel _viewModel;
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _institutionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel = TeacherProfileViewModel(teacherService: widget.teacherService)
      ..addListener(_syncControllers)
      ..load();
  }

  @override
  void dispose() {
    _viewModel.removeListener(_syncControllers);
    _viewModel.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _institutionController.dispose();
    super.dispose();
  }

  void _syncControllers() {
    _setText(_firstNameController, _viewModel.firstName);
    _setText(_lastNameController, _viewModel.lastName);
    _setText(_emailController, _viewModel.email);
    _setText(_institutionController, _viewModel.institution);
  }

  void _setText(TextEditingController controller, String value) {
    if (controller.text == value) return;
    controller.text = value;
    controller.selection = TextSelection.collapsed(offset: value.length);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final saved = await _viewModel.save();
    if (!mounted || !saved) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cambios guardados correctamente')),
    );
  }

  void _cancel() {
    _viewModel.restore();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Datos restaurados')));
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
                title: 'Perfil del Docente',
                showBack: true,
                centerTitle: true,
                onBack: () => Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.teacherHome,
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
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
                          _viewModel.currentProfile.fullName.trim().isEmpty
                              ? 'Juan Pérez'
                              : _viewModel.currentProfile.fullName,
                          style: const TextStyle(
                            color: Color(0xFF102532),
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _viewModel.email.isEmpty
                              ? 'juan.perez@email.com'
                              : _viewModel.email,
                          style: const TextStyle(
                            color: AppColors.neutralGray,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _viewModel.institution.isEmpty
                              ? 'Institución Educativa XYZ'
                              : _viewModel.institution,
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
                          label: 'Correo Electrónico',
                          hintText: 'juan.perez@email.com',
                          keyboardType: TextInputType.emailAddress,
                          validator: AuthValidators.validateEmail,
                          onChanged: _viewModel.setEmail,
                        ),
                        const SizedBox(height: 18),
                        AppTextField(
                          controller: _institutionController,
                          label: 'Institución Educativa',
                          hintText: 'Institución Educativa XYZ',
                          validator: (value) =>
                              AuthValidators.validateRequiredField(
                                value,
                                'La institución educativa es obligatoria.',
                              ),
                          onChanged: _viewModel.setInstitution,
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _cancel,
                                style: OutlinedButton.styleFrom(
                                  fixedSize: const Size.fromHeight(48),
                                  foregroundColor: const Color(0xFF102532),
                                  side: const BorderSide(
                                    color: Color(0xFF697789),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(7),
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
                                onPressed: _save,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 26),
                        TextButton.icon(
                          onPressed: () => Navigator.pushNamedAndRemoveUntil(
                            context,
                            AppRoutes.login,
                            (route) => false,
                          ),
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
