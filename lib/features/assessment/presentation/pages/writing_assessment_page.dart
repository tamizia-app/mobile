import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/drawing_canvas_placeholder.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/student_action_button.dart';
import '../../domain/models/attempt_exercise_args.dart';
import '../../domain/repositories/assessment_repository.dart';
import '../viewmodels/writing_assessment_viewmodel.dart';

class WritingAssessmentPage extends StatefulWidget {
  const WritingAssessmentPage({required this.assessmentRepository, super.key});

  final AssessmentRepository assessmentRepository;

  @override
  State<WritingAssessmentPage> createState() => _WritingAssessmentPageState();
}

class _WritingAssessmentPageState extends State<WritingAssessmentPage> {
  late final WritingAssessmentViewModel _viewModel;
  final _canvasKey = GlobalKey();
  bool _requestedLoad = false;

  @override
  void initState() {
    super.initState();
    _viewModel = WritingAssessmentViewModel(
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
      Navigator.pop(context, true);
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppHeader(
                    title: 'Escritura digital',
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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 10),
        Text(
          _viewModel.progressText,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.primaryBlue,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE8EDF2)),
          ),
          child: Column(
            children: [
              Text(_viewModel.prompt, textAlign: TextAlign.center),
              const SizedBox(height: 4),
              Text(
                _viewModel.textToWrite,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFFF5B0A),
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Escribe aquí',
          style: TextStyle(color: Color(0xFF8A8F98), fontSize: 16),
        ),
        const SizedBox(height: 10),
        Expanded(
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
              child: PrimaryButton(
                text: 'Subir',
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
}

class _CanvasCapture {
  const _CanvasCapture({required this.path, required this.size});

  final String path;
  final Size size;
}
