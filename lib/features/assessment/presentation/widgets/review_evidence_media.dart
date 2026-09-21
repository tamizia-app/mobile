import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/app_states.dart';

class ReviewImagePreview extends StatelessWidget {
  const ReviewImagePreview({required this.url, super.key});

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
          height: 240,
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
                    : const AppLoadingState(message: 'Cargando imagen…'),
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.lg),
                    child: Text(
                      'No se pudo cargar la imagen. Renueva la evidencia e inténtalo nuevamente.',
                      textAlign: TextAlign.center,
                    ),
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

class ReviewAudioPlayer extends StatefulWidget {
  const ReviewAudioPlayer({required this.url, super.key});

  final String url;

  @override
  State<ReviewAudioPlayer> createState() => _ReviewAudioPlayerState();
}

class _ReviewAudioPlayerState extends State<ReviewAudioPlayer> {
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
  void didUpdateWidget(covariant ReviewAudioPlayer oldWidget) {
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
          TextButton.icon(
            onPressed: durationMs > 0 && !_isLoading ? () => _seek(0) : null,
            icon: const Icon(Icons.replay),
            label: const Text('Reiniciar audio'),
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
