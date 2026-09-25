import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/error_message.dart';
import '../../../../core/widgets/student_activity_layout.dart';
import '../../../../core/widgets/app_states.dart';
import '../../../../core/theme/app_tokens.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/widgets/drawing_canvas_placeholder.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/student_action_button.dart';
import '../../domain/models/attempt_exercise_args.dart';
import '../../domain/repositories/assessment_repository.dart';
import '../viewmodels/writing_assessment_viewmodel.dart';

class WritingAssessmentPage extends StatefulWidget {
  const WritingAssessmentPage({
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
  State<WritingAssessmentPage> createState() => _WritingAssessmentPageState();
}

class _WritingAssessmentPageState extends State<WritingAssessmentPage> {
  late final WritingAssessmentViewModel _viewModel;
  final _canvasKey = GlobalKey();
  final _introKey = GlobalKey();
  bool _requestedLoad = false;
  bool _introMeasureScheduled = false;
  double _introHeight = 300;

  @override
  void initState() {
    super.initState();
    _viewModel = WritingAssessmentViewModel(
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
    final capture = await _captureCanvas();
    if (!mounted || capture == null) {
      return;
    }
    final uploaded = await _viewModel.upload(
      imagePath: capture.path,
      canvasSize: capture.size,
    );
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

  Future<_CanvasCapture?> _captureCanvas() async {
    final context = _canvasKey.currentContext;
    if (context == null) {
      return null;
    }
    final boundary = context.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) {
      return null;
    }
    final image = await boundary.toImage(pixelRatio: 2);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      return null;
    }
    final directory = await getTemporaryDirectory();
    final file = File(
      '${directory.path}${Platform.pathSeparator}writing_${DateTime.now().millisecondsSinceEpoch}.png',
    );
    await file.writeAsBytes(byteData.buffer.asUint8List());
    return _CanvasCapture(path: file.path, size: boundary.size);
  }

  void _measureIntro() {
    if (_introMeasureScheduled) return;
    _introMeasureScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _introMeasureScheduled = false;
      if (!mounted) return;
      final height = _introKey.currentContext?.size?.height;
      if (height != null && (height - _introHeight).abs() > 1) {
        setState(() => _introHeight = height);
      }
    });
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _viewModel,
    builder: (context, _) => StudentActivityLayout(
      title: 'Escritura digital',
      onBack: widget.onBack ?? () => Navigator.pop(context, false),
      child: _viewModel.isLoading
          ? const AppLoadingState(message: 'Preparando la escritura…')
          : LayoutBuilder(
              builder: (context, constraints) {
                final shortestSide = MediaQuery.sizeOf(context).shortestSide;
                final minCanvasHeight = shortestSide >= 600
                    ? 440.0
                    : shortestSide >= 500
                    ? 380.0
                    : 360.0;
                return Column(
                  children: [
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, scrollConstraints) {
                          _measureIntro();
                          final availableHeight =
                              scrollConstraints.maxHeight - 32 - _introHeight;
                          final canvasHeight = availableHeight < minCanvasHeight
                              ? minCanvasHeight
                              : availableHeight;
                          return SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Column(
                                  key: _introKey,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    StudentTaskHeading(
                                      progress: _viewModel.progressText,
                                      instruction: _viewModel.prompt,
                                    ),
                                    const SizedBox(height: AppSpacing.lg),
                                    Container(
                                      padding: const EdgeInsets.all(
                                        AppSpacing.lg,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.secondaryContainer,
                                        borderRadius: BorderRadius.circular(20),
                                        border: const Border(
                                          left: BorderSide(
                                            color: AppColors.brandOrange,
                                            width: 5,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        _viewModel.textToWrite,
                                        style: AppTextStyles.studentStimulus
                                            .copyWith(
                                              color: AppColors.secondary,
                                            ),
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.xl),
                                    const Row(
                                      children: [
                                        Icon(
                                          Icons.draw_rounded,
                                          color: AppColors.secondary,
                                          size: 22,
                                        ),
                                        SizedBox(width: AppSpacing.sm),
                                        Expanded(
                                          child: Text(
                                            'Escribe aquí',
                                            style: AppTextStyles.studentTitle,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: AppSpacing.sm),
                                    Text(
                                      'Empieza en el primer renglón y sigue hacia abajo ↓',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.secondary,
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.sm),
                                  ],
                                ),
                                SizedBox(
                                  height: canvasHeight,
                                  child: Semantics(
                                    label:
                                        'Cuaderno de escritura. Empieza en el primer renglón.',
                                    child: RepaintBoundary(
                                      key: _canvasKey,
                                      child: DrawingCanvasPlaceholder(
                                        strokes: _viewModel.strokes,
                                        enabled: true,
                                        onPanStart: _viewModel.startStroke,
                                        onPanUpdate: _viewModel.appendStroke,
                                        onPanEnd: _viewModel.endStroke,
                                      ),
                                    ),
                                  ),
                                ),
                                if (_viewModel.errorMessage != null) ...[
                                  const SizedBox(height: AppSpacing.lg),
                                  ErrorMessage(text: _viewModel.errorMessage!),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                      child: AppActionGroup(
                        children: [
                          StudentActionButton(
                            text: 'Borrar',
                            icon: Icons.cleaning_services_outlined,
                            onPressed: _viewModel.clear,
                          ),
                          PrimaryButton(
                            text: 'Guardar escritura',
                            icon: Icons.check_rounded,
                            student: true,
                            isLoading: _viewModel.isUploading,
                            onPressed: _viewModel.isEvidenceLocked
                                ? null
                                : _upload,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
    ),
  );
}

class _CanvasCapture {
  const _CanvasCapture({required this.path, required this.size});

  final String path;
  final Size size;
}
