import 'package:flutter/material.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/info_banner.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../data/services/student_service.dart';
import '../viewmodels/student_form_viewmodel.dart';

class CreateStudentPage extends StatefulWidget {
  const CreateStudentPage({required this.studentService, super.key});

  final StudentService studentService;

  @override
  State<CreateStudentPage> createState() => _CreateStudentPageState();
}

class _CreateStudentPageState extends State<CreateStudentPage> {
  late final StudentFormViewModel _viewModel;
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _ageController = TextEditingController();
  String? _returnClassroomId;

  @override
  void initState() {
    super.initState();
    _viewModel = StudentFormViewModel(studentService: widget.studentService);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final argument = ModalRoute.of(context)?.settings.arguments;
    if (argument is String) {
      _returnClassroomId = argument;
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _ageController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final formValid = _formKey.currentState!.validate();
    final saved = await _viewModel.create();
    if (!mounted || !formValid || !saved) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Estudiante registrado correctamente')),
    );
    if (_returnClassroomId != null) {
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.classroomDetail,
        arguments: _returnClassroomId,
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StudentFormScaffold(
      title: 'Agregar estudiante',
      subtitle: 'Registro Estudiantil',
      buttonText: 'Guardar',
      formKey: _formKey,
      viewModel: _viewModel,
      codeController: _codeController,
      ageController: _ageController,
      onCancel: () => Navigator.pop(context),
      onSave: _save,
    );
  }
}

class StudentFormScaffold extends StatelessWidget {
  const StudentFormScaffold({
    required this.title,
    required this.buttonText,
    required this.formKey,
    required this.viewModel,
    required this.codeController,
    required this.ageController,
    required this.onCancel,
    required this.onSave,
    this.subtitle,
    super.key,
  });

  final String title;
  final String? subtitle;
  final String buttonText;
  final GlobalKey<FormState> formKey;
  final StudentFormViewModel viewModel;
  final TextEditingController codeController;
  final TextEditingController ageController;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.teacherBackground,
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(10, 16, 10, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFD9E2EA))),
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onCancel,
                  style: OutlinedButton.styleFrom(
                    fixedSize: const Size.fromHeight(48),
                    foregroundColor: const Color(0xFF102532),
                    side: const BorderSide(color: Color(0xFF697789)),
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
                  text: buttonText,
                  isLoading: viewModel.isLoading,
                  onPressed: onSave,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          AppHeader(title: title, showBack: true),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 110),
              child: Form(
                key: formKey,
                child: AnimatedBuilder(
                  animation: viewModel,
                  builder: (context, _) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (subtitle != null) ...[
                          Text(
                            subtitle!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFF102532),
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 34),
                        ],
                        AppTextField(
                          controller: codeController,
                          label: 'Código o seudónimo',
                          hintText: 'Ej: EST-001',
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? 'El código o seudónimo es obligatorio.'
                              : null,
                          onChanged: viewModel.setCode,
                        ),
                        const SizedBox(height: 20),
                        AppTextField(
                          controller: ageController,
                          label: 'Edad',
                          hintText: 'Ej: 12',
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            final age = int.tryParse(value?.trim() ?? '');
                            if (age == null || age <= 0 || age > 120) {
                              return 'Ingresa una edad válida.';
                            }
                            return null;
                          },
                          onChanged: viewModel.setAge,
                        ),
                        const SizedBox(height: 20),
                        _StudentDropdownField(
                          label: 'Grado',
                          hint: 'Seleccionar',
                          value: viewModel.grade.isEmpty
                              ? null
                              : viewModel.grade,
                          items: const ['3ro', '4to', '5to'],
                          onChanged: (value) => viewModel.setGrade(value ?? ''),
                        ),
                        const SizedBox(height: 20),
                        _StudentDropdownField(
                          label: 'Aula',
                          hint: 'Seleccionar',
                          value: viewModel.classroomName.isEmpty
                              ? null
                              : viewModel.classroomName,
                          items: const ['3B', 'Aula A', '4to A', '5to C'],
                          onChanged: (value) =>
                              viewModel.setClassroom(value ?? ''),
                        ),
                        const SizedBox(height: 28),
                        Row(
                          children: [
                            Checkbox(
                              value: viewModel.hasParentAuthorization,
                              onChanged: (value) =>
                                  viewModel.setAuthorization(value ?? false),
                            ),
                            const Expanded(
                              child: Text(
                                'Autorización del padre registrada',
                                style: TextStyle(
                                  color: Color(0xFF102532),
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const InfoBanner(
                          text:
                              'Se recomienda usar códigos para proteger la identidad del estudiante durante las evaluaciones.',
                          backgroundColor: Color(0xFFD6EEF9),
                          borderColor: Color(0xFFB4D7E5),
                        ),
                        if (viewModel.errorMessage != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            viewModel.errorMessage!,
                            style: const TextStyle(
                              color: AppColors.errorRed,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentDropdownField extends StatelessWidget {
  const _StudentDropdownField({
    required this.label,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String hint;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF102532),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          key: ValueKey('$label-${value ?? 'empty'}'),
          initialValue: value,
          hint: Text(hint),
          items: items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 17,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(7),
              borderSide: const BorderSide(color: Color(0xFFC2CDDA)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(7),
              borderSide: const BorderSide(color: AppColors.primaryBlue),
            ),
          ),
        ),
      ],
    );
  }
}
