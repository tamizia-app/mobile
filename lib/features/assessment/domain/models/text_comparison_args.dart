class TextComparisonArgs {
  const TextComparisonArgs({
    required this.expectedText,
    required this.recognizedText,
    this.title = 'Comparación de textos',
  });

  final String expectedText;
  final String recognizedText;
  final String title;
}
