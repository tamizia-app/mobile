import 'package:flutter/material.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/widgets/assessment_cancel_dialog.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/drawing_canvas_placeholder.dart';
import '../../../../core/widgets/student_action_button.dart';
import '../../../../core/widgets/student_success_banner.dart';
import '../../../exercises/data/services/exercise_service.dart';
import '../../data/services/assessment_service.dart';
import '../../domain/models/assessment_session.dart';
import '../viewmodels/writing_assessment_viewmodel.dart';

class WritingAssessmentPage extends StatefulWidget {
  const WritingAssessmentPage({
    required this.exerciseService,
    required this.assessmentService,
    super.key,
  });

  final ExerciseService exerciseService;
  final AssessmentService assessmentService;

  @override
  State<WritingAssessmentPage> createState() => _WritingAssessmentPageState();
}

class _WritingAssessmentPageState extends State<WritingAssessmentPage> {
  late final WritingAssessmentViewModel _viewModel;
  AssessmentSession? _session;

  @override
  void initState() {
    super.initState();
    _viewModel = WritingAssessmentViewModel(
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

  Future<void> _finish() async {
    await _viewModel.finish();
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Evaluación finalizada')));
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.exerciseCatalog,
      (route) => false,
    );
  }

  Future<void> _confirmCancel() async {
    final shouldCancel = await showAssessmentCancelDialog(context);
    if (!mounted || !shouldCancel) return;
    await _viewModel.cancel();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.exerciseCatalog,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, _) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) _confirmCancel();
          },
          child: Scaffold(
            backgroundColor: const Color(0xFFFCFAFB),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppHeader(
                      title: '¡Vamos a escribir!',
                      showBack: true,
                      centerTitle: true,
                      onBack: _confirmCancel,
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE8EDF2)),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Escribe esta frase:',
                            style: TextStyle(fontSize: 17),
                          ),
                          Text(
                            _viewModel.exercise?.phraseToWrite ??
                                'El gato duerme.',
                            style: const TextStyle(
                              color: Color(0xFFFF5B0A),
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Escribe aquí',
                      style: TextStyle(color: Color(0xFF8A8F98), fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: DrawingCanvasPlaceholder(
                        strokes: _viewModel.strokes,
                        enabled: !_viewModel.isPaused,
                        onPanStart: _viewModel.startStroke,
                        onPanUpdate: _viewModel.appendStroke,
                        onPanEnd: _viewModel.endStroke,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const StudentSuccessBanner(
                      text: 'Lo estás haciendo muy bien',
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: StudentActionButton(
                            text: 'Limpiar',
                            icon: Icons.cleaning_services_outlined,
                            onPressed: _viewModel.clear,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: StudentActionButton(
                            text: 'Finalizar',
                            icon: Icons.stars,
                            primary: true,
                            onPressed: _finish,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
