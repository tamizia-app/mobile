import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/assessment_labels.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/error_message.dart';
import '../../domain/models/attempt_review.dart';
import '../../domain/models/exercise_integrity.dart';
import '../../domain/repositories/assessment_repository.dart';

class AttemptReviewPage extends StatefulWidget {
  const AttemptReviewPage({
    required this.assessmentRepository,
    required this.attemptId,
    super.key,
  });

  final AssessmentRepository assessmentRepository;
  final String attemptId;

  @override
  State<AttemptReviewPage> createState() => _AttemptReviewPageState();
}

class _AttemptReviewPageState extends State<AttemptReviewPage> {
  AttemptReview? _review;
  bool _isLoading = true;
  bool _isRepeating = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadReview();
  }

  Future<void> _loadReview() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final review = await widget.assessmentRepository.getAttemptReview(
        widget.attemptId,
      );
      setState(() {
        _review = review;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'No se pudo cargar la revisión del intento.';
        _isLoading = false;
      });
    }
  }

  Future<void> _repeatAttempt() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Repetir evaluación'),
        content: const Text(
          'Se creará un nuevo intento basado en esta evaluación. ¿Deseas continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Repetir'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _isRepeating = true);
    try {
      final response = await widget.assessmentRepository.repeatAttempt(
        widget.attemptId,
        reason: 'Repetición solicitada por el docente',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Nuevo intento creado.')));
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.assessmentAttemptSession,
        arguments: response.newAttemptId,
      );
    } catch (e) {
      if (!mounted) return;
      debugPrint('Repeat attempt error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo repetir el intento.')),
      );
    } finally {
      if (mounted) setState(() => _isRepeating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.teacherBackground,
      body: Column(
        children: [
          AppHeader(
            title: 'Revisión del intento',
            showBack: true,
            centerTitle: true,
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: AppColors.errorRed,
                size: 48,
              ),
              const SizedBox(height: 16),
              ErrorMessage(text: _errorMessage!),
              const SizedBox(height: 20),
              PrimaryButton(
                text: 'Reintentar',
                icon: Icons.refresh,
                onPressed: _loadReview,
              ),
            ],
          ),
        ),
      );
    }
    final review = _review!;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _StudentInfoCard(student: review.student),
          const SizedBox(height: 18),
          _AssessmentInfoCard(review: review),
          const SizedBox(height: 18),
          if (review.result != null) _ResultCard(result: review.result!),
          if (review.exerciseReviews.isNotEmpty) ...[
            const SizedBox(height: 18),
            const Text(
              'Ejercicios',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            ...review.exerciseReviews.asMap().entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ExerciseReviewCard(
                  index: entry.key,
                  exercise: entry.value,
                ),
              ),
            ),
          ],
          if (review.status.trim().toUpperCase() == 'COMPLETED') ...[
            const SizedBox(height: 26),
            PrimaryButton(
              text: 'Repetir evaluación',
              icon: Icons.replay,
              isLoading: _isRepeating,
              onPressed: _isRepeating ? null : _repeatAttempt,
            ),
          ],
          const SizedBox(height: 12),
          PrimaryButton(
            text: 'Volver al historial',
            icon: Icons.arrow_back,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

class _StudentInfoCard extends StatelessWidget {
  const _StudentInfoCard({required this.student});

  final AttemptReviewStudent? student;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Estudiante',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          if (student == null)
            const Text(
              'No disponible',
              style: TextStyle(color: AppColors.mutedText),
            )
          else ...[
            _row('Código', student!.code),
            _row('Edad', '${student!.age}'),
            _row('Género', translateGender(student!.gender)),
            if (student!.classroom != null)
              _row('Aula', student!.classroom!.name),
          ],
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.mutedText),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _AssessmentInfoCard extends StatelessWidget {
  const _AssessmentInfoCard({required this.review});

  final AttemptReview review;

  @override
  Widget build(BuildContext context) {
    final startedStr = review.startedAt != null
        ? '${review.startedAt!.day}/${review.startedAt!.month}/${review.startedAt!.year} ${review.startedAt!.hour}:${review.startedAt!.minute.toString().padLeft(2, '0')}'
        : '—';
    final completedStr = review.completedAt != null
        ? '${review.completedAt!.day}/${review.completedAt!.month}/${review.completedAt!.year} ${review.completedAt!.hour}:${review.completedAt!.minute.toString().padLeft(2, '0')}'
        : '—';
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Evaluación',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          _row('Nombre', review.assessment?.title ?? '—'),
          _row('Estado', translateAttemptStatus(review.status)),
          _row('Iniciado', startedStr),
          _row('Completado', completedStr),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.mutedText),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result});

  final AttemptReviewResult result;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          if (result.finalScore != null) ...[
            Text(
              '${result.finalScore!.toStringAsFixed(1)}%',
              style: const TextStyle(
                color: AppColors.primaryBlue,
                fontSize: 32,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Puntaje final',
              style: TextStyle(color: AppColors.mutedText, fontSize: 13),
            ),
          ],
          if (result.interventionLevel != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: _levelColor(
                  result.interventionLevel,
                ).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Nivel: ${translateInterventionLevel(result.interventionLevel)}',
                style: TextStyle(
                  color: _levelColor(result.interventionLevel),
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _levelColor(String? level) {
    switch (level?.toUpperCase()) {
      case 'LOW':
        return AppColors.successGreen;
      case 'MEDIUM':
        return AppColors.secondaryOrange;
      case 'HIGH':
        return AppColors.errorRed;
      default:
        return AppColors.mutedText;
    }
  }
}

class _ExerciseReviewCard extends StatelessWidget {
  const _ExerciseReviewCard({required this.index, required this.exercise});

  final int index;
  final ExerciseReview exercise;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.title,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          translateExerciseType(exercise.type),
                          style: const TextStyle(
                            color: AppColors.mutedText,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          translateExerciseStatus(exercise.status),
                          style: const TextStyle(
                            color: AppColors.mutedText,
                            fontSize: 12,
                          ),
                        ),
                        if (exercise.score != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            '${exercise.score!.toStringAsFixed(1)}%',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if (exercise.reviewRequired)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryOrange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Revisar',
                    style: TextStyle(
                      color: AppColors.secondaryOrange,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),
          if (exercise.reviewReasons.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...exercise.reviewReasons.map(
              (reason) => Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  '- ${translateReviewReason(reason)}',
                  style: const TextStyle(
                    color: AppColors.secondaryOrange,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 10),
          _buildTypeSpecificDetails(context),
        ],
      ),
    );
  }

  Widget _buildTypeSpecificDetails(BuildContext context) {
    final type = exercise.type.trim().toUpperCase();

    if (type == 'MULTIPLE_CHOICE') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (exercise.questionText != null)
            _detailRow('Pregunta', exercise.questionText!),
          if (exercise.response?['selected_text'] != null)
            _detailRow(
              'Seleccionado',
              exercise.response!['selected_text'] as String,
              isCorrect: exercise.response?['is_correct'] == true,
              isIncorrect: exercise.response?['is_correct'] == false,
            ),
          if (exercise.expected?['correct_text'] != null)
            _detailRow(
              'Correcto',
              exercise.expected!['correct_text'] as String,
            ),
        ],
      );
    }

    if (type == 'ORDER_SYLLABLES') {
      final syllables = exercise.response?['selected_syllables'];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (syllables is List) _detailRow('Sílabas', syllables.join(' ')),
          if (exercise.response?['formed_word'] != null)
            _detailRow(
              'Palabra formada',
              exercise.response!['formed_word'] as String,
              isCorrect: exercise.response?['is_correct'] == true,
              isIncorrect: exercise.response?['is_correct'] == false,
            ),
          if (exercise.expected?['correct_word'] != null)
            _detailRow(
              'Palabra correcta',
              exercise.expected!['correct_word'] as String,
            ),
        ],
      );
    }

    if (type == 'READING_SPEAKING' || type == 'LISTENING_SPEAKING') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (exercise.referenceText != null)
            _detailRow('Texto de referencia', exercise.referenceText!),
          if (exercise.response?['free_transcription_text'] != null)
            _detailRow(
              'Transcripción',
              exercise.response!['free_transcription_text'] as String,
            ),
          if (exercise.response?['recognized_text'] != null)
            _detailRow(
              'Texto reconocido',
              exercise.response!['recognized_text'] as String,
            ),
          _pronunciationMetrics(exercise.scoringComponents),
          if (exercise.response?['audio_url'] != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: _AudioPlayer(
                url: exercise.response!['audio_url'] as String,
              ),
            ),
        ],
      );
    }

    if (type == 'READING_WRITING' || type == 'LISTENING_WRITING') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (exercise.referenceText != null)
            _detailRow('Texto de referencia', exercise.referenceText!),
          if (exercise.response?['recognized_text'] != null)
            _detailRow(
              'Texto reconocido (OCR)',
              exercise.response!['recognized_text'] as String,
            ),
          if (exercise.response?['image_url'] != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: _ImagePreview(
                url: exercise.response!['image_url'] as String,
              ),
            ),
          _ocrMetrics(exercise.scoringComponents),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _detailRow(
    String label,
    String value, {
    bool? isCorrect,
    bool? isIncorrect,
  }) {
    final icon = isCorrect == true
        ? Icons.check_circle
        : isIncorrect == true
        ? Icons.cancel
        : null;
    final iconColor = isCorrect == true
        ? AppColors.successGreen
        : isIncorrect == true
        ? AppColors.errorRed
        : null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              '$label:',
              style: const TextStyle(color: AppColors.mutedText, fontSize: 12),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(value, style: const TextStyle(fontSize: 12)),
                ),
                if (icon != null) ...[
                  const SizedBox(width: 4),
                  Icon(icon, color: iconColor, size: 16),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pronunciationMetrics(ScoringComponents metrics) {
    final chips = <Widget>[];
    if (metrics.pronunciationScore != null) {
      chips.add(
        _metricChip(
          'Pron',
          '${metrics.pronunciationScore!.toStringAsFixed(0)}%',
        ),
      );
    }
    if (metrics.accuracyScore != null) {
      chips.add(
        _metricChip('Prec', '${metrics.accuracyScore!.toStringAsFixed(0)}%'),
      );
    }
    if (metrics.fluencyScore != null) {
      chips.add(
        _metricChip('Fluid', '${metrics.fluencyScore!.toStringAsFixed(0)}%'),
      );
    }
    if (metrics.completenessScore != null) {
      chips.add(
        _metricChip(
          'Comp',
          '${metrics.completenessScore!.toStringAsFixed(0)}%',
        ),
      );
    }
    if (metrics.lexicalMatch != null) {
      chips.add(
        _metricChip('Lex', '${metrics.lexicalMatch!.toStringAsFixed(0)}%'),
      );
    }
    if (chips.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Métricas de pronunciación:',
            style: TextStyle(
              color: AppColors.mutedText,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Wrap(spacing: 8, runSpacing: 4, children: chips),
        ],
      ),
    );
  }

  Widget _ocrMetrics(ScoringComponents metrics) {
    final chips = <Widget>[];
    if (metrics.confidenceAvg != null) {
      chips.add(
        _metricChip(
          'Conf',
          '${(metrics.confidenceAvg! * 100).toStringAsFixed(0)}%',
        ),
      );
    }
    if (metrics.similarityScore != null) {
      chips.add(
        _metricChip('Sim', '${metrics.similarityScore!.toStringAsFixed(0)}%'),
      );
    }
    if (metrics.cer != null) {
      chips.add(
        _metricChip('CER', '${(metrics.cer! * 100).toStringAsFixed(0)}%'),
      );
    }
    if (metrics.wer != null) {
      chips.add(
        _metricChip('WER', '${(metrics.wer! * 100).toStringAsFixed(0)}%'),
      );
    }
    if (chips.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Métricas de OCR:',
            style: TextStyle(
              color: AppColors.mutedText,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Wrap(spacing: 8, runSpacing: 4, children: chips),
        ],
      ),
    );
  }

  Widget _metricChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.infoBlueLight,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(
          color: AppColors.primaryBlue,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Ampliar imagen de la prueba de escritura',
      child: InkWell(
        onTap: () => _showExpandedImage(context, url),
        borderRadius: BorderRadius.circular(6),
        child: Container(
          height: 120,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.backgroundLight,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                url,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, progress) => progress == null
                    ? child
                    : const Center(child: CircularProgressIndicator()),
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: AppColors.mutedText,
                    size: 36,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  color: Colors.black54,
                  child: const Text(
                    'Tocar para ampliar',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _showExpandedImage(BuildContext context, String url) {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black87,
    builder: (context) => Dialog(
      insetPadding: const EdgeInsets.all(16),
      backgroundColor: Colors.black,
      child: SizedBox(
        width: double.infinity,
        height: MediaQuery.sizeOf(context).height * 0.8,
        child: Stack(
          children: [
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 5,
                  child: Center(
                    child: Image.network(
                      url,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, progress) =>
                          progress == null
                          ? child
                          : const CircularProgressIndicator(
                              color: Colors.white,
                            ),
                      errorBuilder: (context, error, stackTrace) =>
                          const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.broken_image_outlined,
                                color: Colors.white70,
                                size: 52,
                              ),
                              SizedBox(height: 12),
                              Text(
                                'No se pudo cargar la imagen.',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton.filled(
                tooltip: 'Cerrar imagen',
                onPressed: () => Navigator.pop(context),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black54,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.close),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _AudioPlayer extends StatefulWidget {
  const _AudioPlayer({required this.url});

  final String url;

  @override
  State<_AudioPlayer> createState() => _AudioPlayerState();
}

class _AudioPlayerState extends State<_AudioPlayer> {
  late final AudioPlayer _player;
  late final StreamSubscription<Duration> _durationSubscription;
  late final StreamSubscription<Duration> _positionSubscription;
  late final StreamSubscription<PlayerState> _stateSubscription;
  late final StreamSubscription<void> _completeSubscription;

  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  PlayerState _state = PlayerState.stopped;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _durationSubscription = _player.onDurationChanged.listen((duration) {
      if (mounted) setState(() => _duration = duration);
    });
    _positionSubscription = _player.onPositionChanged.listen((position) {
      if (mounted) setState(() => _position = position);
    });
    _stateSubscription = _player.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _state = state;
          _isLoading = false;
        });
      }
    });
    _completeSubscription = _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _position = Duration.zero);
    });
  }

  @override
  void didUpdateWidget(covariant _AudioPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _player.stop();
      setState(() {
        _duration = Duration.zero;
        _position = Duration.zero;
        _state = PlayerState.stopped;
        _errorMessage = null;
      });
    }
  }

  Future<void> _togglePlayback() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_state == PlayerState.playing) {
        await _player.pause();
      } else if (_state == PlayerState.paused) {
        await _player.resume();
      } else {
        await _player.play(UrlSource(widget.url));
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'No se pudo reproducir el audio.';
      });
    }
  }

  Future<void> _seek(double milliseconds) async {
    try {
      await _player.seek(Duration(milliseconds: milliseconds.round()));
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorMessage = 'No se pudo cambiar la posición.');
    }
  }

  @override
  void dispose() {
    _durationSubscription.cancel();
    _positionSubscription.cancel();
    _stateSubscription.cancel();
    _completeSubscription.cancel();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final durationMs = _duration.inMilliseconds;
    final positionMs = _position.inMilliseconds.clamp(0, durationMs);
    final isPlaying = _state == PlayerState.playing;

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 12, 8),
      decoration: BoxDecoration(
        color: AppColors.infoBlueLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton.filled(
                tooltip: isPlaying ? 'Pausar audio' : 'Reproducir audio',
                onPressed: _isLoading ? null : _togglePlayback,
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                ),
                icon: _isLoading
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(isPlaying ? Icons.pause : Icons.play_arrow),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Slider(
                  value: durationMs > 0 ? positionMs.toDouble() : 0,
                  max: durationMs > 0 ? durationMs.toDouble() : 1,
                  onChanged: durationMs > 0 ? _seek : null,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${_formatDuration(_position)} / ${_formatDuration(_duration)}',
                style: const TextStyle(
                  color: AppColors.mutedText,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(left: 6, top: 2),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: AppColors.errorRed, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}

String _formatDuration(Duration duration) {
  final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}
