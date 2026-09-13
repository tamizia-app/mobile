import 'package:flutter/material.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/assessment_labels.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../domain/models/assessment_result.dart';
import '../../domain/models/attempt_exercise_args.dart';
import '../../domain/repositories/assessment_repository.dart';
import '../viewmodels/attempt_session_viewmodel.dart';

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
    if (argument is String && argument.isNotEmpty) {
      _attemptId = argument;
    }
    if (!_requestedLoad && _attemptId != null) {
      _requestedLoad = true;
      _viewModel.load(_attemptId!);
    }
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _openCurrentExercise() async {
    final exercise = _viewModel.currentExercise;
    final attempt = _viewModel.attempt;
    if (exercise == null || attempt == null) {
      return;
    }
    final route = _routeForType(exercise.type);
    if (route == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tipo no soportado: ${exercise.type ?? 'N/D'}')),
      );
      return;
    }
    final completed = await Navigator.pushNamed(
      context,
      route,
      arguments: AttemptExerciseArgs(
        attemptId: attempt.id,
        exerciseAttempt: exercise,
        exerciseIndex: _viewModel.currentIndex,
        totalExercises: _viewModel.exerciseAttempts.length,
      ),
    );
    if (!mounted || completed != true) {
      return;
    }
    if (_viewModel.isLastExercise) {
      final result = await _viewModel.finish();
      if (!mounted || result == null) {
        return;
      }
      _openResult(result);
    } else {
      _viewModel.markCurrentCompleted();
    }
  }

  Future<void> _finishNow() async {
    final result = await _viewModel.finish();
    if (!mounted || result == null) {
      return;
    }
    _openResult(result);
  }

  void _openResult(AssessmentResult result) {
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.assessmentResult,
      arguments: result,
    );
  }

  String? _routeForType(String? rawType) {
    final type = rawType?.trim().toUpperCase();
    return switch (type) {
      'MULTIPLE_CHOICE' => AppRoutes.assessmentChooseWord,
      'ORDER_SYLLABLES' => AppRoutes.assessmentBuildWord,
      'READING_SPEAKING' || 'LISTENING_SPEAKING' => AppRoutes.assessmentReading,
      'READING_WRITING' || 'LISTENING_WRITING' => AppRoutes.assessmentWriting,
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.teacherBackground,
          body: Column(
            children: [
              AppHeader(
                title: 'Sesión del intento',
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
    if (_viewModel.errorMessage != null || _viewModel.attempt == null) {
      return _ErrorState(
        message: _viewModel.errorMessage ?? 'No se pudo cargar el intento.',
        onRetry: _attemptId == null ? null : () => _viewModel.load(_attemptId!),
      );
    }
    final exercise = _viewModel.currentExercise;
    if (exercise == null) {
      return _ErrorState(
        message: 'El intento no contiene ejercicios.',
        onRetry: _attemptId == null ? null : () => _viewModel.load(_attemptId!),
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 24, 18, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Progreso ${_viewModel.progressText}',
                  style: const TextStyle(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  exercise.displayName,
                  style: const TextStyle(
                    color: Color(0xFF102532),
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  exercise.instructions ??
                      exercise.prompt ??
                      'Sin instrucciones.',
                  style: const TextStyle(
                    color: AppColors.neutralGray,
                    fontSize: 15,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 14),
                _InfoRow(label: 'Tipo', value: translateExerciseType(exercise.type)),
              ],
            ),
          ),
          if (_viewModel.errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              _viewModel.errorMessage!,
              style: const TextStyle(
                color: AppColors.errorRed,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 24),
          PrimaryButton(
            text: 'Abrir ejercicio',
            icon: Icons.play_arrow_rounded,
            onPressed: _openCurrentExercise,
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _viewModel.isFinishing ? null : _finishNow,
            icon: const Icon(Icons.flag_outlined),
            label: Text(
              _viewModel.isFinishing ? 'Finalizando...' : 'Finalizar intento',
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 136,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.mutedText),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 12),
              TextButton(onPressed: onRetry, child: const Text('Reintentar')),
            ],
          ],
        ),
      ),
    );
  }
}
