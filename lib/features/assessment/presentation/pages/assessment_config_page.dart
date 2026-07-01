import 'package:flutter/material.dart';

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
          backgroundColor: const Color(0xFFFAFBFC),
          body: Column(
            children: [
              AppHeader(
                title: 'Nueva evaluacion',
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
      return const Center(child: CircularProgressIndicator());
    }
    if (_viewModel.errorMessage != null && _viewModel.templates.isEmpty) {
      return _ErrorState(
        message: _viewModel.errorMessage!,
        onRetry: () => _viewModel.load(preselectedTemplateId: _templateId),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
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
          const SizedBox(height: 24),
          _ConfigDropdown(
            label: 'Estudiante (seudonimo)',
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
            const SizedBox(height: 10),
            const LinearProgressIndicator(minHeight: 2),
          ],
          const SizedBox(height: 24),
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
            const SizedBox(height: 18),
            const _ConsentBlockedBanner(),
          ],
          if (_viewModel.pendingAttempt != null) ...[
            const SizedBox(height: 18),
            _PendingAttemptBanner(attemptId: _viewModel.pendingAttempt!.id),
          ],
          if (_viewModel.errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              _viewModel.errorMessage!,
              style: const TextStyle(
                color: AppColors.errorRed,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 28),
          const Text(
            'Resumen de sesion',
            style: TextStyle(
              color: Color(0xFF111827),
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 18),
          _SelectedSummary(
            classroom: _viewModel.selectedClassroom?.name,
            student: _viewModel.selectedStudent?.alias,
            template: _viewModel.selectedTemplate?.name,
          ),
          const SizedBox(height: 18),
          const AssessmentSummaryCard(durationText: '15 - 20 min'),
          const SizedBox(height: 24),
          const InfoBanner(
            text:
                'Se requiere consentimiento previo\nAsegurese de contar con la autorizacion de los tutores legales antes de iniciar la evaluacion con el estudiante.',
            backgroundColor: Color(0xFFD1EAF6),
            borderColor: Color(0xFFABCEDF),
          ),
          const SizedBox(height: 48),
          PrimaryButton(
            text: 'Crear assessment e iniciar intento',
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
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
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.mutedText),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConsentBlockedBanner extends StatelessWidget {
  const _ConsentBlockedBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFCA5A5)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.block_outlined, color: AppColors.errorRed),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'No se puede iniciar la evaluacion sin consentimiento valido.',
              style: TextStyle(
                color: AppColors.errorRed,
                fontWeight: FontWeight.w800,
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
  const _PendingAttemptBanner({required this.attemptId});

  final String attemptId;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF93C5FD)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.play_circle_outline, color: AppColors.primaryBlue),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Se encontro un intento pendiente para reanudar: $attemptId',
              style: const TextStyle(
                color: Color(0xFF1E3A8A),
                fontWeight: FontWeight.w800,
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
            color: Color(0xFF111827),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
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
              borderRadius: BorderRadius.circular(7),
              borderSide: const BorderSide(color: Color(0xFFCED8E3)),
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

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            TextButton(onPressed: onRetry, child: const Text('Reintentar')),
          ],
        ),
      ),
    );
  }
}
