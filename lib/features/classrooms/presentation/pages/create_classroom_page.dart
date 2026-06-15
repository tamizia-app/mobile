import 'package:flutter/material.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../data/services/classroom_service.dart';
import '../viewmodels/classroom_form_viewmodel.dart';

class CreateClassroomPage extends StatefulWidget {
  const CreateClassroomPage({required this.classroomService, super.key});

  final ClassroomService classroomService;

  @override
  State<CreateClassroomPage> createState() => _CreateClassroomPageState();
}

class _CreateClassroomPageState extends State<CreateClassroomPage> {
  late final ClassroomFormViewModel _viewModel;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel = ClassroomFormViewModel(
      classroomService: widget.classroomService,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final formValid = _formKey.currentState!.validate();
    final saved = await _viewModel.create();
    if (!mounted || !formValid || !saved) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Aula creada correctamente')));
    Navigator.pushReplacementNamed(context, AppRoutes.classrooms);
  }

  @override
  Widget build(BuildContext context) {
    return ClassroomFormScaffold(
      title: 'Crear aula',
      buttonText: 'Guardar',
      formKey: _formKey,
      viewModel: _viewModel,
      nameController: _nameController,
      onCancel: () =>
          Navigator.pushReplacementNamed(context, AppRoutes.classrooms),
      onSave: _save,
    );
  }
}

class ClassroomFormFields extends StatelessWidget {
  const ClassroomFormFields({
    required this.viewModel,
    required this.nameController,
    super.key,
  });

  final ClassroomFormViewModel viewModel;
  final TextEditingController nameController;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: viewModel,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTextField(
              controller: nameController,
              label: 'Nombre del aula *',
              hintText: 'Ej. Aula de Ciencias',
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Este campo es obligatorio.'
                  : null,
              onChanged: viewModel.setName,
            ),
            const SizedBox(height: 22),
            _DropdownField(
              label: 'Grado',
              hint: 'Seleccionar grado',
              value: viewModel.grade.isEmpty ? null : viewModel.grade,
              items: const ['3ro', '4to', '5to'],
              onChanged: (value) => viewModel.setGrade(value ?? ''),
            ),
            const SizedBox(height: 22),
            _DropdownField(
              label: 'Sección',
              hint: 'Seleccionar sección',
              value: viewModel.section.isEmpty ? null : viewModel.section,
              items: const ['A', 'B', 'C'],
              onChanged: (value) => viewModel.setSection(value ?? ''),
            ),
            const SizedBox(height: 22),
            _DropdownField(
              label: 'Año escolar',
              hint: 'Seleccionar año',
              value: viewModel.schoolYear.isEmpty ? null : viewModel.schoolYear,
              items: const ['2026', '2025', '2024'],
              onChanged: (value) => viewModel.setSchoolYear(value ?? ''),
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
    );
  }
}

class ClassroomFormScaffold extends StatelessWidget {
  const ClassroomFormScaffold({
    required this.title,
    required this.buttonText,
    required this.formKey,
    required this.viewModel,
    required this.nameController,
    required this.onCancel,
    required this.onSave,
    super.key,
  });

  final String title;
  final String buttonText;
  final GlobalKey<FormState> formKey;
  final ClassroomFormViewModel viewModel;
  final TextEditingController nameController;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(26, 16, 26, 26),
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
              padding: const EdgeInsets.fromLTRB(26, 26, 26, 40),
              child: Form(
                key: formKey,
                child: ClassroomFormFields(
                  viewModel: viewModel,
                  nameController: nameController,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({
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
            fontSize: 13,
            fontWeight: FontWeight.w600,
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
              borderSide: const BorderSide(color: Color(0xFF697789)),
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
