import 'package:flutter/material.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/widgets/assessment_cancel_dialog.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/student_action_button.dart';
import '../../../../core/widgets/student_success_banner.dart';
import '../../../exercises/data/services/exercise_service.dart';
import '../../data/services/assessment_service.dart';
import '../../domain/models/assessment_session.dart';
import '../viewmodels/build_word_viewmodel.dart';

class BuildWordPage extends StatefulWidget {
  const BuildWordPage({
    required this.exerciseService,
    required this.assessmentService,
    super.key,
  });

  final ExerciseService exerciseService;
  final AssessmentService assessmentService;

  @override
  State<BuildWordPage> createState() => _BuildWordPageState();
}

class _BuildWordPageState extends State<BuildWordPage> {
  late final BuildWordViewModel _viewModel;
  AssessmentSession? _session;

  @override
  void initState() {
    super.initState();
    _viewModel = BuildWordViewModel(
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
              child: Column(
                children: [
                  AppHeader(
                    title: 'Forma la palabra',
                    showBack: true,
                    centerTitle: true,
                    onBack: _confirmCancel,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 22, 16, 24),
                      child: IgnorePointer(
                        ignoring: _viewModel.isPaused,
                        child: Column(
                          children: [
                            Text(
                              _viewModel.progressText,
                              style: const TextStyle(
                                color: Color(0xFF5B3A9A),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              _viewModel.currentQuestion.prompt,
                              style: const TextStyle(
                                color: Color(0xFF5B3A9A),
                                fontSize: 17,
                              ),
                            ),
                            const SizedBox(height: 22),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 30),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF2EAF6),
                                borderRadius: BorderRadius.circular(36),
                                border: Border.all(
                                  color: const Color(0xFFCFC3D7),
                                  width: 4,
                                ),
                              ),
                              child: Column(
                                children: [
                                  const Text(
                                    'Arrastra aquí',
                                    style: TextStyle(
                                      color: Color(0xFF25212A),
                                      fontSize: 27,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Suelta las sílabas en orden',
                                    style: TextStyle(
                                      color: Color(0xFF5F5665),
                                      fontSize: 17,
                                    ),
                                  ),
                                  const SizedBox(height: 30),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(2, (index) {
                                      return _SyllableTargetBox(
                                        text: _viewModel.placedSyllables[index],
                                        onAccept: (syllable) => _viewModel
                                            .placeSyllableAt(syllable, index),
                                        onTap: () => _viewModel
                                            .removePlacedSyllable(index),
                                      );
                                    }),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            StudentSuccessBanner(
                              text:
                                  _viewModel.feedback ??
                                  '¡Genial! Lo estás haciendo bien',
                            ),
                            if (_viewModel.validationMessage != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                _viewModel.validationMessage!,
                                style: const TextStyle(
                                  color: Color(0xFFB91C1C),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                            const SizedBox(height: 26),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: _viewModel.availableSyllables
                                  .map(
                                    (syllable) => _SyllableButton(
                                      text: syllable,
                                      onTap: () =>
                                          _viewModel.selectSyllable(syllable),
                                    ),
                                  )
                                  .toList(),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              height: 64,
                              child: FilledButton(
                                onPressed: _viewModel.check,
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF640A),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(26),
                                  ),
                                ),
                                child: const Text(
                                  'COMPROBAR',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
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
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SyllableTargetBox extends StatelessWidget {
  const _SyllableTargetBox({
    required this.text,
    required this.onAccept,
    required this.onTap,
  });

  final String? text;
  final ValueChanged<String> onAccept;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DragTarget<String>(
      onAcceptWithDetails: (details) => onAccept(details.data),
      builder: (context, candidateData, rejectedData) {
        return InkWell(
          onTap: text == null ? null : onTap,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            width: 80,
            height: 80,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: candidateData.isEmpty ? null : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFC9C1CF), width: 4),
            ),
            child: Text(
              text ?? '',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
            ),
          ),
        );
      },
    );
  }
}

class _SyllableButton extends StatelessWidget {
  const _SyllableButton({required this.text, required this.onTap});

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final child = _SyllableTile(text: text);
    return Draggable<String>(
      data: text,
      feedback: Material(
        color: Colors.transparent,
        child: _SyllableTile(text: text, elevated: true),
      ),
      childWhenDragging: Opacity(opacity: 0.35, child: child),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: child,
      ),
    );
  }
}

class _SyllableTile extends StatelessWidget {
  const _SyllableTile({required this.text, this.elevated = false});

  final String text;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 92,
      height: 92,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFDDF2FF),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFACDDF3),
            offset: Offset(0, elevated ? 8 : 5),
            blurRadius: elevated ? 8 : 0,
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF0056B3),
          fontSize: 32,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
