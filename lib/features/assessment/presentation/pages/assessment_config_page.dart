import 'package:flutter/material.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/assessment_summary_card.dart';
import '../../../../core/widgets/info_banner.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../classrooms/data/services/classroom_service.dart';
import '../../../exercises/data/services/exercise_service.dart';
import '../../../students/data/services/student_service.dart';
import '../../data/services/assessment_service.dart';
import '../viewmodels/assessment_config_viewmodel.dart';

class AssessmentConfigPage extends StatefulWidget {
  const AssessmentConfigPage({
    required this.classroomService,
    required this.studentService,
    required this.exerciseService,
    required this.assessmentService,
    super.key,
  });

  final ClassroomService classroomService;
  final StudentService studentService;
  final ExerciseService exerciseService;
  final AssessmentService assessmentService;

  @override
  State<AssessmentConfigPage> createState() => _AssessmentConfigPageState();
}

class _AssessmentConfigPageState extends State<AssessmentConfigPage> {
  late final AssessmentConfigViewModel _viewModel;
  String? _exerciseId;

  @override
  void initState() {
    super.initState();
    _viewModel = AssessmentConfigViewModel(
      classroomService: widget.classroomService,
      studentService: widget.studentService,
      exerciseService: widget.exerciseService,
      assessmentService: widget.assessmentService,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final argument = ModalRoute.of(context)?.settings.arguments;
    if (argument is String) _exerciseId = argument;
    if (_viewModel.exercises.isEmpty) {
      _viewModel.load(preselectedExerciseId: _exerciseId);
    }
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    final session = await _viewModel.createSession();
    if (!mounted || session == null) return;
    Navigator.pushNamed(
      context,
      AppRoutes.assessmentInstructions,
      arguments: session,
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
                title: 'Nueva evaluación',
                showBack: true,
                centerTitle: true,
                onBack: () => Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.exerciseDetail,
                  arguments: _exerciseId ?? _viewModel.exerciseId,
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
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
                              (item) => DropdownMenuItem(
                                value: item.id,
                                child: Text(item.name),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) _viewModel.setClassroom(value);
                        },
                      ),
                      const SizedBox(height: 24),
                      _ConfigDropdown(
                        label: 'Estudiante (seudónimo)',
                        hint: 'Seleccionar estudiante',
                        value: _viewModel.studentId.isEmpty
                            ? null
                            : _viewModel.studentId,
                        items: _viewModel.students
                            .map(
                              (item) => DropdownMenuItem(
                                value: item.id,
                                child: Text(item.alias),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) _viewModel.setStudent(value);
                        },
                      ),
                      const SizedBox(height: 24),
                      _ConfigDropdown(
                        label: 'Ejercicio',
                        hint: 'Seleccionar ejercicio',
                        value: _viewModel.exerciseId.isEmpty
                            ? null
                            : _viewModel.exerciseId,
                        items: _viewModel.exercises
                            .map(
                              (item) => DropdownMenuItem(
                                value: item.id,
                                child: Text(item.title),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) _viewModel.setExercise(value);
                        },
                      ),
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
                        'Resumen de sesión',
                        style: TextStyle(
                          color: Color(0xFF111827),
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 28),
                      const AssessmentSummaryCard(durationText: '15 - 20 min'),
                      const SizedBox(height: 24),
                      const InfoBanner(
                        text:
                            'Se requiere consentimiento previo\nAsegúrese de contar con la autorización de los tutores legales antes de iniciar la evaluación con el estudiante.',
                        backgroundColor: Color(0xFFD1EAF6),
                        borderColor: Color(0xFFABCEDF),
                      ),
                      const SizedBox(height: 48),
                      PrimaryButton(
                        text: 'Iniciar evaluación',
                        icon: Icons.arrow_forward,
                        isLoading: _viewModel.isLoading,
                        onPressed: _start,
                      ),
                    ],
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
          initialValue: value,
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
