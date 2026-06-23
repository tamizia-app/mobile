import 'package:flutter/material.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/widgets/assessment_cancel_dialog.dart';
import '../../../../core/widgets/assessment_pause_overlay.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/selectable_word_card.dart';
import '../../../../core/widgets/student_action_button.dart';
import '../../../exercises/data/services/exercise_service.dart';
import '../../data/services/assessment_service.dart';
import '../../domain/models/assessment_session.dart';
import '../viewmodels/choose_word_viewmodel.dart';

class ChooseWordPage extends StatefulWidget {
  const ChooseWordPage({
    required this.exerciseService,
    required this.assessmentService,
    super.key,
  });

  final ExerciseService exerciseService;
  final AssessmentService assessmentService;

  @override
  State<ChooseWordPage> createState() => _ChooseWordPageState();
}

class _ChooseWordPageState extends State<ChooseWordPage> {
  late final ChooseWordViewModel _viewModel;
  AssessmentSession? _session;

  @override
  void initState() {
    super.initState();
    _viewModel = ChooseWordViewModel(
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

  Future<void> _nextOrFinish() async {
    final wasLast = _viewModel.isLastQuestion;
    if (!_viewModel.nextQuestion()) {
      _showValidation();
      return;
    }
    if (wasLast) {
      await _finish();
    }
  }

  void _showValidation() {
    if (_viewModel.validationMessage == null) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(_viewModel.validationMessage!)));
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
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Stack(
                children: [
                  Column(
                    children: [
                      AppHeader(
                        title: '¡Elige la palabra!',
                        showBack: true,
                        centerTitle: true,
                        onBack: _confirmCancel,
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(16, 22, 16, 24),
                          child: Column(
                            children: [
                              IgnorePointer(
                                ignoring: _viewModel.isPaused,
                                child: Column(
                                  children: [
                                    Text(
                                      _viewModel.progressText,
                                      style: const TextStyle(
                                        color: Color(0xFF102532),
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 18),
                                    Text(
                                      _viewModel.currentQuestion.prompt,
                                      style: const TextStyle(
                                        color: Color(0xFF102532),
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 22),
                                    _QuestionImage(
                                      label:
                                          _viewModel.currentQuestion.imageLabel,
                                    ),
                                    const SizedBox(height: 28),
                                    ..._viewModel.currentQuestion.options.map(
                                      (option) => Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 18,
                                        ),
                                        child: SelectableWordCard(
                                          text: option,
                                          selected:
                                              _viewModel.selectedWord == option,
                                          onTap: () =>
                                              _viewModel.selectWord(option),
                                        ),
                                      ),
                                    ),
                                    if (_viewModel.feedback != null) ...[
                                      Text(
                                        _viewModel.feedback!,
                                        style: const TextStyle(
                                          color: Color(0xFF147A3A),
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                    ],
                                    if (_viewModel.validationMessage !=
                                        null) ...[
                                      Text(
                                        _viewModel.validationMessage!,
                                        style: const TextStyle(
                                          color: Color(0xFFB91C1C),
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                    ],
                                  ],
                                ),
                              ),
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
                                      onPressed: _viewModel.togglePause,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: StudentActionButton(
                                      text: _viewModel.isLastQuestion
                                          ? 'Finalizar'
                                          : 'Siguiente →',
                                      icon: _viewModel.isLastQuestion
                                          ? Icons.stop
                                          : Icons.arrow_forward,
                                      primary: true,
                                      onPressed: _nextOrFinish,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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

class _QuestionImage extends StatelessWidget {
  const _QuestionImage({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final icon = switch (label) {
      'casa' => Icons.home_rounded,
      'pato' => Icons.flutter_dash,
      _ => Icons.apple,
    };
    final color = switch (label) {
      'casa' => const Color(0xFF0056B3),
      'pato' => const Color(0xFFFFB020),
      _ => const Color(0xFFD9281E),
    };

    return Container(
      width: 300,
      height: 260,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(34),
        border: Border.all(color: const Color(0xFFD5ECF7), width: 4),
        boxShadow: const [
          BoxShadow(color: Color(0xFFD5ECF7), offset: Offset(0, 12)),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFD6EFEA),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Center(child: Icon(icon, color: color, size: 136)),
      ),
    );
  }
}
