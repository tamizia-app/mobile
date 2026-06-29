class AssessmentTemplate {
  const AssessmentTemplate({
    required this.templateId,
    required this.name,
    this.description,
    this.version,
    this.status,
    this.summary,
    this.exercises = const [],
  });

  final String templateId;
  final String name;
  final String? description;
  final String? version;
  final String? status;
  final String? summary;
  final List<TemplateExerciseSummary> exercises;

  String get id => templateId;
}

class TemplateExerciseSummary {
  const TemplateExerciseSummary({
    required this.exerciseId,
    this.title,
    this.type,
  });

  final String exerciseId;
  final String? title;
  final String? type;

  String get displayName => title?.trim().isNotEmpty == true
      ? title!.trim()
      : 'Ejercicio $exerciseId';
}
