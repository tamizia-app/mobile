import 'package:flutter/foundation.dart';

import '../../../exercises/data/services/exercise_service.dart';
import '../../../exercises/domain/models/exercise.dart';
import '../../data/services/assessment_service.dart';
import '../../domain/models/assessment_question.dart';
import '../../domain/models/assessment_session.dart';

class BuildWordViewModel extends ChangeNotifier {
  BuildWordViewModel({
    required ExerciseService exerciseService,
    required AssessmentService assessmentService,
  }) : _exerciseService = exerciseService,
       _assessmentService = assessmentService;

  final ExerciseService _exerciseService;
  final AssessmentService _assessmentService;

  Exercise? exercise;
  AssessmentSession? session;
  final List<BuildWordQuestion> questions = const [
    BuildWordQuestion(
      prompt: '¿Qué es esto?',
      targetWord: 'casa',
      syllables: ['ca', 'sa', 'ma'],
      answer: ['ca', 'sa'],
    ),
    BuildWordQuestion(
      prompt: '¿Qué es esto?',
      targetWord: 'mesa',
      syllables: ['me', 'sa', 'se'],
      answer: ['me', 'sa'],
    ),
    BuildWordQuestion(
      prompt: '¿Qué es esto?',
      targetWord: 'pato',
      syllables: ['pa', 'to', 'ta'],
      answer: ['pa', 'to'],
    ),
  ];
  int currentQuestionIndex = 0;
  final List<String?> placedSyllables = [null, null];
  String? feedback;
  bool isPaused = false;
  String? validationMessage;

  BuildWordQuestion get currentQuestion => questions[currentQuestionIndex];

  bool get isLastQuestion => currentQuestionIndex == questions.length - 1;

  String get progressText =>
      'Pregunta ${currentQuestionIndex + 1} de ${questions.length}';

  List<String> get availableSyllables => currentQuestion.syllables
      .where((syllable) => !placedSyllables.contains(syllable))
      .toList();

  Future<void> load(AssessmentSession assessmentSession) async {
    session = assessmentSession;
    exercise = await _exerciseService.getExerciseById(
      assessmentSession.exerciseId,
    );
    notifyListeners();
  }

  void selectSyllable(String syllable) {
    if (isPaused) return;
    final index = placedSyllables.indexWhere((item) => item == null);
    if (index == -1 || placedSyllables.contains(syllable)) return;
    placedSyllables[index] = syllable;
    feedback = null;
    validationMessage = null;
    notifyListeners();
  }

  void placeSyllableAt(String syllable, int index) {
    if (isPaused || placedSyllables.contains(syllable)) return;
    placedSyllables[index] = syllable;
    feedback = null;
    validationMessage = null;
    notifyListeners();
  }

  void removePlacedSyllable(int index) {
    if (isPaused) return;
    placedSyllables[index] = null;
    feedback = null;
    validationMessage = null;
    notifyListeners();
  }

  void clear() {
    for (var index = 0; index < placedSyllables.length; index++) {
      placedSyllables[index] = null;
    }
    feedback = null;
    validationMessage = null;
    notifyListeners();
  }

  void check() {
    if (!_hasAnswer()) {
      validationMessage = 'Coloca las sílabas para continuar.';
      notifyListeners();
      return;
    }
    final formed = placedSyllables.whereType<String>().toList();
    feedback = _isCorrect(formed) ? '¡Correcto!' : 'Inténtalo de nuevo';
    validationMessage = null;
    notifyListeners();
    // TODO: send build-word answer to backend later.
  }

  bool nextQuestion() {
    if (!_hasAnswer()) {
      validationMessage = 'Coloca las sílabas para continuar.';
      notifyListeners();
      return false;
    }
    if (!isLastQuestion) {
      currentQuestionIndex++;
      clear();
      return true;
    }
    return true;
  }

  Future<void> togglePause() async {
    final currentSession = session;
    if (currentSession == null) return;
    isPaused = !isPaused;
    if (isPaused) {
      await _assessmentService.pauseSession(currentSession.id);
    } else {
      await _assessmentService.resumeSession(currentSession.id);
    }
    notifyListeners();
    // TODO: persist pause/resume timestamps for game metrics in backend.
  }

  Future<void> finish() async {
    final currentSession = session;
    if (currentSession == null) return;
    await _assessmentService.finishSession(currentSession.id);
  }

  Future<void> cancel() async {
    final currentSession = session;
    if (currentSession != null) {
      await _assessmentService.cancelSession(currentSession.id);
    }
  }

  bool _hasAnswer() => placedSyllables.every((item) => item != null);

  bool _isCorrect(List<String> answer) {
    if (answer.length != currentQuestion.answer.length) return false;
    for (var index = 0; index < answer.length; index++) {
      if (answer[index] != currentQuestion.answer[index]) return false;
    }
    return true;
  }
}
