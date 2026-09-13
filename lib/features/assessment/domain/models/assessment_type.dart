enum AssessmentType { reading, writing, buildWord, chooseWord, mixed }

extension AssessmentTypeLabel on AssessmentType {
  String get label {
    switch (this) {
      case AssessmentType.reading:
        return 'Lectura';
      case AssessmentType.writing:
        return 'Escritura';
      case AssessmentType.buildWord:
        return 'Arma la palabra';
      case AssessmentType.chooseWord:
        return 'Elige la palabra correcta';
      case AssessmentType.mixed:
        return 'Lectura y escritura';
    }
  }
}
