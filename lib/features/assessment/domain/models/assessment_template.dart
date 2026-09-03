class AssessmentTemplate {
  const AssessmentTemplate({
    required this.templateId,
    required this.name,
    this.description,
    this.version,
    this.isActive,
    this.createdByTeacherId,
    this.createdAt,
    this.updatedAt,
    this.summary,
    this.exercises = const [],
  });

  final String templateId;
  final String name;
  final String? description;
  final int? version;
  final bool? isActive;
  final String? createdByTeacherId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
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
      : 'Ejercicio';
}
