import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../core/widgets/assessment_result_summary.dart';
import '../../../../core/widgets/app_states.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../widgets/exercise_metrics_panel.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/assessment_labels.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/error_message.dart';
import '../../domain/models/attempt_review.dart';
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
      if (!mounted) return;
      setState(() {
        _review = review;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
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
            title: 'Detalle de la evaluación',
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
      return const AppLoadingState(message: 'Cargando resultados…');
    }
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: AppColors.errorRed,
                size: 48,
              ),
              const SizedBox(height: AppSpacing.lg),
              ErrorMessage(text: _errorMessage!),
              const SizedBox(height: AppSpacing.lg),
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
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (review.result != null) _ResultCard(result: review.result!),
          const SizedBox(height: AppSpacing.lg),
          ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            title: Text(review.student?.code ?? 'Datos de la evaluación'),
            subtitle: Text(
              review.assessment?.title ?? translateAttemptStatus(review.status),
            ),
            children: [
              _StudentInfoCard(student: review.student),
              const SizedBox(height: AppSpacing.md),
              _AssessmentInfoCard(review: review),
            ],
          ),
          if (review.exerciseReviews.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            const AppSectionHeader(
              title: 'Análisis por ejercicio',
              description:
                  'Revisa el puntaje, los indicadores y la evidencia de cada actividad.',
            ),
            const SizedBox(height: AppSpacing.sm),
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
            const SizedBox(height: AppSpacing.xl),
            PrimaryButton(
              text: 'Repetir evaluación',
              icon: Icons.replay,
              isLoading: _isRepeating,
              onPressed: _isRepeating ? null : _repeatAttempt,
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          PrimaryButton(
            text: 'Volver al historial',
            variant: AppButtonVariant.secondary,
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
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.control),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Estudiante',
            style: TextStyle(
              fontSize: AppFontSizes.bodyLarge,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
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
              style: const TextStyle(fontWeight: FontWeight.w700),
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
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.control),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Evaluación',
            style: TextStyle(
              fontSize: AppFontSizes.bodyLarge,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
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
              style: const TextStyle(fontWeight: FontWeight.w700),
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
  Widget build(BuildContext context) => AssessmentResultSummary(
    score: result.finalScore,
    level: result.interventionLevel,
    pending: result.pendingExercises,
  );
}

class _ExerciseReviewCard extends StatelessWidget {
  const _ExerciseReviewCard({required this.index, required this.exercise});
  final int index;
  final ExerciseReview exercise;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(AppSpacing.lg),
    decoration: AppSurfaces.card,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Ejercicio ${index + 1} · ${translateExerciseType(exercise.type)}',
          style: AppTextStyles.labelMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(exercise.title, style: AppTextStyles.headingSmall),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            AppStatusBadge(label: translateExerciseStatus(exercise.status), icon: Icons.assignment_outlined),
            if (exercise.reviewRequired)
              const AppStatusBadge(
                label: 'Requiere revisión docente',
                icon: Icons.flag_outlined,
                color: AppColors.warning,
              ),
          ],
        ),
        AppDetailRow(
          label: 'Puntaje del ejercicio',
          value: exercise.score == null
              ? 'Sin puntaje disponible'
              : '${exercise.score!.toStringAsFixed(1)} / 100',
        ),
        AppDetailRow(
          label: 'Calidad de la evidencia',
          value: translateTechnicalStatus(exercise.technicalStatus.apiValue),
        ),
        Text(
          exercise.scoreEligible
              ? 'Incluido en el cálculo del resultado.'
              : 'No se incluye en el cálculo del resultado.',
          style: AppTextStyles.bodySmall,
        ),
        if (exercise.reviewReasons.isNotEmpty ||
            exercise.qualityReasons.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.warningContainer,
              borderRadius: BorderRadius.circular(AppRadius.control),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Aspectos que revisar',
                  style: AppTextStyles.labelLarge,
                ),
                for (final reason in {
                  ...exercise.reviewReasons,
                  ...exercise.qualityReasons,
                })
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text('• ${translateReviewReason(reason)}'),
                  ),
              ],
            ),
          ),
        ],
        const Divider(),
        _buildTypeSpecificDetails(context),
      ],
    ),
  );

  Widget _buildTypeSpecificDetails(BuildContext context) {
    final type = exercise.type.trim().toUpperCase();
    final response = exercise.response;
    if (type == 'MULTIPLE_CHOICE' || type == 'ORDER_SYLLABLES') {
      final choice = type == 'MULTIPLE_CHOICE';
      final given = response?[choice ? 'selected_text' : 'formed_word'];
      final expected =
          exercise.expected?[choice ? 'correct_text' : 'correct_word'];
      final correct = response?['is_correct'];
      final syllables = response?['selected_syllables'];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (exercise.questionText != null)
            _textBlock('Consigna', exercise.questionText!),
          if (syllables is List)
            _textBlock('Sílabas elegidas', syllables.join(' · ')),
          _textBlock(
            'Respuesta del estudiante',
            given?.toString() ?? 'No disponible',
          ),
          if (correct is bool)
            Align(
              alignment: Alignment.centerLeft,
              child: AppStatusBadge(
                label: correct ? 'Respuesta correcta' : 'Respuesta incorrecta',
                icon: correct
                    ? Icons.check_circle_outline
                    : Icons.cancel_outlined,
                color: correct ? AppColors.success : AppColors.error,
              ),
            ),
          const SizedBox(height: AppSpacing.md),
          _textBlock(
            'Respuesta esperada',
            expected?.toString() ?? 'No disponible',
          ),
        ],
      );
    }
    final writing = type == 'READING_WRITING' || type == 'LISTENING_WRITING';
    final speaking = type == 'READING_SPEAKING' || type == 'LISTENING_SPEAKING';
    if (!writing && !speaking) {
      return const Text('No hay detalles disponibles para este ejercicio.');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ExerciseMetricsPanel(
          metrics: exercise.scoringComponents,
          writing: writing,
        ),
        const SizedBox(height: AppSpacing.xl),
        const AppSectionHeader(title: 'Respuesta y evidencia'),
        const SizedBox(height: AppSpacing.md),
        if (exercise.referenceText != null)
          _textBlock('Texto de referencia', exercise.referenceText!),
        if (response?['free_transcription_text'] != null)
          _textBlock(
            'Transcripción del audio',
            response!['free_transcription_text'].toString(),
          ),
        if (response?['recognized_text'] != null)
          _textBlock(
            writing
                ? 'Texto reconocido de la escritura (OCR)'
                : 'Texto reconocido',
            response!['recognized_text'].toString(),
          ),
        if (writing && response?['image_url'] != null)
          _ImagePreview(url: response!['image_url'].toString()),
        if (speaking && response?['audio_url'] != null)
          _AudioPlayer(url: response!['audio_url'].toString()),
        if (response == null || response.isEmpty)
          const Text(
            'No hay una respuesta disponible.',
            style: AppTextStyles.bodySmall,
          ),
      ],
    );
  }

  Widget _textBlock(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.md),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: AppTextStyles.labelMedium),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppRadius.control),
          ),
          child: SelectableText(
            value.trim().isEmpty ? 'Sin texto reconocido' : value,
            style: AppTextStyles.bodyMedium,
          ),
        ),
      ],
    ),
  );
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
        borderRadius: BorderRadius.circular(AppRadius.control),
        child: Container(
          height: 120,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.backgroundLight,
            borderRadius: BorderRadius.circular(AppRadius.control),
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
                    : const AppLoadingState(message: 'Cargando resultados…'),
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
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: AppFontSizes.support,
                    ),
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
      insetPadding: const EdgeInsets.all(AppSpacing.lg),
      backgroundColor: Colors.black,
      child: SizedBox(
        width: double.infinity,
        height: MediaQuery.sizeOf(context).height * 0.8,
        child: Stack(
          children: [
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
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
                              SizedBox(height: AppSpacing.md),
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
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.infoBlueLight,
        borderRadius: BorderRadius.circular(AppRadius.control),
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
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Slider(
                  value: durationMs > 0 ? positionMs.toDouble() : 0,
                  max: durationMs > 0 ? durationMs.toDouble() : 1,
                  onChanged: durationMs > 0 ? _seek : null,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '${_formatDuration(_position)} / ${_formatDuration(_duration)}',
                style: const TextStyle(
                  color: AppColors.mutedText,
                  fontSize: AppFontSizes.support,
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
                style: const TextStyle(
                  color: AppColors.errorRed,
                  fontSize: AppFontSizes.support,
                ),
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
