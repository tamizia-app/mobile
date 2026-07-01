String translateExerciseType(String? type) {
  if (type == null) return 'No disponible';
  switch (type.trim().toUpperCase()) {
    case 'MULTIPLE_CHOICE':
      return 'Seleccion multiple';
    case 'ORDER_SYLLABLES':
      return 'Orden de silabas';
    case 'READING_SPEAKING':
      return 'Lectura oral';
    case 'LISTENING_SPEAKING':
      return 'Escucha y habla';
    case 'READING_WRITING':
      return 'Escritura';
    case 'LISTENING_WRITING':
      return 'Escucha y escritura';
    default:
      return _fallback(type);
  }
}

String translateExerciseStatus(String? status) {
  if (status == null) return 'No disponible';
  switch (status.trim().toUpperCase()) {
    case 'PENDING':
      return 'Pendiente';
    case 'ANSWERED':
      return 'Respondido';
    case 'EVALUATED':
      return 'Evaluado';
    case 'FAILED':
      return 'Fallido';
    case 'IN_PROGRESS':
      return 'En progreso';
    case 'COMPLETED':
    case 'FINISHED':
      return 'Completado';
    case 'SKIPPED':
      return 'Saltado';
    case 'STARTED':
      return 'Iniciado';
    default:
      return _fallback(status);
  }
}

String translateAttemptStatus(String? status) {
  if (status == null) return 'No disponible';
  switch (status.trim().toUpperCase()) {
    case 'IN_PROGRESS':
    case 'STARTED':
      return 'En progreso';
    case 'COMPLETED':
    case 'FINISHED':
      return 'Completado';
    case 'CANCELLED':
    case 'CANCELED':
      return 'Cancelado';
    case 'PENDING':
      return 'Pendiente';
    default:
      return _fallback(status);
  }
}

String translateInterventionLevel(String? level) {
  if (level == null) return 'No disponible';
  switch (level.trim().toUpperCase()) {
    case 'LOW':
      return 'Bajo';
    case 'MEDIUM':
      return 'Medio';
    case 'HIGH':
      return 'Alto';
    default:
      return _fallback(level);
  }
}

String translateGender(String? gender) {
  if (gender == null) return 'No disponible';
  switch (gender.trim().toUpperCase()) {
    case 'BOY':
      return 'Nino';
    case 'GIRL':
      return 'Nina';
    default:
      return _fallback(gender);
  }
}

String _fallback(String value) {
  return value
      .replaceAll('_', ' ')
      .split(' ')
      .map((word) {
        if (word.isEmpty) return word;
        return word[0].toUpperCase() + word.substring(1).toLowerCase();
      })
      .join(' ');
}
