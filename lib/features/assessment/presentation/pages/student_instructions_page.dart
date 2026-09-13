import 'package:flutter/material.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/student_activity_layout.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/app_states.dart';
import '../../../../core/widgets/info_banner.dart';

import '../../../../core/constants/app_routes.dart';
import '../../data/services/assessment_service.dart';
import '../../domain/models/assessment_session.dart';
import '../../domain/models/assessment_type.dart';
import '../../../exercises/data/services/exercise_service.dart';
import '../viewmodels/student_instructions_viewmodel.dart';

class StudentInstructionsPage extends StatefulWidget {
  const StudentInstructionsPage({
    required this.exerciseService,
    required this.assessmentService,
    super.key,
  });

  final ExerciseService exerciseService;
  final AssessmentService assessmentService;

  @override
  State<StudentInstructionsPage> createState() =>
      _StudentInstructionsPageState();
}

class _StudentInstructionsPageState extends State<StudentInstructionsPage> {
  late final StudentInstructionsViewModel _viewModel;
  AssessmentSession? _session;

  @override
  void initState() {
    super.initState();
    _viewModel = StudentInstructionsViewModel(
      exerciseService: widget.exerciseService,
      assessmentService: widget.assessmentService,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final argument = ModalRoute.of(context)?.settings.arguments;
    if (argument is AssessmentSession && _session == null) {
      _session = argument;
      _viewModel.load(argument);
    }
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    final session = _session;
    if (session == null) return;
    await _viewModel.start();
    if (!mounted) return;
    Navigator.pushNamed(
      context,
      _routeForType(session.type),
      arguments: session,
    );
  }

  String _routeForType(AssessmentType type) {
    switch (type) {
      case AssessmentType.reading:
      case AssessmentType.mixed:
        return AppRoutes.assessmentReading;
      case AssessmentType.writing:
        return AppRoutes.assessmentWriting;
      case AssessmentType.buildWord:
        return AppRoutes.assessmentBuildWord;
      case AssessmentType.chooseWord:
        return AppRoutes.assessmentChooseWord;
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _viewModel,
    builder: (context, _) => StudentActivityLayout(
      title: 'Antes de empezar',
      onBack: () => Navigator.pushReplacementNamed(
        context,
        AppRoutes.assessmentConfigure,
        arguments: _session?.exerciseId,
      ),
      child: _viewModel.isLoading
          ? const AppLoadingState(message: 'Preparando la actividad…')
          : SingleChildScrollView(
              padding: AppSpacing.page,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  StudentInstructionBubble(
                    instruction: _viewModel.instructionText,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  const InfoBanner(
                    text: 'Hazlo con calma. Tu docente te acompañará.',
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  PrimaryButton(
                    text: 'Comenzar actividad',
                    icon: Icons.play_arrow_rounded,
                    student: true,
                    onPressed: _start,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  PrimaryButton(
                    text: 'Volver',
                    student: true,
                    variant: AppButtonVariant.secondary,
                    onPressed: () => Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.assessmentConfigure,
                      arguments: _session?.exerciseId,
                    ),
                  ),
                ],
              ),
            ),
    ),
  );
}
