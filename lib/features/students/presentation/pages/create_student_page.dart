import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/info_banner.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../domain/repositories/student_repository.dart';
import '../viewmodels/student_form_viewmodel.dart';

class CreateStudentPage extends StatefulWidget {
  const CreateStudentPage({required this.studentRepository, super.key});

  final StudentRepository studentRepository;

  @override
  State<CreateStudentPage> createState() => _CreateStudentPageState();
}

class _CreateStudentPageState extends State<CreateStudentPage> {
  late final StudentFormViewModel _viewModel;
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _ageController = TextEditingController();
  String? _classroomId;
  String? _classroomName;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _viewModel = StudentFormViewModel(
      studentRepository: widget.studentRepository,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) {
      return;
    }
    final argument = ModalRoute.of(context)?.settings.arguments;
    if (argument is Map<String, dynamic>) {
      _classroomId = argument['classroomId'] as String?;
      _classroomName = argument['classroomName'] as String?;
    } else if (argument is String) {
      _classroomId = argument;
    }
    final classroomId = _classroomId;
    if (classroomId != null && classroomId.isNotEmpty) {
      _viewModel.initializeForCreate(classroomId);
    }
    _initialized = true;
  }

  @override
  void dispose() {
    _codeController.dispose();
    _ageController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final result = await _viewModel.createStudentWithOptionalConsent();
    if (!mounted || result == null) {
      return;
    }
    Navigator.pop(context, result);
  }

  Future<void> _pickConsentFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png'],
      withData: true,
    );
    final file = result?.files.single;
    if (file == null) {
      return;
    }
    _viewModel.selectConsentFile(
      name: file.name,
      bytes: file.bytes?.toList(growable: false) ?? const [],
    );
  }

  @override
  Widget build(BuildContext context) {
    return StudentFormScaffold(
      title: 'Agregar estudiante',
      subtitle: _classroomName == null
          ? 'Aula: ${_classroomId ?? ''}'
          : 'Aula: $_classroomName',
      buttonText: 'Guardar',
      formKey: _formKey,
      viewModel: _viewModel,
      codeController: _codeController,
      ageController: _ageController,
      onPickConsent: _pickConsentFile,
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
    this.onPickConsent,
    this.onRetry,
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
  final VoidCallback? onPickConsent;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: viewModel,
      builder: (context, _) {
        final isBusy =
            viewModel.isLoading ||
            viewModel.isSubmitting ||
            viewModel.isUploadingConsent;
        final saveAction = viewModel.isEditing
            ? (viewModel.canSave ? onSave : null)
            : (isBusy ? null : onSave);
        return Scaffold(
          backgroundColor: AppColors.teacherBackground,
          bottomNavigationBar: viewModel.isInitialized
              ? Container(
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
                            onPressed: isBusy ? null : onCancel,
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
                            isLoading: isBusy,
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
                        padding: const EdgeInsets.fromLTRB(24, 28, 24, 110),
                        child: Form(
                          key: formKey,
                          child: Column(
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
                                label: 'Codigo del estudiante',
                                hintText: 'Ej: EST-001',
                                validator: (value) {
                                  final code = value?.trim() ?? '';
                                  if (code.isEmpty) {
                                    return 'El codigo es obligatorio.';
                                  }
                                  if (code.length > 50) {
                                    return 'El codigo admite hasta 50 caracteres.';
                                  }
                                  return viewModel.fieldErrors['code'];
                                },
                                onChanged: viewModel.setCode,
                              ),
                              const SizedBox(height: 20),
                              AppTextField(
                                controller: ageController,
                                label: 'Edad',
                                hintText: 'Entre 4 y 18',
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                validator: (value) {
                                  final age = int.tryParse(value?.trim() ?? '');
                                  if (age == null || age < 4 || age > 18) {
                                    return 'La edad debe estar entre 4 y 18.';
                                  }
                                  return viewModel.fieldErrors['age'];
                                },
                                onChanged: viewModel.setAge,
                              ),
                              const SizedBox(height: 20),
                              _GenderField(viewModel: viewModel),
                              const SizedBox(height: 24),
                              if (onPickConsent != null) ...[
                                _OptionalConsentSection(
                                  file: viewModel.selectedConsentFile,
                                  onSelect: onPickConsent!,
                                  onRemove: viewModel.removeConsentFile,
                                ),
                                const SizedBox(height: 24),
                              ],
                              const InfoBanner(
                                text:
                                    'Usa un codigo para proteger la identidad '
                                    'del estudiante.',
                                backgroundColor: Color(0xFFD6EEF9),
                                borderColor: Color(0xFFB4D7E5),
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
                          ),
                        ),
                      )
                    : _StudentFormLoading(
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

class _OptionalConsentSection extends StatelessWidget {
  const _OptionalConsentSection({
    required this.file,
    required this.onSelect,
    required this.onRemove,
  });

  final SelectedConsentFile? file;
  final VoidCallback onSelect;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final selected = file;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Consentimiento',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        const Text(
          'Puedes adjuntar ahora el documento de consentimiento o hacerlo '
          'mas adelante desde el detalle del estudiante.',
          style: TextStyle(color: AppColors.neutralGray, height: 1.4),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.cardBorder),
            borderRadius: BorderRadius.circular(8),
          ),
          child: selected == null
              ? Row(
                  children: [
                    const Expanded(child: Text('Sin consentimiento adjunto')),
                    TextButton.icon(
                      onPressed: onSelect,
                      icon: const Icon(Icons.attach_file),
                      label: const Text('Seleccionar archivo'),
                    ),
                  ],
                )
              : Row(
                  children: [
                    const Icon(Icons.description_outlined),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selected.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            _formatSize(selected.size),
                            style: const TextStyle(
                              color: AppColors.neutralGray,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Reemplazar archivo',
                      onPressed: onSelect,
                      icon: const Icon(Icons.swap_horiz),
                    ),
                    IconButton(
                      tooltip: 'Quitar archivo',
                      onPressed: onRemove,
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  static String _formatSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    }
    return '${(bytes / 1024).toStringAsFixed(1)} KB';
  }
}

class _GenderField extends StatelessWidget {
  const _GenderField({required this.viewModel});

  final StudentFormViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      key: ValueKey('gender-${viewModel.gender}'),
      initialValue: viewModel.gender.isEmpty ? null : viewModel.gender,
      hint: const Text('Seleccionar genero'),
      items: const [
        DropdownMenuItem(value: 'BOY', child: Text('Niño')),
        DropdownMenuItem(value: 'GIRL', child: Text('Niña')),
      ],
      validator: (_) =>
          viewModel.fieldErrors['gender'] ??
          (viewModel.gender.isEmpty ? 'Selecciona un genero.' : null),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onChanged: (value) => viewModel.setGender(value ?? ''),
      decoration: const InputDecoration(labelText: 'Genero'),
    );
  }
}

class _StudentFormLoading extends StatelessWidget {
  const _StudentFormLoading({
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
          Text(message ?? 'No se pudo cargar el estudiante.'),
          if (onRetry != null)
            TextButton(onPressed: onRetry, child: const Text('Reintentar')),
        ],
      ),
    );
  }
}
