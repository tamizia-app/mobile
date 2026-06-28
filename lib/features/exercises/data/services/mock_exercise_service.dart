import '../../../assessment/domain/models/assessment_type.dart';
import '../../domain/models/exercise.dart';
import '../../domain/models/exercise_category.dart';
import 'exercise_service.dart';

class MockExerciseService implements ExerciseService {
  final List<ExerciseCategory> _categories = const [
    ExerciseCategory(id: 'reading', name: 'Lectura'),
    ExerciseCategory(id: 'writing', name: 'Escritura'),
    ExerciseCategory(id: 'games', name: 'Juegos'),
  ];

  final List<Exercise> _exercises = const [
    Exercise(
      id: 'visual-vocabulary',
      title: 'Comprensión Lectora: Vocabulario Visual',
      detailTitle: 'Análisis de Comprensión Lectora',
      category: 'Lectura',
      type: AssessmentType.mixed,
      typeLabel: 'Lectura y escritura',
      recommendedGrade: '3er Año Básico',
      estimatedDurationMinutes: 45,
      description:
          'Ejercicio diseñado para mejorar el reconocimiento de palabras frecuentes. Los estudiantes asocian imágenes claras con su correspondiente palabra escrita.',
      instructionsForTeacher:
          'Explique a los estudiantes que deben leer detenidamente el texto antes de responder. Asegúrese de que todos tengan un lápiz y goma de borrar. Se sugiere dar 5 minutos adicionales para revisión.',
      referenceText: 'El sol brilla en el cielo azul y las aves cantan',
      phraseToWrite: 'El gato duerme.',
    ),
    Exercise(
      id: 'reading-aloud',
      title: 'Lectura en voz alta',
      detailTitle: 'Lectura en voz alta',
      category: 'Lectura',
      type: AssessmentType.reading,
      typeLabel: 'Lectura',
      recommendedGrade: '3er Año Básico',
      estimatedDurationMinutes: 15,
      description:
          'Actividad guiada para escuchar la lectura del estudiante en voz alta.',
      instructionsForTeacher:
          'Indique al estudiante que lea con calma y active la grabación simulada cuando esté listo.',
      referenceText: 'El sol brilla en el cielo azul y las aves cantan',
    ),
    Exercise(
      id: 'digital-writing',
      title: 'Escritura digital',
      detailTitle: 'Escritura digital',
      category: 'Escritura',
      type: AssessmentType.writing,
      typeLabel: 'Escritura',
      recommendedGrade: '3er Año Básico',
      estimatedDurationMinutes: 15,
      description:
          'Actividad para practicar trazos y escritura de frases cortas.',
      instructionsForTeacher:
          'Pida al estudiante copiar la frase en el área de escritura digital.',
      phraseToWrite: 'El gato duerme.',
    ),
    Exercise(
      id: 'build-word',
      title: 'Arma la palabra',
      detailTitle: 'Arma la palabra',
      category: 'Juegos',
      type: AssessmentType.buildWord,
      typeLabel: 'Juego de sílabas',
      recommendedGrade: '3er Año Básico',
      estimatedDurationMinutes: 10,
      description: 'Juego para ordenar sílabas y formar una palabra.',
      instructionsForTeacher:
          'Invite al estudiante a seleccionar las sílabas en el orden correcto.',
      targetWord: 'oso',
      syllables: ['ma', 'ca', 'sa'],
    ),
    Exercise(
      id: 'choose-word',
      title: 'Elige la palabra correcta',
      detailTitle: 'Elige la palabra correcta',
      category: 'Juegos',
      type: AssessmentType.chooseWord,
      typeLabel: 'Selección de palabra',
      recommendedGrade: '3er Año Básico',
      estimatedDurationMinutes: 10,
      description: 'Juego para elegir la palabra que corresponde a la imagen.',
      instructionsForTeacher:
          'Muestre la imagen y pida al estudiante seleccionar la palabra correcta.',
      targetWord: 'manzana',
      wordsOptions: ['manzana', 'mansana', 'mazana'],
    ),
  ];

  @override
  Future<List<Exercise>> getExercises() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return List<Exercise>.unmodifiable(_exercises);
  }

  @override
  Future<Exercise> getExerciseById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return _exercises.firstWhere(
      (exercise) => exercise.id == id,
      orElse: () => _exercises.first,
    );
  }

  @override
  Future<List<ExerciseCategory>> getCategories() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return List<ExerciseCategory>.unmodifiable(_categories);
  }
}

// TODO: future backend integration.
// class ApiExerciseService implements ExerciseService {
//   // GET /api/exercises
//   // GET /api/exercises/{id}
//   // GET /api/exercise-categories
// }
