Quiero que integres el módulo de assessments en el frontend Flutter por fases, respetando el backend real ya analizado.

Contexto importante:

* Este proyecto es el frontend Flutter de TamizIA.
* Ya existe arquitectura MVVM.
* Auth, teacher, classrooms y students ya están integrados o en integración.
* Ya existen varias pantallas diseñadas del flujo de ejercicios/evaluación.
* PERO no todas están implementadas todavía en Flutter: algunas solo existen en Figma.
* No quiero que inventes flujo ni contratos.
* Debes basarte en el análisis real del backend de assessments.
* Si una pantalla necesaria para esta fase no existe todavía en Flutter, debes implementarla también siguiendo el Figma y la arquitectura actual.

## Resumen del backend que debes respetar

El backend sigue este flujo real:

### Configuración

1. Crear `exercise`
2. Crear `template`
3. Adjuntar `exercise` al `template`

### Ejecución

4. Crear `assessment` para un aula
5. Iniciar `attempt` para un estudiante
6. Al iniciar el attempt, el backend crea automáticamente los `exercise_attempt_id`
7. Las respuestas se envían usando esos `exercise_attempt_id`
8. Luego se hace `finish attempt`
9. Luego se obtiene `result`

Diferencias conceptuales importantes:

* `template` = plantilla reusable
* `exercise` = ejercicio reusable
* `assessment` = evaluación asignada a un aula
* `attempt` = intento de un estudiante
* `exercise_attempt` = instancia concreta de cada ejercicio dentro del intento

No asumir que el frontend puede responder ejercicios sin haber iniciado antes un `attempt`.

## Endpoints relevantes del backend

### Templates

* `GET /api/v1/assessments/templates`
* `POST /api/v1/assessments/templates`
* `GET /api/v1/assessments/templates/{template_id}`

### Exercises

* `GET /api/v1/assessments/exercises`
* `GET /api/v1/assessments/exercises/{exercise_id}`
* `POST /api/v1/assessments/exercises`
* `POST /api/v1/assessments/templates/{template_id}/exercises`

### Assessments

* `GET /api/v1/assessments`
* `POST /api/v1/assessments`
* `GET /api/v1/assessments/{assessment_id}`

### Attempts

* `GET /api/v1/assessments/{assessment_id}/attempts`
* `POST /api/v1/assessments/{assessment_id}/attempts`
* `GET /api/v1/assessments/attempts/{attempt_id}`

### Responses

* `POST /api/v1/assessments/exercise-attempts/{exercise_attempt_id}/mc-response`

* `GET /api/v1/assessments/exercise-attempts/{exercise_attempt_id}/mc-response`

* `POST /api/v1/assessments/exercise-attempts/{exercise_attempt_id}/os-response`

* `GET /api/v1/assessments/exercise-attempts/{exercise_attempt_id}/os-response`

* `POST /api/v1/assessments/exercise-attempts/{exercise_attempt_id}/speaking-response`

* `GET /api/v1/assessments/exercise-attempts/{exercise_attempt_id}/speaking-response`

* `POST /api/v1/assessments/exercise-attempts/{exercise_attempt_id}/writing-response`

* `GET /api/v1/assessments/exercise-attempts/{exercise_attempt_id}/writing-response`

### Finish / result

* `POST /api/v1/assessments/attempts/{attempt_id}/finish`
* `GET /api/v1/assessments/attempts/{attempt_id}/result`

### Extra

* `GET /api/v1/assessments/responses/{exercise_attempt_id}/download-url`

No uses los endpoints `dev/speech/*` como parte del flujo real del producto.

## Pantallas existentes y pantallas faltantes

### Pantallas que ya existen o están diseñadas

* Catálogo de ejercicios
* Detalle de ejercicio
* Nueva evaluación
* Instrucciones
* Evaluación de lectura en voz alta
* Evaluación de escritura digital
* Arma la palabra
* Elige la palabra correcta
* Resultado de sesión
* Comparación de texto esperado vs reconocido
* Repetir evaluación
* Historial del estudiante
* Privacidad y tratamiento de datos
* Error / sesión fallida

### Importante

No asumas que todas esas pantallas ya están implementadas en Flutter.

Regla:

* si ya existen en Flutter, intégralas o ajústalas
* si todavía no existen y son necesarias para esta fase, créalas siguiendo el Figma y la arquitectura actual
* si una pantalla existe pero no encaja con el backend real, modifícala

## Lo que quiero que hagas ahora

### NO implementes todo de golpe.

Quiero integración por fases.

## FASE 1: estructura real de catálogo y evaluación

Implementa primero estas pantallas y flujos reales:

### 1. Catálogo de templates

Crear una nueva pantalla si no existe.

Debe consumir:

* `GET /api/v1/assessments/templates`

Debe mostrar:

* nombre
* descripción
* versión si existe
* estado si existe
* CTA para ver detalle o seleccionar

Si el backend no devuelve suficiente información en el listado, usa lo disponible sin inventar datos.

### 2. Detalle de template

Crear una nueva pantalla si no existe.

Debe consumir:

* `GET /api/v1/assessments/templates/{template_id}`

Debe mostrar:

* nombre
* descripción
* versión
* resumen de la plantilla

Si el endpoint no devuelve ejercicios adjuntos, no inventarlos.
En ese caso:

* documenta la limitación
* muestra la información real disponible
* deja la UI preparada para enriquecerla después si aparece un endpoint mejor

### 3. Nueva evaluación

Modificar la pantalla actual de “Nueva evaluación”.

Debe alinearse al backend real:

* aula
* estudiante
* template / evaluación preconfigurada
* resumen de sesión
* validación de consentimiento
* botón para crear assessment e iniciar el flujo correcto

No debe seguir representando solo un ejercicio aislado si eso no encaja con el backend.

### 4. Crear assessment

Debe usar:

* `POST /api/v1/assessments`

Debe guardar:

* `assessment_id`

### 5. Iniciar attempt

Debe usar:

* `POST /api/v1/assessments/{assessment_id}/attempts`
  con `student_id`

Debe guardar:

* `attempt_id`
* `exercise_attempt_id` de cada ejercicio retornado

### 6. Resumen previo del intento

Crear una nueva pantalla si no existe.

Debe mostrar:

* aula
* estudiante
* template / assessment
* lista o resumen de ejercicios retornados en el attempt
* consentimiento
* botón “Comenzar”

Esta pantalla debe servir como puente antes de entrar a la ejecución real.

### 7. Estado de consentimiento faltante

Si el backend impide iniciar el attempt por falta de consentimiento, crear el estado visual correspondiente si todavía no existe:

* pantalla
* modal
* banner
* o estado vacío claro

Debe comunicar que no se puede iniciar la evaluación sin consentimiento válido.

### 8. Estado de intento pendiente / reanudar

Si al listar attempts se detecta un intento en progreso o incompleto, preparar el estado visual para:

* continuar
* ver detalle
* o manejar reanudación

Si todavía no existe esa pantalla/componente, créalo de forma mínima pero consistente con el design system.

## FASE 2: ejecución de ejercicios usando exercise_attempts

Después, deja preparada o implementa en una segunda fase:

* lectura -> speaking-response
* escritura -> writing-response
* arma la palabra -> os-response
* elige la palabra correcta -> mc-response

Pero solo si la FASE 1 queda bien.

## Lo que debes revisar en las pantallas actuales

### Mantener

Estas pantallas encajan y deben conservarse:

* Catálogo de ejercicios
* Detalle de ejercicio
* Instrucciones
* Lectura
* Escritura
* Arma la palabra
* Elige la palabra correcta
* Resultados
* Comparación
* Historial del estudiante
* Error/sesión fallida

### Modificar

* “Nueva evaluación” para que represente template/assessment/attempt, no solo ejercicio aislado.
* Ajustar flujo de selección para usar IDs reales del backend.
* Ajustar pantallas para no asumir datos que todavía no existen antes del attempt.

### Agregar si faltan en Flutter

* Catálogo de templates
* Detalle de template
* Resumen previo de intento
* Estado de intento pendiente/reanudar
* Estado de consentimiento faltante

## Arquitectura requerida

Mantén MVVM y arquitectura limpia.

Flujo:

Page
-> ViewModel
-> Repository
-> RemoteDataSource
-> ApiClient protegido por Bearer/refresh ya existente

No hagas HTTP desde páginas.
No hagas lógica de tokens en assessment.
No rompas auth/classrooms/students.

## Módulos sugeridos

Puedes crear o adaptar módulos como:

* templates
* exercises
* assessments
* attempts
* responses
* results

Pero no dupliques estructuras existentes si ya hay algo cercano.

## Figma

Usa las pantallas ya diseñadas en Figma como referencia visual.
Si una pantalla necesaria no existe en Flutter, constrúyela fiel al Figma o, si el Figma no la tiene, crea una versión mínima coherente con el design system actual.

## Restricciones

* No inventar endpoints.
* No inventar campos no soportados.
* No usar mocks en runtime para assessment.
* No asumir que `exercise_attempt_id` existe antes de iniciar el attempt.
* No integrar todavía los endpoints `dev/speech/*` como flujo de producto.
* No romper diseño general.
* No refactorizar módulos no relacionados.
* No implementar todo assessment en una sola pasada si eso vuelve el código inmanejable.

## Criterios de aceptación de esta fase

1. Existe catálogo/listado real de templates o equivalente usable.
2. Existe detalle de template o equivalente.
3. “Nueva evaluación” queda alineada al backend real.
4. Se puede crear assessment y luego iniciar attempt.
5. Se obtiene y conserva `attempt_id`.
6. Se obtienen y conservan `exercise_attempt_id`.
7. Existe resumen previo de intento.
8. Existe manejo visual de consentimiento faltante si aplica.
9. Existe estado básico de reanudar intento si aplica.
10. Se usan IDs reales y backend real.
11. Si una pantalla necesaria no existía en Flutter, fue implementada.
12. `flutter analyze` no muestra errores.

## Entrega final

Al terminar, explícame:

1. Qué pantallas nuevas agregaste.
2. Qué pantallas existentes modificaste.
3. Cuáles ya existían y cuáles tuviste que crear desde Figma.
4. Qué endpoints consumiste.
5. Qué IDs se guardan en cada paso.
6. Qué quedó listo para la siguiente fase.
7. Qué limitaciones del backend encontraste para template/detail.
8. Resultados de `flutter analyze`.
