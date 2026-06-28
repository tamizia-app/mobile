Continuemos con el desarrollo de TamizIA.

Ya están implementados:
- BLOCK-1-AUTH
- BLOCK-2-DOCENTE-AULA-ESTUDIANTE

Ahora necesito implementar el BLOCK-3-EXERCISES-CATALOG-ASSESSMENT siguiendo fielmente las imágenes del Figma.

Las imágenes de referencia están en:

docs/figma/BLOCK-3-EXERCISES-CATALOG-ASSESSMENT/

Archivos de referencia:
- Catálogo de ejercicios.png
- Detalle de ejercicio.png
- Configurar sesión de evaluación.png
- Instrucciones para estudiante.png
- Evaluación de lectura en voz alta.png
- Evaluación de escritura digital.png
- Arma la palabra.png
- Elige la palabra correcta.png

IMPORTANTE:
- Usa las imágenes del Figma solo como referencia visual.
- No las agregues como assets de la app salvo que sea estrictamente necesario para replicar imágenes decorativas.
- Respeta colores, tipografía, espaciados, cards, bordes, sombras, iconos, botones y navegación del Figma.
- Mantén la arquitectura MVVM existente.
- No metas todo en un solo archivo.
- No modifiques el BLOCK-1 ni el BLOCK-2 salvo para conectar navegación.
- No implementes backend real.
- No implementes Firebase.
- No implementes Azure real.
- No implementes base de datos real.
- No agregues Dio, http, Retrofit ni dependencias de red.
- Todo debe estar mockeado.
- Deja servicios abstractos y MockServices preparados para reemplazo futuro por API real.
- Ejecuta flutter analyze al final y corrige errores importantes.

Objetivo:
Implementar el catálogo de ejercicios, detalle de ejercicio, configuración de sesión de evaluación y pantallas de evaluación para estudiante con datos dummy, navegación local y estructura preparada para backend futuro.

Contexto funcional:
El docente debe poder entrar al catálogo de ejercicios, seleccionar un ejercicio preconfigurado, ver su detalle, usarlo en una evaluación, configurar aula/estudiante/ejercicio y luego iniciar una sesión guiada para el estudiante.

Esto corresponde al Sprint 2 del proyecto:
- Catálogo de ejercicios preconfigurados.
- Selección de ejercicio por estudiante.
- Creación de sesión de evaluación.
- Instrucciones previas.
- Primera captura simulada de lectura en voz alta.
- Pantallas iniciales de escritura y ejercicios lúdicos.

Rutas nuevas sugeridas:
- /exercises/catalog
- /exercises/detail
- /assessment/configure
- /assessment/instructions
- /assessment/reading
- /assessment/writing
- /assessment/build-word
- /assessment/choose-word

Actualizar navegación:
- En el bottom navigation, el item “Ejercicios” debe navegar a /exercises/catalog.
- En el dashboard, el acceso rápido “Catálogo” debe navegar a /exercises/catalog.
- En detalle de ejercicio, el botón “Usar en evaluación” debe navegar a /assessment/configure.
- En configurar sesión, el botón “Iniciar evaluación” debe navegar a /assessment/instructions.
- En instrucciones, el botón “¡Comenzar!” debe navegar al tipo de evaluación correspondiente:
    - Lectura -> /assessment/reading
    - Escritura -> /assessment/writing
    - Arma la palabra -> /assessment/build-word
    - Elige la palabra correcta -> /assessment/choose-word

Estructura esperada:

lib/
features/
exercises/
data/
services/
exercise_service.dart
mock_exercise_service.dart

      domain/
        models/
          exercise.dart
          exercise_category.dart

      presentation/
        viewmodels/
          exercise_catalog_viewmodel.dart
          exercise_detail_viewmodel.dart

        pages/
          exercise_catalog_page.dart
          exercise_detail_page.dart

    assessment/
      data/
        services/
          assessment_service.dart
          mock_assessment_service.dart

      domain/
        models/
          assessment_session.dart
          assessment_summary.dart
          assessment_type.dart

      presentation/
        viewmodels/
          assessment_config_viewmodel.dart
          student_instructions_viewmodel.dart
          reading_assessment_viewmodel.dart
          writing_assessment_viewmodel.dart
          build_word_viewmodel.dart
          choose_word_viewmodel.dart

        pages/
          assessment_config_page.dart
          student_instructions_page.dart
          reading_assessment_page.dart
          writing_assessment_page.dart
          build_word_page.dart
          choose_word_page.dart

core/
widgets/
exercise_card.dart
category_chip.dart
assessment_timer.dart
student_success_banner.dart
student_instruction_card.dart
student_action_button.dart
drawing_canvas_placeholder.dart
selectable_word_card.dart
assessment_summary_card.dart

Servicios y mocks:

Crear contratos abstractos:

abstract class ExerciseService {
Future<List<Exercise>> getExercises();
Future<Exercise> getExerciseById(String id);
Future<List<ExerciseCategory>> getCategories();
}

class MockExerciseService implements ExerciseService {
// Datos dummy por ahora.
}

class ApiExerciseService implements ExerciseService {
// TODO futuro:
// GET /api/exercises
// GET /api/exercises/{id}
// GET /api/exercise-categories
// No implementar HTTP real todavía.
}

abstract class AssessmentService {
Future<AssessmentSession> createSession({
required String classroomId,
required String studentId,
required String exerciseId,
});

Future<void> startSession(String sessionId);
Future<void> pauseSession(String sessionId);
Future<void> finishSession(String sessionId);
Future<void> saveReadingEvidence(String sessionId);
Future<void> saveWritingEvidence(String sessionId);
}

class MockAssessmentService implements AssessmentService {
// Simular creación y control de sesión.
}

class ApiAssessmentService implements AssessmentService {
// TODO futuro:
// POST /api/assessment-sessions
// PATCH /api/assessment-sessions/{id}/start
// PATCH /api/assessment-sessions/{id}/pause
// PATCH /api/assessment-sessions/{id}/finish
// POST /api/assessment-sessions/{id}/reading-evidence
// POST /api/assessment-sessions/{id}/writing-evidence
// No implementar HTTP real todavía.
}

Reglas de arquitectura:
- Las páginas no deben tener datos quemados directamente.
- Los datos dummy deben venir desde MockExerciseService y MockAssessmentService.
- Los ViewModels consumen servicios abstractos.
- Las páginas consumen ViewModels.
- La UI no debe conocer detalles de backend.
- Dejar comentarios TODO breves donde se conectaría backend real.
- No usar throw UnimplementedError en código que pueda ejecutarse.
- No dejar clases incompletas que rompan compilación.

Modelos sugeridos:

Exercise:
- id
- title
- description
- category
- type
- recommendedGrade
- estimatedDurationMinutes
- imageUrlOrAsset
- instructionsForTeacher
- referenceText
- phraseToWrite
- wordsOptions

ExerciseCategory:
- id
- name

AssessmentSession:
- id
- classroomId
- studentId
- exerciseId
- type
- status
- estimatedDurationMinutes

AssessmentType:
- reading
- writing
- buildWord
- chooseWord
- mixed

Datos dummy sugeridos:

Categorías:
- Lectura
- Escritura
- Juegos

Ejercicios:
1. Comprensión Lectora: Vocabulario Visual
   Categoría: Lectura
   Tipo: Lectura y escritura
   Grado recomendado: 3er Año Básico
   Duración estimada: 45 minutos
   Descripción:
   “Ejercicio diseñado para mejorar el reconocimiento de palabras frecuentes. Los estudiantes asocian imágenes claras con su correspondiente palabra escrita.”
   Instrucciones para docente:
   “Explique a los estudiantes que deben leer detenidamente el texto antes de responder. Asegúrese de que todos tengan un lápiz y goma de borrar. Se sugiere dar 5 minutos adicionales para revisión.”

2. Lectura en voz alta
   Categoría: Lectura
   Tipo: Lectura
   Grado recomendado: 3er Año Básico
   Duración estimada: 15 minutos
   Texto de lectura:
   “El sol brilla en el cielo azul y las aves cantan”

3. Escritura digital
   Categoría: Escritura
   Tipo: Escritura
   Grado recomendado: 3er Año Básico
   Duración estimada: 15 minutos
   Frase:
   “El gato duerme.”

4. Arma la palabra
   Categoría: Juegos
   Tipo: buildWord
   Palabra objetivo:
   “oso”

5. Elige la palabra correcta
   Categoría: Juegos
   Tipo: chooseWord
   Imagen: manzana
   Opciones:
    - manzana
    - mansana
    - mazana

Pantalla 1: Catálogo de ejercicios

Referencia:
docs/figma/BLOCK-3-EXERCISES-CATALOG-ASSESSMENT/Catálogo de ejercicios.png

Debe incluir:
- Header “Catálogo de Ejercicios”.
- Icono de búsqueda a la derecha.
- Chips/categorías:
    - Lectura
    - Escritura
    - Juegos
- Lista vertical de cards de ejercicios.
- Card principal con imagen de libro.
- Título:
  “Comprensión Lectora: Vocabulario Visual”
- Badge de duración:
  “15 min”
- Descripción breve.
- Botón:
  “Seleccionar →”
- Bottom navigation visible con item “Ejercicios” activo.

Comportamiento:
- Tap en categoría filtra la lista mock.
- Tap en búsqueda muestra SnackBar “Búsqueda no implementada todavía”.
- Tap en Seleccionar navega a /exercises/detail con el ejercicio seleccionado.
- Bottom nav funciona igual que en bloque 2.

Pantalla 2: Detalle de ejercicio

Referencia:
docs/figma/BLOCK-3-EXERCISES-CATALOG-ASSESSMENT/Detalle de ejercicio.png

Debe incluir:
- Header con flecha atrás y título “Detalle del Ejercicio”.
- Título:
  “Análisis de Comprensión Lectora”
- Secciones:
    - Tipo de ejercicio: Lectura y escritura
    - Grado recomendado: 3er Año Básico
    - Duración estimada: 45 minutos
- Sección:
  “Instrucciones para el docente”
- Texto de instrucciones.
- Botón azul:
  “Usar en evaluación”

Comportamiento:
- Flecha atrás vuelve al catálogo.
- Botón “Usar en evaluación” navega a /assessment/configure.

Pantalla 3: Configurar sesión de evaluación

Referencia:
docs/figma/BLOCK-3-EXERCISES-CATALOG-ASSESSMENT/Configurar sesión de evaluación.png

Debe incluir:
- Header con flecha atrás.
- Título:
  “Nueva evaluación”
- Campos tipo selector:
    - Aula: Seleccionar aula
    - Estudiante (seudónimo): Seleccionar estudiante
    - Ejercicio: Seleccionar ejercicio
- Sección:
  “Resumen de sesión”
- Fila:
  “Duración estimada” -> “15 - 20 min”
- Banner azul:
  “Se requiere consentimiento previo. Asegúrese de contar con la autorización de los tutores legales antes de iniciar la evaluación con el estudiante.”
- Botón:
  “Iniciar evaluación →”

Validaciones:
- Aula obligatoria.
- Estudiante obligatorio.
- Ejercicio obligatorio.

Comportamiento:
- Los selectores pueden ser DropdownButtonFormField con datos dummy.
- Iniciar evaluación valida campos.
- Si es válido, crea sesión mock y navega a /assessment/instructions.
- Flecha atrás vuelve al detalle de ejercicio.

Pantalla 4: Instrucciones para estudiante

Referencia:
docs/figma/BLOCK-3-EXERCISES-CATALOG-ASSESSMENT/Instrucciones para estudiante.png

Debe incluir:
- Header con flecha atrás.
- Título:
  “Instrucciones”
- Imagen/ilustración de búho o mascota si ya existe asset; si no, usar placeholder amigable con icono.
- Título:
  “¡Antes de empezar!”
- Texto:
  “Lee el texto en voz alta cuando el docente te lo indique”
- Banner:
  “Hazlo con calma, no es un examen”
- Botón naranja:
  “¡Comenzar! ▶”
- Botón secundario:
  “Volver”

Comportamiento:
- Comenzar navega a la pantalla de evaluación según el tipo de ejercicio seleccionado.
- Volver regresa a configuración de evaluación.

Pantalla 5: Evaluación de lectura en voz alta

Referencia:
docs/figma/BLOCK-3-EXERCISES-CATALOG-ASSESSMENT/Evaluación de lectura en voz alta.png

Debe incluir:
- Header con flecha atrás.
- Título:
  “¡Vamos a leer juntos!”
- Timer visual:
    - 00 minutos
    - 15 segundos
- Card central con texto grande:
  “El sol brilla en el cielo azul y las aves cantan”
- Botón circular naranja con icono de micrófono.
- Banner verde:
  “Lo estás haciendo muy bien”
- Botones inferiores:
    - Pausar
    - Finalizar

Comportamiento:
- El timer puede ser simulado.
- El botón micrófono cambia estado visual grabando/no grabando.
- Pausar cambia estado y muestra SnackBar.
- Finalizar llama a MockAssessmentService.finishSession y vuelve al detalle de estudiante, al catálogo o muestra SnackBar según el flujo existente.
- No grabar audio real todavía.
- Dejar TODO donde después irá la captura de audio y envío al backend.

Pantalla 6: Evaluación de escritura digital

Referencia:
docs/figma/BLOCK-3-EXERCISES-CATALOG-ASSESSMENT/Evaluación de escritura digital.png

Debe incluir:
- Header con flecha atrás.
- Título:
  “¡Vamos a escribir!”
- Card superior:
  “Escribe esta frase:”
  “El gato duerme.”
- Label:
  “Escribe aquí”
- Área grande de escritura digital.
- Mostrar placeholder “Escribe aquí...”
- Puede mostrar trazos simulados o implementar canvas simple si ya existe estructura.
- Banner verde:
  “Lo estás haciendo muy bien”
- Botones:
    - Limpiar
    - Finalizar

Comportamiento:
- Limpiar borra trazos si se implementa canvas; si no, limpia estado simulado.
- Finalizar llama a MockAssessmentService.finishSession.
- No implementar OCR real.
- No enviar imagen real al backend.
- Dejar TODO donde después irá captura de trazos, imagen y envío a backend.

Pantalla 7: Arma la palabra

Referencia:
docs/figma/BLOCK-3-EXERCISES-CATALOG-ASSESSMENT/Arma la palabra.png

Debe incluir:
- Header con flecha atrás.
- Título:
  “Forma la palabra”
- Pregunta:
  “¿Qué es esto?”
- Zona grande:
  “Arrastra aquí”
- Texto:
  “Suelta las sílabas en orden”
- Espacios punteados para formar la palabra.
- Banner verde:
  “¡Genial! Lo estás haciendo bien”
- Botones o sílabas dummy si aparecen en el Figma.

Comportamiento:
- Puede ser interacción simulada.
- No implementar drag and drop complejo si toma demasiado.
- Se puede simular selección de sílabas.
- Finalizar o acción correspondiente muestra SnackBar.

Pantalla 8: Elige la palabra correcta

Referencia:
docs/figma/BLOCK-3-EXERCISES-CATALOG-ASSESSMENT/Elige la palabra correcta.png

Debe incluir:
- Header con flecha atrás.
- Título:
  “¡Elige la palabra!”
- Pregunta:
  “¿Qué es esto?”
- Imagen de manzana o placeholder visual similar.
- Opciones de palabra:
    - manzana
    - mansana
    - mazana
- Botón o selección según Figma.
- Feedback visual cuando seleccione opción correcta/incorrecta.

Comportamiento:
- Si selecciona “manzana”, mostrar feedback correcto.
- Si selecciona otra, mostrar feedback de intento.
- No registrar resultado real todavía.
- Dejar TODO para envío de respuesta al backend futuro.

Buenas prácticas obligatorias:
- Aplicar MVVM.
- Usar servicios abstractos y mocks.
- No usar datos quemados directamente en páginas.
- Los ViewModels manejan estado, loading, selección, errores y acciones.
- Las páginas solo renderizan UI y ejecutan eventos.
- Reutilizar AppHeader, PrimaryButton, AppTextField, AppBottomNav, InfoBanner y widgets existentes.
- Crear widgets nuevos solo si son reutilizables.
- Mantener nombres de archivos en snake_case.
- Usar const cuando sea posible.
- No duplicar colores hardcodeados si ya existen en app_colors.dart.
- No duplicar estilos si ya existen en app_text_styles.dart.
- No dejar imports sin usar.
- No dejar código muerto.
- No romper rutas existentes.
- No cambiar el diseño de bloques anteriores.

Resultado esperado:
- La app compila.
- flutter analyze no tiene errores.
- El bottom navigation permite entrar a Catálogo/Ejercicios.
- Se puede navegar: Dashboard -> Catálogo -> Detalle ejercicio -> Configurar sesión -> Instrucciones -> Evaluación.
- Todo funciona con datos mock.
- No existe integración real con backend.
- El código queda listo para reemplazar MockServices por ApiServices en el futuro.

Al finalizar, explícame:
1. Qué archivos creaste.
2. Qué archivos modificaste.
3. Qué rutas nuevas agregaste.
4. Cómo probar el flujo completo desde login.
5. Qué quedó mockeado.
6. Dónde se conectaría backend real después.