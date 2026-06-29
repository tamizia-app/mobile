import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../domain/repositories/classroom_repository.dart';
import '../viewmodels/classroom_form_viewmodel.dart';

class CreateClassroomPage extends StatefulWidget {
  const CreateClassroomPage({required this.classroomRepository, super.key});

  final ClassroomRepository classroomRepository;

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
      classroomRepository: widget.classroomRepository,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final created = await _viewModel.create();
    if (!mounted || created == null) {
      return;
    }
    Navigator.pop(context, created);
  }

  @override
  Widget build(BuildContext context) {
    return ClassroomFormScaffold(
      title: 'Crear aula',
      buttonText: 'Guardar',
      formKey: _formKey,
      viewModel: _viewModel,
      nameController: _nameController,
      onCancel: () => Navigator.pop(context),
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
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Este campo es obligatorio.';
                }
                return viewModel.fieldErrors['name'];
              },
              onChanged: viewModel.setName,
            ),
            const SizedBox(height: 22),
            _DropdownField(
              label: 'Grado',
              hint: 'Seleccionar grado',
              value: viewModel.gradeLevel.isEmpty ? null : viewModel.gradeLevel,
              items: ClassroomFormViewModel.gradeLevels,
              itemLabel: _capitalize,
              validator: (_) =>
                  viewModel.fieldErrors['grade_level'] ??
                  (viewModel.gradeLevel.isEmpty
                      ? 'Selecciona un grado.'
                      : null),
              onChanged: (value) => viewModel.setGradeLevel(value ?? ''),
            ),
            const SizedBox(height: 22),
            _DropdownField(
              label: 'Seccion',
              hint: 'Seleccionar seccion',
              value: viewModel.section.isEmpty ? null : viewModel.section,
              items: ClassroomFormViewModel.sections,
              validator: (_) =>
                  viewModel.fieldErrors['section'] ??
                  (viewModel.section.isEmpty
                      ? 'Selecciona una seccion.'
                      : null),
              onChanged: (value) => viewModel.setSection(value ?? ''),
            ),
            const SizedBox(height: 22),
            _YearField(
              value: viewModel.schoolYear?.year,
              years: viewModel.availableSchoolYears,
              errorText: viewModel.fieldErrors['school_year'],
              onChanged: viewModel.setSchoolYear,
            ),
            if (viewModel.generalError != null) ...[
              const SizedBox(height: 12),
              Text(
                viewModel.generalError!,
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

  static String _capitalize(String value) {
    return '${value[0].toUpperCase()}${value.substring(1)}';
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
    this.onRetry,
    super.key,
  });

  final String title;
  final String buttonText;
  final GlobalKey<FormState> formKey;
  final ClassroomFormViewModel viewModel;
  final TextEditingController nameController;
  final VoidCallback onCancel;
  final VoidCallback onSave;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: viewModel,
      builder: (context, _) {
        final saveAction = viewModel.isEditing
            ? (viewModel.canSave ? onSave : null)
            : (viewModel.isLoading ? null : onSave);
        return Scaffold(
          backgroundColor: Colors.white,
          bottomNavigationBar: viewModel.isInitialized
              ? Container(
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
                            onPressed: viewModel.isLoading ? null : onCancel,
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
                            onPressed: saveAction,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : null,
          body: Column(
            children: [
              AppHeader(title: title, showBack: true),
              Expanded(
                child: viewModel.isInitialized
                    ? SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(26, 26, 26, 40),
                        child: Form(
                          key: formKey,
                          child: ClassroomFormFields(
                            viewModel: viewModel,
                            nameController: nameController,
                          ),
                        ),
                      )
                    : _ClassroomFormLoading(
                        isLoading: viewModel.isLoading,
                        message: viewModel.generalError,
                        onRetry: onRetry,
                      ),
              ),
            ],
          ),
        );
      },
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
    required this.validator,
    this.itemLabel,
  });

  final String label;
  final String hint;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final FormFieldValidator<String> validator;
  final String Function(String)? itemLabel;

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
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(itemLabel?.call(item) ?? item),
                ),
              )
              .toList(),
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
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

class _YearField extends StatelessWidget {
  const _YearField({
    required this.value,
    required this.years,
    required this.errorText,
    required this.onChanged,
  });

  final int? value;
  final List<int> years;
  final String? errorText;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return _DropdownField(
      label: 'Año escolar',
      hint: 'Seleccionar año',
      value: value?.toString(),
      items: years.map((year) => year.toString()).toList(growable: false),
      validator: (_) =>
          errorText ??
          (value == null || !years.contains(value)
              ? 'Selecciona un año escolar válido.'
              : null),
      onChanged: (selected) {
        final year = int.tryParse(selected ?? '');
        if (year != null) {
          onChanged(year);
        }
      },
    );
  }
}

class _ClassroomFormLoading extends StatelessWidget {
  const _ClassroomFormLoading({
    required this.isLoading,
    required this.message,
    required this.onRetry,
  });

  final bool isLoading;
  final String? message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message ?? 'No se pudo cargar el aula.'),
          if (onRetry != null)
            TextButton(onPressed: onRetry, child: const Text('Reintentar')),
        ],
      ),
    );
  }
}
