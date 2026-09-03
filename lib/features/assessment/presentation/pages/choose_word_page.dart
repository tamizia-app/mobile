import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/selectable_word_card.dart';
import '../../domain/models/attempt_exercise_args.dart';
import '../../domain/repositories/assessment_repository.dart';
import '../viewmodels/choose_word_viewmodel.dart';

class ChooseWordPage extends StatefulWidget {
  const ChooseWordPage({required this.assessmentRepository, super.key});

  final AssessmentRepository assessmentRepository;

  @override
  State<ChooseWordPage> createState() => _ChooseWordPageState();
}

class _ChooseWordPageState extends State<ChooseWordPage> {
  late final ChooseWordViewModel _viewModel;
  bool _requestedLoad = false;

  @override
  void initState() {
    super.initState();
    _viewModel = ChooseWordViewModel(
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
                  title: 'Elige la palabra',
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
    if (_viewModel.options.isEmpty) {
      return _StateMessage(
        text: _viewModel.errorMessage ?? 'Este ejercicio no tiene opciones.',
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _viewModel.progressText,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            _viewModel.prompt,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF102532),
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (_viewModel.exerciseAttempt?.imageUrl != null) ...[
            const SizedBox(height: 18),
            _ImageHint(url: _viewModel.exerciseAttempt!.imageUrl!),
          ],
          const SizedBox(height: 26),
          ..._viewModel.options.map(
            (option) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: SelectableWordCard(
                text: option.text,
                selected: _viewModel.selectedOptionId == option.optionId,
                onTap: () => _viewModel.selectOption(option.optionId),
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
          const SizedBox(height: 22),
          PrimaryButton(
            text: 'Guardar respuesta',
            icon: Icons.arrow_forward,
            isLoading: _viewModel.isSubmitting,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}

class _ImageHint extends StatelessWidget {
  const _ImageHint({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final uri = Uri.tryParse(url);
    if (uri != null && uri.hasScheme) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(url, height: 180, fit: BoxFit.contain),
      );
    }
    return Text(
      'Imagen: $url',
      textAlign: TextAlign.center,
      style: const TextStyle(color: AppColors.mutedText),
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
