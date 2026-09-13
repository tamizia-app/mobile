import 'package:flutter/material.dart';
import '../../../../core/widgets/student_activity_layout.dart';
import '../../../../core/widgets/app_states.dart';
import '../../../../core/theme/app_tokens.dart';

import '../../../../core/theme/app_colors.dart';

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
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _viewModel,
    builder: (context, _) => StudentActivityLayout(
      title: 'Forma la palabra',
      onBack: () => Navigator.pop(context, false),
      child: _buildContent(),
    ),
  );

  Widget _buildContent() {
    if (_viewModel.isLoading) {
      return const AppLoadingState(message: 'Preparando la actividad…');
    }
    if (_viewModel.syllables.isEmpty) {
      return _StateMessage(
        text: _viewModel.errorMessage ?? 'Este ejercicio no tiene sílabas.',
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StudentTaskHeading(
            progress: _viewModel.progressText,
            instruction: _viewModel.prompt,
          ),
          const SizedBox(height: AppSpacing.xl),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.studentLilac,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.studentPurple.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
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
          const SizedBox(height: AppSpacing.xl),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: AppSpacing.lg,
            runSpacing: AppSpacing.lg,
            children: _viewModel.availableSyllables
                .map(
                  (syllable) => _SyllableButton(
                    text: syllable,
                    onTap: () => _viewModel.selectSyllable(syllable),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Tu palabra: ${_viewModel.formedWord}',
            style: const TextStyle(
              color: AppColors.mutedText,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (_viewModel.errorMessage != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              _viewModel.errorMessage!,
              textAlign: TextAlign.left,
              style: const TextStyle(
                color: AppColors.errorRed,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          AppActionGroup(
            children: [
              StudentActionButton(
                text: 'Limpiar',
                icon: Icons.cleaning_services_outlined,
                onPressed: _viewModel.clear,
              ),
              PrimaryButton(
                text: 'Guardar',
                student: true,
                icon: Icons.arrow_forward,
                isLoading: _viewModel.isSubmitting,
                onPressed: _submit,
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
            constraints: const BoxConstraints(minWidth: 76, minHeight: 76),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: candidateData.isEmpty
                  ? Colors.white
                  : AppColors.secondaryContainer,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.studentPurple, width: 2),
            ),
            child: Center(
              widthFactor: 1,
              heightFactor: 1,
              child: Text(
                text ?? '',
                style: const TextStyle(
                  fontSize: AppFontSizes.section,
                  fontWeight: FontWeight.w700,
                ),
              ),
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
        child: _SyllableTile(text: text),
      ),
      childWhenDragging: Opacity(opacity: 0.35, child: child),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: child,
      ),
    );
  }
}

class _SyllableTile extends StatelessWidget {
  const _SyllableTile({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 80, minHeight: 80),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.secondary, width: 1.5),
        boxShadow: const [
          BoxShadow(color: AppColors.studentYellow, offset: Offset(0, 4)),
        ],
      ),
      child: Center(
        widthFactor: 1,
        heightFactor: 1,
        child: Text(
          text,
          style: const TextStyle(
            color: AppColors.secondary,
            fontSize: AppFontSizes.heading,
            fontWeight: FontWeight.w700,
          ),
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
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Text(text, textAlign: TextAlign.left),
      ),
    );
  }
}
