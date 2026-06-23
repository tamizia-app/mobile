import 'package:flutter/foundation.dart';

import '../../../exercises/data/services/exercise_service.dart';
import '../../../exercises/domain/models/exercise.dart';
import '../../data/services/assessment_service.dart';
import '../../domain/models/assessment_question.dart';
import '../../domain/models/assessment_session.dart';

class ChooseWordViewModel extends ChangeNotifier {
  ChooseWordViewModel({
    required ExerciseService exerciseService,
    required AssessmentService assessmentService,
  }) : _exerciseService = exerciseService,
       _assessmentService = assessmentService;

  final ExerciseService _exerciseService;
  final AssessmentService _assessmentService;

  Exercise? exercise;
  AssessmentSession? session;
  final List<ChooseWordQuestion> questions = const [
    ChooseWordQuestion(
      prompt: '¿Qué es esto?',
      imageLabel: 'manzana',
      options: ['Manzana', 'Mansana', 'Mazana'],
      correctAnswer: 'Manzana',
    ),
    ChooseWordQuestion(
      prompt: '¿Qué es esto?',
      imageLabel: 'casa',
      options: ['Casa', 'Caza', 'Cassa'],
      correctAnswer: 'Casa',
    ),
    ChooseWordQuestion(
      prompt: '¿Qué es esto?',
      imageLabel: 'pato',
      options: ['Pato', 'Bato', 'Patoo'],
      correctAnswer: 'Pato',
    ),
  ];
  int currentQuestionIndex = 0;
  String? selectedWord;
  String? feedback;
  String? validationMessage;
  bool isPaused = false;

  ChooseWordQuestion get currentQuestion => questions[currentQuestionIndex];

  bool get isLastQuestion => currentQuestionIndex == questions.length - 1;

  String get progressText =>
      'Pregunta ${currentQuestionIndex + 1} de ${questions.length}';

  Future<void> load(AssessmentSession assessmentSession) async {
    session = assessmentSession;
    exercise = await _exerciseService.getExerciseById(
      assessmentSession.exerciseId,
    );
    notifyListeners();
  }

  void selectWord(String word) {
    if (isPaused) return;
    selectedWord = word;
    feedback = word.toLowerCase() == currentQuestion.correctAnswer.toLowerCase()
        ? '¡Correcto!'
        : 'Buen intento, prueba otra vez';
    validationMessage = null;
    notifyListeners();
    // TODO: send selected answer to backend later.
  }

  bool nextQuestion() {
    if (selectedWord == null) {
      validationMessage = 'Selecciona una respuesta para continuar.';
      notifyListeners();
      return false;
    }
    if (!isLastQuestion) {
      currentQuestionIndex++;
      selectedWord = null;
      feedback = null;
      validationMessage = null;
      notifyListeners();
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
}
