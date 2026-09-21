import 'package:flutter/material.dart';
import '../../../../core/widgets/app_states.dart';
import '../../../../core/theme/app_tokens.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/assessment_summary_card.dart';
import '../../../../core/widgets/info_banner.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../classrooms/domain/repositories/classroom_repository.dart';
import '../../../students/domain/repositories/student_repository.dart';
import '../../domain/repositories/assessment_repository.dart';
import '../viewmodels/assessment_config_viewmodel.dart';

class AssessmentConfigPage extends StatefulWidget {
  const AssessmentConfigPage({
    required this.classroomRepository,
    required this.studentRepository,
    required this.assessmentRepository,
    super.key,
  });

  final ClassroomRepository classroomRepository;
  final StudentRepository studentRepository;
  final AssessmentRepository assessmentRepository;

  @override
  State<AssessmentConfigPage> createState() => _AssessmentConfigPageState();
}

class _AssessmentConfigPageState extends State<AssessmentConfigPage> {
  late final AssessmentConfigViewModel _viewModel;
  String? _templateId;

  @override
  void initState() {
    super.initState();
    _viewModel = AssessmentConfigViewModel(
      classroomRepository: widget.classroomRepository,
      studentRepository: widget.studentRepository,
      assessmentRepository: widget.assessmentRepository,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final argument = ModalRoute.of(context)?.settings.arguments;
    if (argument is String) {
      _templateId = argument;
    }
    if (_viewModel.templates.isEmpty && !_viewModel.isLoading) {
      _viewModel.load(preselectedTemplateId: _templateId);
    }
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _createAssessmentAndAttempt() async {
    final preview = await _viewModel.createAssessmentAndAttempt();
    if (!mounted || preview == null) {
      return;
    }
    Navigator.pushNamed(
      context,
      AppRoutes.assessmentAttemptPreview,
      arguments: preview,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: Column(
            children: [
              AppHeader(
                title: 'Nueva evaluación',
                showBack: true,
                centerTitle: true,
                onBack: () => Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.templateCatalog,
                ),
              ),
              Expanded(child: _buildContent()),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    if (_viewModel.isLoading) {
      return const AppLoadingState(message: 'Cargando información…');
    }
    if (_viewModel.errorMessage != null && _viewModel.templates.isEmpty) {
      return _ErrorState(
        message: _viewModel.errorMessage!,
        onRetry: () => _viewModel.load(preselectedTemplateId: _templateId),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ConfigDropdown(
            label: 'Aula',
            hint: 'Seleccionar aula',
            value: _viewModel.classroomId.isEmpty
                ? null
                : _viewModel.classroomId,
            items: _viewModel.classrooms
                .map(
                  (item) =>
                      DropdownMenuItem(value: item.id, child: Text(item.name)),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) {
                _viewModel.setClassroom(value);
              }
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          _ConfigDropdown(
            label: 'Estudiante (seudónimo)',
            hint: 'Seleccionar estudiante',
            value: _viewModel.studentId.isEmpty ? null : _viewModel.studentId,
            items: _viewModel.students
                .map(
                  (item) =>
                      DropdownMenuItem(value: item.id, child: Text(item.alias)),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) {
                _viewModel.setStudent(value);
              }
            },
          ),
          if (_viewModel.isLoadingConsent) ...[
            const SizedBox(height: AppSpacing.sm),
            const LinearProgressIndicator(minHeight: 2),
          ],
          const SizedBox(height: AppSpacing.xl),
          _ConfigDropdown(
            label: 'Plantilla',
            hint: 'Seleccionar plantilla',
            value: _viewModel.templateId.isEmpty ? null : _viewModel.templateId,
            items: _viewModel.templates
                .map(
                  (item) =>
                      DropdownMenuItem(value: item.id, child: Text(item.name)),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) {
                _viewModel.setTemplate(value);
              }
            },
          ),
          if (_viewModel.missingConsent) ...[
            const SizedBox(height: AppSpacing.lg),
            const _ConsentBlockedBanner(),
          ],
          if (_viewModel.pendingAttempt != null) ...[
            const SizedBox(height: AppSpacing.lg),
            const _PendingAttemptBanner(),
          ],
          if (_viewModel.errorMessage != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              _viewModel.errorMessage!,
              style: const TextStyle(
                color: AppColors.errorRed,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          const Text(
            'Resumen de la sesión',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: AppFontSizes.title,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _SelectedSummary(
            classroom: _viewModel.selectedClassroom?.name,
            student: _viewModel.selectedStudent?.alias,
            template: _viewModel.selectedTemplate?.name,
          ),
          const SizedBox(height: AppSpacing.lg),
          const AssessmentSummaryCard(durationText: '15–20 min'),
          const SizedBox(height: AppSpacing.xl),
          const InfoBanner(
            text:
                'Se requiere consentimiento previo\nAsegúrate de contar con la autorización de los tutores legales antes de iniciar la evaluación con el estudiante.',
            backgroundColor: AppColors.primaryContainer,
            borderColor: AppColors.border,
          ),
          const SizedBox(height: AppSpacing.huge),
          PrimaryButton(
            text: 'Crear evaluación e iniciar intento',
            icon: Icons.arrow_forward,
            isLoading: _viewModel.isSubmitting,
            onPressed: _createAssessmentAndAttempt,
          ),
        ],
      ),
    );
  }
}

class _SelectedSummary extends StatelessWidget {
  const _SelectedSummary({
    required this.classroom,
    required this.student,
    required this.template,
  });

  final String? classroom;
  final String? student;
  final String? template;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.control),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          _SummaryRow(label: 'Aula', value: classroom ?? 'Pendiente'),
          _SummaryRow(label: 'Estudiante', value: student ?? 'Pendiente'),
          _SummaryRow(label: 'Plantilla', value: template ?? 'Pendiente'),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) =>
      AppDetailRow(label: label, value: value);
}

class _ConsentBlockedBanner extends StatelessWidget {
  const _ConsentBlockedBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.errorContainer,
        borderRadius: BorderRadius.circular(AppRadius.control),
        border: Border.all(color: AppColors.errorContainer),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.block_outlined, color: AppColors.errorRed),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'No se puede iniciar la evaluación sin un consentimiento válido.',
              style: TextStyle(
                color: AppColors.errorRed,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingAttemptBanner extends StatelessWidget {
  const _PendingAttemptBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(AppRadius.control),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.play_circle_outline, color: AppColors.primaryBlue),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Se encontró un intento pendiente. Puedes continuar desde donde lo dejaste.',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfigDropdown extends StatelessWidget {
  const _ConfigDropdown({
    required this.label,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String hint;
  final String? value;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: AppFontSizes.body,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        DropdownButtonFormField<String>(
          itemHeight: null,
          key: ValueKey('$label-${value ?? 'empty'}-${items.length}'),
          value: value,
          hint: Text(hint),
          isExpanded: true,
          items: items,
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 18,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.control),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.control),
              borderSide: const BorderSide(color: AppColors.primaryBlue),
            ),
          ),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.md),
            TextButton(onPressed: onRetry, child: const Text('Reintentar')),
          ],
        ),
      ),
    );
  }
}
