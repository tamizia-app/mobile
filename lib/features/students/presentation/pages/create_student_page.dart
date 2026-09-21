import 'package:flutter/material.dart';
import '../../../../core/widgets/app_states.dart';
import '../../../../core/theme/app_tokens.dart';
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
      subtitle: _classroomName == null ? 'Aula nueva' : 'Aula: $_classroomName',
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
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.sm,
                    AppSpacing.lg,
                    AppSpacing.sm,
                    AppSpacing.xl,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: AppColors.divider)),
                  ),
                  child: SafeArea(
                    child: AppActionGroup(
                      children: [
                        OutlinedButton(
                          onPressed: isBusy ? null : onCancel,
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(AppSizes.button),
                            foregroundColor: AppColors.textPrimary,
                            side: const BorderSide(color: AppColors.border),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppRadius.control,
                              ),
                            ),
                          ),
                          child: const Text('Cancelar'),
                        ),
                        PrimaryButton(
                          text: buttonText,
                          isLoading: isBusy,
                          onPressed: saveAction,
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
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.xl,
                          AppSpacing.xl,
                          AppSpacing.xl,
                          110,
                        ),
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
                                    color: AppColors.textPrimary,
                                    fontSize: AppFontSizes.body,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xxl),
                              ],
                              AppTextField(
                                controller: codeController,
                                label: 'Código del estudiante',
                                hintText: 'Ej: EST-001',
                                validator: (value) {
                                  final code = value?.trim() ?? '';
                                  if (code.isEmpty) {
                                    return 'El código es obligatorio.';
                                  }
                                  if (code.length > 50) {
                                    return 'El código admite hasta 50 caracteres.';
                                  }
                                  return viewModel.fieldErrors['code'];
                                },
                                onChanged: viewModel.setCode,
                              ),
                              const SizedBox(height: AppSpacing.lg),
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
                              const SizedBox(height: AppSpacing.lg),
                              _GenderField(viewModel: viewModel),
                              const SizedBox(height: AppSpacing.xl),
                              if (onPickConsent != null) ...[
                                _OptionalConsentSection(
                                  file: viewModel.selectedConsentFile,
                                  onSelect: onPickConsent!,
                                  onRemove: viewModel.removeConsentFile,
                                ),
                                const SizedBox(height: AppSpacing.xl),
                              ],
                              const InfoBanner(
                                text:
                                    'Usa un código para proteger la identidad '
                                    'del estudiante.',
                                backgroundColor: AppColors.primaryContainer,
                                borderColor: AppColors.border,
                              ),
                              if (viewModel.generalError != null) ...[
                                const SizedBox(height: AppSpacing.md),
                                Text(
                                  viewModel.generalError!,
                                  style: const TextStyle(
                                    color: AppColors.errorRed,
                                    fontSize: AppFontSizes.support,
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
          style: TextStyle(
            fontSize: AppFontSizes.bodyLarge,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        const Text(
          'Puedes adjuntar ahora el documento de consentimiento o hacerlo '
          'más adelante desde el detalle del estudiante.',
          style: TextStyle(color: AppColors.neutralGray, height: 1.4),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.cardBorder),
            borderRadius: BorderRadius.circular(AppRadius.control),
          ),
          child: selected == null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Sin consentimiento adjunto'),
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
                    const SizedBox(width: AppSpacing.sm),
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
                              fontSize: AppFontSizes.support,
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
      isExpanded: true,
      itemHeight: null,
      key: ValueKey('gender-${viewModel.gender}'),
      value: viewModel.gender.isEmpty ? null : viewModel.gender,
      hint: const Text('Seleccionar género'),
      items: const [
        DropdownMenuItem(value: 'BOY', child: Text('Niño')),
        DropdownMenuItem(value: 'GIRL', child: Text('Niña')),
      ],
      validator: (_) =>
          viewModel.fieldErrors['gender'] ??
          (viewModel.gender.isEmpty ? 'Selecciona un género.' : null),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onChanged: (value) => viewModel.setGender(value ?? ''),
      decoration: const InputDecoration(labelText: 'Género'),
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
      return const AppLoadingState(message: 'Cargando información…');
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
