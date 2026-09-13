class BuildWordQuestion {
  const BuildWordQuestion({
    required this.prompt,
    required this.targetWord,
    required this.syllables,
    required this.answer,
  });

  final String prompt;
  final String targetWord;
  final List<String> syllables;
  final List<String> answer;
}

class ChooseWordQuestion {
  const ChooseWordQuestion({
    required this.prompt,
    required this.imageLabel,
    required this.options,
    required this.correctAnswer,
  });

  final String prompt;
  final String imageLabel;
  final List<String> options;
  final String correctAnswer;
}
