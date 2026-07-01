import '../../domain/models/assessment_template.dart';

class AssessmentTemplateDto {
  const AssessmentTemplateDto({
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

  factory AssessmentTemplateDto.fromJson(Map<String, dynamic> json) {
    final templateId =
        _optionalString(json, 'template_id') ?? _optionalString(json, 'id');
    final name =
        _optionalString(json, 'name') ?? _optionalString(json, 'title');
    if (templateId == null || templateId.isEmpty) {
      throw const FormatException('Invalid template response: template_id.');
    }
    if (name == null || name.isEmpty) {
      throw const FormatException('Invalid template response: name.');
    }
    return AssessmentTemplateDto(
      templateId: templateId,
      name: name,
      description: _optionalString(json, 'description'),
      version: _optionalInt(json, 'version'),
      isActive: _optionalBool(json, 'is_active'),
      createdByTeacherId: _optionalString(json, 'created_by_teacher_id'),
      createdAt: _optionalDateTime(json, 'created_at'),
      updatedAt: _optionalDateTime(json, 'updated_at'),
      summary: _optionalString(json, 'summary'),
      exercises: _readExercises(json),
    );
  }

  final String templateId;
  final String name;
  final String? description;
  final int? version;
  final bool? isActive;
  final String? createdByTeacherId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? summary;
  final List<TemplateExerciseSummaryDto> exercises;

  AssessmentTemplate toDomain() {
    return AssessmentTemplate(
      templateId: templateId,
      name: name,
      description: description,
      version: version,
      isActive: isActive,
      createdByTeacherId: createdByTeacherId,
      createdAt: createdAt,
      updatedAt: updatedAt,
      summary: summary,
      exercises: exercises
          .map((item) => item.toDomain())
          .toList(growable: false),
    );
  }

  static List<TemplateExerciseSummaryDto> _readExercises(
    Map<String, dynamic> json,
  ) {
    final value = json['exercises'];
    if (value is! List) {
      return const [];
    }
    return value
        .whereType<Map<String, dynamic>>()
        .map(TemplateExerciseSummaryDto.fromJson)
        .toList(growable: false);
  }
}

class TemplateExerciseSummaryDto {
  const TemplateExerciseSummaryDto({
    required this.exerciseId,
    this.title,
    this.type,
  });

  factory TemplateExerciseSummaryDto.fromJson(Map<String, dynamic> json) {
    final exerciseId =
        _optionalString(json, 'exercise_id') ?? _optionalString(json, 'id');
    if (exerciseId == null || exerciseId.isEmpty) {
      throw const FormatException('Invalid template exercise response.');
    }
    return TemplateExerciseSummaryDto(
      exerciseId: exerciseId,
      title: _optionalString(json, 'title') ?? _optionalString(json, 'name'),
      type: _optionalString(json, 'type'),
    );
  }

  final String exerciseId;
  final String? title;
  final String? type;

  TemplateExerciseSummary toDomain() {
    return TemplateExerciseSummary(
      exerciseId: exerciseId,
      title: title,
      type: type,
    );
  }
}

String? _optionalString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value == null) {
    return null;
  }
  if (value is String) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
  if (value is num || value is bool) {
    return value.toString();
  }
  return null;
}

int? _optionalInt(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return null;
}

bool? _optionalBool(Map<String, dynamic> json, String key) {
  final value = json[key];
  return value is bool ? value : null;
}

DateTime? _optionalDateTime(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! String || value.trim().isEmpty) {
    return null;
  }
  return DateTime.tryParse(value);
}
