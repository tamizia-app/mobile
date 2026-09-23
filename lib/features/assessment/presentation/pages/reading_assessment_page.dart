import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/error_message.dart';
import '../../../../core/widgets/student_activity_layout.dart';
import '../../../../core/widgets/app_states.dart';
import '../../../../core/theme/app_tokens.dart';

import '../../../../core/widgets/assessment_timer.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../domain/models/attempt_exercise_args.dart';
import '../../domain/repositories/assessment_repository.dart';
import '../viewmodels/reading_assessment_viewmodel.dart';

class ReadingAssessmentPage extends StatefulWidget {
  const ReadingAssessmentPage({
    required this.assessmentRepository,
    this.args,
    this.onCompleted,
    this.onBack,
    this.onBusyChanged,
    super.key,
  });

  final AssessmentRepository assessmentRepository;
  final AttemptExerciseArgs? args;
  final VoidCallback? onCompleted;
  final VoidCallback? onBack;
  final ValueChanged<bool>? onBusyChanged;

  @override
  State<ReadingAssessmentPage> createState() => _ReadingAssessmentPageState();
}

class _ReadingAssessmentPageState extends State<ReadingAssessmentPage> {
  late final ReadingAssessmentViewModel _viewModel;
  bool _requestedLoad = false;

  @override
  void initState() {
    super.initState();
    _viewModel = ReadingAssessmentViewModel(
      assessmentRepository: widget.assessmentRepository,
    );
    _viewModel.addListener(
      () => widget.onBusyChanged?.call(
        _viewModel.isLoading || _viewModel.isUploading,
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final argument = widget.args ?? ModalRoute.of(context)?.settings.arguments;
    if (!_requestedLoad && argument is AttemptExerciseArgs) {
      _requestedLoad = true;
      _viewModel.load(argument);
    }
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _upload() async {
    final uploaded = await _viewModel.upload();
    if (!mounted) {
      return;
    }
    if (uploaded) {
      if (widget.onCompleted != null) {
        widget.onCompleted!();
      } else {
        Navigator.pop(context, true);
      }
      return;
    }
    if (_viewModel.errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_viewModel.errorMessage!)));
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _viewModel,
    builder: (context, _) => StudentActivityLayout(
      title: 'Lectura en voz alta',
      onBack: widget.onBack ?? () => Navigator.pop(context, false),
      child: _viewModel.isLoading
          ? const AppLoadingState(message: 'Preparando la lectura…')
          : SingleChildScrollView(
              padding: AppSpacing.page,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  StudentTaskHeading(
                    progress: _viewModel.progressText,
                    instruction: _viewModel.prompt,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Container(
                    constraints: const BoxConstraints(minHeight: 200),
                    padding: AppSpacing.page,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: const Border(
                        left: BorderSide(
                          color: AppColors.studentTeal,
                          width: 5,
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.studentTeal.withValues(alpha: 0.07),
                          offset: const Offset(0, 5),
                          blurRadius: 14,
                        ),
                      ],
                    ),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _viewModel.textToRead,
                      style: AppTextStyles.studentStimulus,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  PrimaryButton(
                    text: _viewModel.isRecording
                        ? 'Detener grabación'
                        : 'Grabar mi lectura',
                    icon: _viewModel.isRecording
                        ? Icons.stop_circle_outlined
                        : Icons.mic_none_outlined,
                    student: true,
                    onPressed:
                        _viewModel.isUploading || _viewModel.isEvidenceLocked
                        ? null
                        : _viewModel.toggleRecording,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      _recordingLabel(),
                      style: AppTextStyles.bodySmall,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: AssessmentTimer(
                      minutes: _viewModel.minutes,
                      seconds: _viewModel.seconds,
                    ),
                  ),
                  if (_viewModel.errorMessage != null) ...[
                    const SizedBox(height: AppSpacing.lg),
                    ErrorMessage(text: _viewModel.errorMessage!),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  PrimaryButton(
                    text: 'Guardar lectura',
                    icon: Icons.check_rounded,
                    student: true,
                    variant: AppButtonVariant.secondary,
                    isLoading: _viewModel.isUploading,
                    onPressed:
                        _viewModel.isEvidenceLocked || _viewModel.isRecording
                        ? null
                        : _upload,
                  ),
                ],
              ),
            ),
    ),
  );

  String _recordingLabel() {
    if (_viewModel.isPaused) {
      return 'Grabación pausada';
    }
    if (_viewModel.isRecording) {
      return 'Te estamos escuchando. Toca «Detener grabación» al terminar.';
    }
    if (_viewModel.audioPath != null) {
      return 'Tu lectura está lista. Toca “Guardar lectura” para continuar.';
    }
    return 'Cuando estés listo, toca «Grabar mi lectura».';
  }
}
