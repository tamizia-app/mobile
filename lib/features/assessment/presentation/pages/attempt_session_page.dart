import 'package:flutter/material.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/app_states.dart';
import '../../domain/models/attempt_exercise_args.dart';
import '../../domain/repositories/assessment_repository.dart';
import '../viewmodels/attempt_session_viewmodel.dart';
import 'build_word_page.dart';
import 'choose_word_page.dart';
import 'reading_assessment_page.dart';
import 'writing_assessment_page.dart';

class AttemptSessionPage extends StatefulWidget {
  const AttemptSessionPage({required this.assessmentRepository, super.key});
  final AssessmentRepository assessmentRepository;
  @override
  State<AttemptSessionPage> createState() => _AttemptSessionPageState();
}

class _AttemptSessionPageState extends State<AttemptSessionPage> {
  late final AttemptSessionViewModel _viewModel;
  String? _attemptId;
  bool _requestedLoad = false;
  bool _dialogOpen = false;
  bool _activityBusy = false;
  bool _completedAll = false;
  bool _openingResult = false;

  @override
  void initState() {
    super.initState();
    _viewModel = AttemptSessionViewModel(
      assessmentRepository: widget.assessmentRepository,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final argument = ModalRoute.of(context)?.settings.arguments;
    if (!_requestedLoad && argument is String && argument.isNotEmpty) {
      _requestedLoad = true;
      _attemptId = argument;
      _load();
    }
  }

  Future<void> _load() async {
    await _viewModel.load(_attemptId!);
    if (!mounted) return;
    if (_viewModel.attempt != null &&
        _viewModel.exerciseAttempts.isNotEmpty &&
        _viewModel.currentExercise == null) {
      _completedAll = true;
      await _finish();
    }
  }

  void _completed() {
    if (_viewModel.isFinishing || _openingResult || _dialogOpen) return;
    _activityBusy = false;
    if (_viewModel.isLastExercise) {
      setState(() => _completedAll = true);
      _finish();
    } else {
      _viewModel.markCurrentCompleted();
    }
  }

  Future<void> _requestFinish() async {
    if (_dialogOpen ||
        _activityBusy ||
        _viewModel.isLoading ||
        _viewModel.isFinishing ||
        _openingResult) {
      return;
    }
    if (_viewModel.attempt == null) {
      Navigator.maybePop(context);
      return;
    }
    _dialogOpen = true;
    final finish = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Desea finalizar la prueba?'),
        content: const Text(
          'Se conservarán las respuestas guardadas. La respuesta en curso no se guardará.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No, continuar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sí, finalizar'),
          ),
        ],
      ),
    );
    _dialogOpen = false;
    if (mounted && finish == true) await _finish();
  }

  Future<void> _finish() async {
    if (_viewModel.isFinishing || _openingResult) return;
    final result = await _viewModel.finish();
    if (!mounted) return;
    if (result != null) {
      _openingResult = true;
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.assessmentResult,
        arguments: result,
      );
    } else if (!_completedAll) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _viewModel.errorMessage ??
                'No se pudo finalizar. Inténtalo nuevamente.',
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _viewModel,
    builder: (context, _) => PopScope<Object?>(
      canPop: _viewModel.attempt == null && !_viewModel.isLoading,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _requestFinish();
      },
      child: Stack(
        children: [
          AbsorbPointer(absorbing: _viewModel.isFinishing, child: _content()),
          if (_viewModel.isFinishing && !_completedAll)
            const Positioned.fill(
              child: ColoredBox(
                color: Colors.white70,
                child: AppLoadingState(message: 'Finalizando la prueba…'),
              ),
            ),
        ],
      ),
    ),
  );

  Widget _content() {
    if (_completedAll) {
      return _shell(
        _viewModel.isFinishing || _openingResult
            ? const AppLoadingState(
                message: 'Estamos procesando la evaluación…',
              )
            : AppEmptyState(
                title: 'No pudimos finalizar la prueba',
                message: _viewModel.errorMessage ?? 'Inténtalo nuevamente.',
                icon: Icons.sync_problem,
                actionLabel: 'Reintentar',
                onAction: _finish,
              ),
      );
    }
    if (_viewModel.isLoading) {
      return _shell(const AppLoadingState(message: 'Cargando actividad…'));
    }
    final exercise = _viewModel.currentExercise;
    if (exercise == null) {
      return _shell(
        AppEmptyState(
          title: 'No pudimos cargar la actividad',
          message:
              _viewModel.errorMessage ?? 'El intento no contiene ejercicios.',
          icon: Icons.error_outline,
          actionLabel: 'Reintentar',
          onAction: _attemptId == null ? null : _load,
        ),
      );
    }
    final args = AttemptExerciseArgs(
      attemptId: _viewModel.attempt!.id,
      exerciseAttempt: exercise,
      exerciseIndex: _viewModel.currentIndex,
      totalExercises: _viewModel.exerciseAttempts.length,
    );
    // A new exercise gets a fresh state; cancelling the finish dialog keeps it.
    final key = ValueKey(exercise.id);
    void busy(bool value) {
      _activityBusy = value;
    }

    return switch (exercise.type?.trim().toUpperCase()) {
      'MULTIPLE_CHOICE' => ChooseWordPage(
        key: key,
        assessmentRepository: widget.assessmentRepository,
        args: args,
        onCompleted: _completed,
        onBack: _requestFinish,
        onBusyChanged: busy,
      ),
      'ORDER_SYLLABLES' => BuildWordPage(
        key: key,
        assessmentRepository: widget.assessmentRepository,
        args: args,
        onCompleted: _completed,
        onBack: _requestFinish,
        onBusyChanged: busy,
      ),
      'READING_SPEAKING' || 'LISTENING_SPEAKING' => ReadingAssessmentPage(
        key: key,
        assessmentRepository: widget.assessmentRepository,
        args: args,
        onCompleted: _completed,
        onBack: _requestFinish,
        onBusyChanged: busy,
      ),
      'READING_WRITING' || 'LISTENING_WRITING' => WritingAssessmentPage(
        key: key,
        assessmentRepository: widget.assessmentRepository,
        args: args,
        onCompleted: _completed,
        onBack: _requestFinish,
        onBusyChanged: busy,
      ),
      _ => _shell(
        const AppEmptyState(
          title: 'Actividad no disponible',
          message: 'Este tipo de ejercicio no está disponible en esta versión.',
          icon: Icons.info_outline,
        ),
      ),
    };
  }

  Widget _shell(Widget child) => Scaffold(
    body: Column(
      children: [
        AppHeader(title: 'Evaluación', showBack: true, onBack: _requestFinish),
        Expanded(child: child),
      ],
    ),
  );
}
