import 'package:flutter/material.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/widgets/assessment_cancel_dialog.dart';
import '../../../../core/widgets/assessment_pause_overlay.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/assessment_timer.dart';
import '../../../../core/widgets/student_action_button.dart';
import '../../../../core/widgets/student_success_banner.dart';
import '../../../exercises/data/services/exercise_service.dart';
import '../../data/services/assessment_service.dart';
import '../../domain/models/assessment_session.dart';
import '../viewmodels/reading_assessment_viewmodel.dart';

class ReadingAssessmentPage extends StatefulWidget {
  const ReadingAssessmentPage({
    required this.exerciseService,
    required this.assessmentService,
    super.key,
  });

  final ExerciseService exerciseService;
  final AssessmentService assessmentService;

  @override
  State<ReadingAssessmentPage> createState() => _ReadingAssessmentPageState();
}

class _ReadingAssessmentPageState extends State<ReadingAssessmentPage> {
  late final ReadingAssessmentViewModel _viewModel;
  AssessmentSession? _session;

  @override
  void initState() {
    super.initState();
    _viewModel = ReadingAssessmentViewModel(
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
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    child: Column(
                      children: [
                        AppHeader(
                          title: '¡Vamos a leer juntos!',
                          showBack: true,
                          centerTitle: true,
                          onBack: _confirmCancel,
                        ),
                        const SizedBox(height: 8),
                        AssessmentTimer(
                          minutes: _viewModel.minutes,
                          seconds: _viewModel.seconds,
                        ),
                        const SizedBox(height: 18),
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            alignment: Alignment.center,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Text(
                              _viewModel.exercise?.referenceText ??
                                  'El sol brilla en el cielo azul y las aves cantan',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF231610),
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        IgnorePointer(
                          ignoring: _viewModel.isPaused,
                          child: GestureDetector(
                            onTap: _viewModel.toggleRecording,
                            child: CircleAvatar(
                              radius: 48,
                              backgroundColor: _viewModel.isRecording
                                  ? const Color(0xFFFFD0C2)
                                  : Colors.white,
                              child: CircleAvatar(
                                radius: 42,
                                backgroundColor: _viewModel.isRecording
                                    ? const Color(0xFFD9281E)
                                    : const Color(0xFFFF5B0A),
                                child: Icon(
                                  _viewModel.isRecording
                                      ? Icons.stop
                                      : Icons.mic,
                                  color: Colors.white,
                                  size: 34,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const StudentSuccessBanner(
                          text: 'Lo estás haciendo muy bien',
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: StudentActionButton(
                                text: _viewModel.isPaused
                                    ? 'Reanudar'
                                    : 'Pausar',
                                icon: _viewModel.isPaused
                                    ? Icons.play_arrow
                                    : Icons.pause,
                                onPressed: () async {
                                  await _viewModel.togglePause();
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: StudentActionButton(
                                text: 'Finalizar',
                                icon: Icons.stop,
                                primary: true,
                                onPressed: _finish,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  AssessmentPauseOverlay(visible: _viewModel.isPaused),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
