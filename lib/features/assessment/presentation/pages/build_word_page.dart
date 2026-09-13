import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/student_action_button.dart';
import '../../domain/models/attempt_exercise_args.dart';
import '../../domain/repositories/assessment_repository.dart';
import '../viewmodels/build_word_viewmodel.dart';

class BuildWordPage extends StatefulWidget {
  const BuildWordPage({required this.assessmentRepository, super.key});

  final AssessmentRepository assessmentRepository;

  @override
  State<BuildWordPage> createState() => _BuildWordPageState();
}

class _BuildWordPageState extends State<BuildWordPage> {
  late final BuildWordViewModel _viewModel;
  bool _requestedLoad = false;

  @override
  void initState() {
    super.initState();
    _viewModel = BuildWordViewModel(
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

  Future<void> _submit() async {
    final saved = await _viewModel.submit();
    if (!mounted) {
      return;
    }
    if (saved) {
      Navigator.pop(context, true);
      return;
    }
    final message = _viewModel.validationMessage ?? _viewModel.errorMessage;
    if (message != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                AppHeader(
                  title: 'Forma la palabra',
                  showBack: true,
                  centerTitle: true,
                  onBack: () => Navigator.pop(context, false),
                ),
                Expanded(child: _buildContent()),
              ],
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
    if (_viewModel.syllables.isEmpty) {
      return _StateMessage(
        text: _viewModel.errorMessage ?? 'Este ejercicio no tiene sílabas.',
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 24),
      child: Column(
        children: [
          Text(
            _viewModel.progressText,
            style: const TextStyle(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            _viewModel.prompt,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF5B3A9A),
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 22),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 26),
            decoration: BoxDecoration(
              color: const Color(0xFFF2EAF6),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFCFC3D7), width: 3),
            ),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: List.generate(_viewModel.placedSyllables.length, (
                index,
              ) {
                return _SyllableTargetBox(
                  text: _viewModel.placedSyllables[index],
                  onAccept: (syllable) =>
                      _viewModel.placeSyllableAt(syllable, index),
                  onTap: () => _viewModel.removePlacedSyllable(index),
                );
              }),
            ),
          ),
          const SizedBox(height: 22),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 14,
            runSpacing: 14,
            children: _viewModel.availableSyllables
                .map(
                  (syllable) => _SyllableButton(
                    text: syllable,
                    onTap: () => _viewModel.selectSyllable(syllable),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 18),
          Text(
            'formed_word: ${_viewModel.formedWord}',
            style: const TextStyle(
              color: AppColors.mutedText,
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
          const SizedBox(height: 24),
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
                  text: 'Guardar',
                  icon: Icons.arrow_forward,
                  isLoading: _viewModel.isSubmitting,
                  onPressed: _submit,
                ),
              ),
            ],
          ),
        ],
      ),
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
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 76,
            height: 76,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: candidateData.isEmpty
                  ? Colors.white
                  : const Color(0xFFDDF2FF),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFC9C1CF), width: 3),
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
        borderRadius: BorderRadius.circular(24),
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
      width: 82,
      height: 82,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFDDF2FF),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFACDDF3),
            offset: Offset(0, elevated ? 8 : 4),
            blurRadius: elevated ? 8 : 0,
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF0056B3),
          fontSize: 28,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Text(text, textAlign: TextAlign.center),
      ),
    );
  }
}
