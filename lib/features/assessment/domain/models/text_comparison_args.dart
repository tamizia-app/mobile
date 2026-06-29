class TextComparisonArgs {
  const TextComparisonArgs({
    required this.expectedText,
    required this.recognizedText,
    this.title = 'Comparacion de texto',
  });

  final String expectedText;
  final String recognizedText;
  final String title;
}
