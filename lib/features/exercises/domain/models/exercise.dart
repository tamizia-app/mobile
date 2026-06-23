import '../../../assessment/domain/models/assessment_type.dart';

class Exercise {
  const Exercise({
    required this.id,
    required this.title,
    required this.detailTitle,
    required this.description,
    required this.category,
    required this.type,
    required this.typeLabel,
    required this.recommendedGrade,
    required this.estimatedDurationMinutes,
    required this.instructionsForTeacher,
    this.imageUrlOrAsset,
    this.referenceText,
    this.phraseToWrite,
    this.targetWord,
    this.wordsOptions = const [],
    this.syllables = const [],
  });

  final String id;
  final String title;
  final String detailTitle;
  final String description;
  final String category;
  final AssessmentType type;
  final String typeLabel;
  final String recommendedGrade;
  final int estimatedDurationMinutes;
  final String? imageUrlOrAsset;
  final String instructionsForTeacher;
  final String? referenceText;
  final String? phraseToWrite;
  final String? targetWord;
  final List<String> wordsOptions;
  final List<String> syllables;
}
