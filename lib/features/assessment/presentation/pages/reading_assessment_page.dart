import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/assessment_timer.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/student_action_button.dart';
import '../../domain/models/attempt_exercise_args.dart';
import '../../domain/repositories/assessment_repository.dart';
import '../viewmodels/reading_assessment_viewmodel.dart';

class ReadingAssessmentPage extends StatefulWidget {
  const ReadingAssessmentPage({required this.assessmentRepository, super.key});

  final AssessmentRepository assessmentRepository;

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
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final argument = ModalRoute.of(context)?.settings.arguments;
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
      Navigator.pop(context, true);
      return;
    }
    if (_viewModel.errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_viewModel.errorMessage!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFFCFAFB),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Column(
                children: [
                  AppHeader(
                    title: 'Lectura en voz alta',
                    showBack: true,
                    centerTitle: true,
                    onBack: () => Navigator.pop(context, false),
                  ),
                  Expanded(child: _buildContent()),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    if (_viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Column(
      children: [
        const SizedBox(height: 8),
        Text(
          _viewModel.progressText,
          style: const TextStyle(
            color: AppColors.primaryBlue,
            fontWeight: FontWeight.w900,
          ),
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
              _viewModel.textToRead,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF231610),
                fontSize: 30,
                fontWeight: FontWeight.w900,
                height: 1.4,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        GestureDetector(
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
                _viewModel.isRecording ? Icons.stop : Icons.mic,
                color: Colors.white,
                size: 34,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          _recordingLabel(),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.neutralGray,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (_viewModel.errorMessage != null) ...[
          const SizedBox(height: 8),
          Text(
            _viewModel.errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.errorRed,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: StudentActionButton(
                text: _viewModel.isPaused ? 'Reanudar' : 'Pausar',
                icon: _viewModel.isPaused ? Icons.play_arrow : Icons.pause,
                onPressed: _viewModel.isRecording
                    ? _viewModel.togglePause
                    : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: PrimaryButton(
                text: 'Subir audio',
                icon: Icons.cloud_upload_outlined,
                isLoading: _viewModel.isUploading,
                onPressed: _upload,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _recordingLabel() {
    if (_viewModel.isPaused) {
      return 'Grabacion pausada';
    }
    if (_viewModel.isRecording) {
      return 'Grabando... toca el microfono para detener';
    }
    if (_viewModel.audioPath != null) {
      return 'Audio temporal listo para subir';
    }
    return 'Toca el microfono para grabar';
  }
}
