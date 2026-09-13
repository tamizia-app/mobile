import 'package:flutter/material.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/student_instruction_card.dart';
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
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFFCFAFB),
          body: Column(
            children: [
              AppHeader(
                title: 'Instrucciones',
                showBack: true,
                centerTitle: true,
                onBack: () => Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.assessmentConfigure,
                  arguments: _session?.exerciseId,
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 42, 16, 30),
                  child: Column(
                    children: [
                      const StudentInstructionCard(),
                      const SizedBox(height: 28),
                      const Text(
                        '¡Antes de empezar!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF111827),
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _viewModel.instructionText,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF334155),
                          fontSize: 20,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 22),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F7FF),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.mood, color: Color(0xFF245FE5)),
                            SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'Hazlo con calma, no es un examen',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFF245FE5),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 42),
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: FilledButton(
                          onPressed: _start,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFFF5B0A),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            '¡Comenzar! ▶',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pushReplacementNamed(
                            context,
                            AppRoutes.assessmentConfigure,
                            arguments: _session?.exerciseId,
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF4B5563),
                            side: const BorderSide(color: Color(0xFFDDE6EF)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(27),
                            ),
                          ),
                          child: const Text(
                            'Volver',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
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
