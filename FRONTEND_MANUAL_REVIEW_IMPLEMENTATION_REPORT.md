# Frontend Manual Review Implementation Report

Fecha: 20 de septiembre de 2026. Proyecto: `D:\TESIS\tamizia_app`, base `1c26edf`. Backend inspeccionado: `D:\TESIS\backend`, commit `474b3e3`.

## 1. Resumen

Implementada la revisión manual docente de Writing y Speaking desde el detalle de evaluaciones completadas. Incluye evidencia, edición del texto reconocido, ajustes explícitos de métricas de Speaking, confirmación, reversión, historial y recarga de resultados.

El backend conserva la responsabilidad de calcular métricas derivadas, puntajes e intervención. Flutter valida el formulario y presenta las respuestas del servidor. No se añadieron dependencias ni se modificó el backend.

## 2. Backend inspeccionado

Se leyeron `BACKEND_MANUAL_REVIEW_FINAL_CONTRACT.md`, `BACKEND_MANUAL_REVIEW_PHASE4_REPORT.md` y la auditoría histórica `BACKEND_MANUAL_REVIEW_AUDIT.md`. Se contrastaron con:

- `app/assessment/presentation/schemas.py`: requests y respuestas de review/manual-review.
- `app/assessment/presentation/routes.py`: GET review, PATCH manual-review, composición de evidencia, métricas y análisis.
- `app/assessment/application/use_cases/manual_review_exercise_attempt.py`: acciones, correcciones, validaciones, versiones, snapshots y fuentes.
- `app/assessment/application/exercise_score_service.py` y comparadores de texto: cálculo exclusivamente servidor.
- Repositorios de scores/eventos en `app/assessment/infrastructure/repositories/assessment_repositories.py`: persistencia y orden del historial.

La auditoría es anterior al código actual; se usó el código como referencia definitiva. El único archivo no versionado del backend al inicio y al cierre es la auditoría preexistente; no se alteró.

## 3. Contrato real consumido

| Operación | Endpoint | Uso |
| --- | --- | --- |
| GET | `/api/v1/assessments/attempts/{attempt_id}/review` | Carga y recarga del ejercicio, evidencia, scores, fuentes, historial y resultado general |
| PATCH | `/api/v1/assessments/exercise-attempts/{exercise_attempt_id}/manual-review` | `confirm`, `correct_evidence`, `override_metrics`, `revert` |
| GET existente | Resultado del intento mediante `getResult` | Recarga de pantalla de resultados al volver del detalle |
| GET existente | Historial mediante `getStudentHistory` | Recarga de lista, resumen y gráficos al volver del detalle |

GET exercise usa `type`, `review_required`, `review_version`, `review_status`, `original_score`, `current_score`, `metrics.original_metrics`, `metrics.current_metrics`, `response`, `metric_sources`, `automatic_analysis`, `reviewed_analysis`, `manual_review_history` y metadatos del ajuste.

PATCH usa `action`, `teacher_observation`, `base_review_version`; añade `corrections` o `metrics` según la acción. No se envían `teacher_id`, `evidence_version`, puntajes calculados ni nivel de intervención.

La respuesta PATCH usa `exercise_type` y `manual_review_required`; sus métricas están en la raíz. `assessment_result` sólo contiene `original_final_score` y `current_final_score`. El nivel vigente se obtiene del GET posterior.

## 4. Arquitectura frontend encontrada

Flutter con páginas Stateful, estado `ChangeNotifier`, inyección por constructor y rutas nombradas en `app.dart`. Flujo de datos existente: `ApiClient`/Dio → datasource → repository → dominio → viewmodel/página. Se conserva la autenticación y renovación de sesión del cliente común. Se reutilizan tema, espaciado, tarjetas, estados, encabezados y botones.

## 5. Archivos modificados

Rutas relativas a la raíz del frontend:

```text
lib/app.dart
lib/core/constants/app_routes.dart
lib/core/network/api_error_mapper.dart
lib/core/network/api_exception.dart
lib/features/assessment/domain/models/attempt_review.dart
lib/features/assessment/domain/models/manual_review.dart                         [nuevo]
lib/features/assessment/domain/repositories/assessment_repository.dart
lib/features/assessment/data/models/attempt_review_dto.dart
lib/features/assessment/data/models/manual_review_dto.dart                       [nuevo]
lib/features/assessment/data/datasources/assessment_remote_data_source.dart
lib/features/assessment/data/datasources/assessment_remote_data_source_impl.dart
lib/features/assessment/data/repositories/assessment_repository_impl.dart
lib/features/assessment/presentation/pages/manual_review_page.dart               [nuevo]
lib/features/assessment/presentation/pages/attempt_review_page.dart
lib/features/assessment/presentation/pages/assessment_result_page.dart
lib/features/assessment/presentation/pages/student_history_page.dart
lib/features/assessment/presentation/pages/reading_assessment_page.dart
lib/features/assessment/presentation/pages/writing_assessment_page.dart
lib/features/assessment/presentation/viewmodels/manual_review_viewmodel.dart     [nuevo]
lib/features/assessment/presentation/viewmodels/reading_assessment_viewmodel.dart
lib/features/assessment/presentation/viewmodels/writing_assessment_viewmodel.dart
lib/features/assessment/presentation/widgets/manual_review_status_badge.dart     [nuevo]
lib/features/assessment/presentation/widgets/review_evidence_media.dart          [extraído]
test/features/assessment/manual_review_contract_test.dart                       [nuevo]
test/features/assessment/manual_review_viewmodel_test.dart                      [nuevo]
test/features/assessment/manual_review_widget_test.dart                         [nuevo]
test/features/assessment/manual_review_refresh_test.dart                        [nuevo]
test/features/assessment/manual_review_evidence_lock_test.dart                  [nuevo]
test/features/assessment/manual_review_fixtures.dart                            [nuevo]
test/features/assessment/phase1_contract_test.dart
FRONTEND_MANUAL_REVIEW_IMPLEMENTATION_REPORT.md                                 [nuevo]
```

## 6. Modelos/DTOs

Se añadieron tipos para acciones, estado de revisión, fuentes de métricas, evidencia, análisis/alineación, eventos históricos, request, respuesta PATCH y argumentos de navegación. `ExerciseReview.manualReview` encapsula estos datos sin romper los consumidores anteriores.

El parser conserva números nulos, distingue cero, tolera campos opcionales ausentes y representa estados/fuentes desconocidos como desconocidos. Una versión ausente no se interpreta como cero: bloquea guardar hasta obtener una versión válida. La respuesta PATCH se valida antes de usar su versión.

## 7. API/repository

`manualReviewExercise` atraviesa las interfaces y sus implementaciones existentes. El datasource realiza PATCH autenticado y convierte errores con `ApiErrorMapper`. Las pruebas verifican método, ruta, cabecera Bearer y cuerpo exacto. El cliente no reintenta mutaciones por red/5xx/conflicto; conserva el mecanismo común de renovación de autenticación ante 401.

## 8. Entry point

Botón `Revisar manualmente` o `Ver revisión manual` en la tarjeta del ejercicio, exclusivamente para `READING_WRITING` y `READING_SPEAKING` con intento `COMPLETED`. Navega a `/assessment/manual-review` con IDs tipados, y la pantalla obtiene una revisión nueva del servidor. No se habilita en otros tipos ni en intentos pendientes.

## 9. Writing

Muestra instrucciones, imagen completa, visor ampliable con zoom/pan, texto esperado, OCR automático y texto revisado guardado. El editor produce una transcripción completa y exige texto no vacío cuando hay corrección. Presenta score y métricas originales/vigentes, motivo, estado e historial.

Se reutilizó y extrajo el visor previo. Se añadió renovación de evidencia mediante GET y estados de carga/error. Writing no ofrece edición manual de CER/WER/accuracies; una corrección favorable o desfavorable se expresa mediante el texto que realmente contiene la imagen.

## 10. Speaking

Muestra audio de sólo lectura con reproducir, pausar, reanudar, desplazamiento, duración y reinicio; usa el reproductor `audioplayers` existente. Muestra referencia, transcripción automática de Whisper, reconocimiento de Azure si está disponible y transcripción revisada.

Permite ajustar `accuracy_score`, `fluency_score`, `pronunciation_score`, `completeness_score` entre 0 y 100, incluidos extremos y decimales. Una métrica ausente se presenta vacía/«No disponible». No se puede reemplazar un valor existente por vacío. `lexical_match` se consulta; su corrección principal es editar la transcripción. La alineación de texto se muestra cuando la entrega el servidor.

## 11. Confirm

Disponible sin revisión previa, sin correcciones pendientes y con motivo no vacío. No reenvía métricas. Ejemplo del cuerpo serializado por Flutter:

```json
{"action":"confirm","teacher_observation":"La evidencia automática es aceptable.","base_review_version":0}
```

Se recarga GET después de confirmar. Una confirmación no se presenta como restauración de valores: para ello existe revert.

## 12. Correct evidence

Se envía sólo el campo correspondiente al tipo. Estos ejemplos muestran la estructura real serializada; los valores son ilustrativos, no datos de alumnos ni solicitudes ejecutadas contra producción.

Writing:

```json
{"action":"correct_evidence","teacher_observation":"La imagen contiene la palabra PERRO.","base_review_version":0,"corrections":{"recognized_text":"EL PERRO CORRE"}}
```

Speaking:

```json
{"action":"correct_evidence","teacher_observation":"La grabación incluye la palabra es.","base_review_version":3,"corrections":{"free_transcription_text":"Mi casa es azul."}}
```

La observación y el texto se recortan con trim. Flutter no calcula alineación, CER, WER, similitud, precisión, lexical match ni score después de editar.

## 13. Override metrics

Sólo se envían las métricas modificadas. Una representación distinta del mismo número (`70`, `70.0`, `70,0`) no genera un cambio falso.

```json
{"action":"override_metrics","teacher_observation":"Contrasté texto y pronunciación con el audio.","base_review_version":7,"metrics":{"accuracy_score":92,"fluency_score":85.5}}
```

Cuando también cambia el texto: PATCH correct_evidence → versión devuelta por ese PATCH → PATCH override_metrics → GET review. El `7` del ejemplo debe proceder de la respuesta anterior, nunca de una suma local.

Si falla el segundo PATCH, se informa que el texto ya se guardó y se recarga. Sólo se conserva el borrador de métricas si la versión recargada coincide con la confirmada por el primer PATCH. El reintento es explícito y sólo envía métricas pendientes; no se hace rollback ni se repite el texto.

## 14. Revert

Se ofrece con revisión previa y motivo obligatorio, tras diálogo de confirmación. Restaura los valores que determine el backend y mantiene el historial. No se reenvían snapshots desde Flutter.

```json
{"action":"revert","teacher_observation":"Restaurar la interpretación automática original.","base_review_version":9}
```

## 15. review_version

Cada primera acción usa la versión del GET vigente. En secuencia, la segunda usa exactamente la respuesta de la primera. Se verifica que el PATCH corresponda al ejercicio y que la versión avance; nunca se da por confirmado `base + 1`. Los tests incluyen un salto de versión a 11.

Durante guardado se deshabilitan acciones repetidas y salida. Si PATCH funciona pero GET falla, se comunica que ya quedó guardado y se bloquea otra mutación hasta recargar.

## 16. Errores 409

`ConflictException` conserva `code`. `MANUAL_REVIEW_VERSION_CONFLICT` muestra mensaje amigable, recarga y descarta el borrador obsoleto. Si la recarga falla, guardar permanece bloqueado.

`ASSESSMENT_EVIDENCE_LOCKED` tiene mensaje específico. La revisión no incluye uploads. Además, las pantallas de captura existentes deshabilitan el envío después de recibir este código y sus viewmodels rechazan llamadas repetidas a upload para ese ejercicio. Se verifica ese bloqueo en Writing.

400/422 muestran validación; 401 usa sesión; 403 indica permisos; 404 indica recurso no visible; red/5xx permiten recuperación. Un resultado de escritura incierto exige consultar el GET antes de una nueva decisión.

## 17. Original/current/metric sources

Se comparan «Automático original» y «Vigente» con valores independientes. Las fuentes se traducen como automática, recalculada desde texto revisado o ajustada por docente. Una fuente desconocida se presenta como no informada; en la versión inicial se identifica el origen automático.

No se presenta un null como cero ni se calcula un resultado faltante. Calidad técnica, elegibilidad y revisión son conceptos separados. Las limitaciones de procedencia del backend en acciones consecutivas se detallan en la sección 23.

## 18. Historial

Se presentan eventos recientes primero, traduciendo la acción, fecha local, identificador del revisor, motivo, texto corregido y métricas enviadas. No se muestra JSON crudo. El backend entrega el identificador, no el nombre del docente; tampoco entrega un diff before/after dentro de los eventos de este GET.

## 19. Refresh

Después de la mutación o secuencia se consulta GET review. Al salir de revisión manual, el detalle se recarga; al volver desde el detalle, se recargan resultado o historial según el origen de navegación. Se incluyen controles mounted para respuestas tardías.

Si falla actualizar el resultado general, se oculta el resultado anterior y aparece una acción de reintento. La revisión muestra feedback inline y mediante Snackbar, también cuando se guarda al final del formulario. Renovar la evidencia vuelve a GET y pide descartar borradores si existen; no almacena URLs como permanentes ni construye URLs desde blob paths.

## 20. Tests agregados

47 pruebas nuevas, distribuidas en cinco archivos de tests y un archivo de fixtures:

- Contrato: null/zero, versiones, estados, textos revisados, análisis, historial, fuentes, cuerpos de las cuatro acciones, repository/PATCH autenticado y errores HTTP.
- Viewmodel: cambios reales, motivo, rango numérico, Writing, secuencia con versión devuelta, doble envío bloqueado, fallo parcial y reintento exclusivo, conflicto, timeout, fallo del GET posterior, confirm/revert, tipos/estados no editables y respuesta después de dispose.
- Widgets: tipos habilitados, intento pendiente, Writing/Speaking, validación, carga/error/reintento, salida con borrador, reversión cancelada, historial, recarga del detalle, pantalla de 360 px con texto ampliado y visor de zoom.
- Refresh: resultado/nivel e historial/resumen al volver.
- Evidencia bloqueada: no repetir upload después del 409.

También se precisó una comprobación existente de `phase1_contract_test.dart`: busca fluidez dentro del panel de métricas, porque el score del ejercicio puede tener el mismo texto `90.0 / 100`. Se conserva la verificación del valor, sin confundir dos campos distintos.

## 21. Resultado de tests/analyzer

Validación con el SDK local Flutter 3.41.9 / Dart 3.11.5, sin actualizar dependencias:

- `dart format` en archivos Dart modificados/nuevos.
- `dart analyze lib test`: **No issues found**, código de salida 0.
- `flutter test --no-pub --reporter expanded`: **138 pruebas aprobadas**, código de salida 0; incluye las 47 nuevas y las 91 existentes. Log local: `.dart_tool/manual-review-tests.log`.
- `flutter test --no-pub test/features/assessment/manual_review_widget_test.dart`: 15/15 aprobadas tras el último ajuste de pantalla.
- `git diff --check`: sin errores.

Los tests usan respuestas controladas y el contrato inspeccionado. No equivalen a pruebas de producción, reproducción real de audio ni interacción física en un dispositivo.

## 22. Limitaciones

No se ejecutaron PATCH contra una cuenta real ni pruebas en dispositivo/emulador con evidencia alojada. Queda la comprobación de URLs firmadas, conectividad, audio y accesibilidad con teclado/lector de pantalla real descrita en la sección 24. No se generó un APK ni se publicó una versión.

Se soporta evidencia remota HTTP/HTTPS. Si el backend devuelve una URL local `file://`, blob path aislado, URL ausente o caducada, se informa y se permite renovar mediante GET. No se intenta adivinar un endpoint de descarga.

Los ejercicios con `technical_status=INVALID` quedan sólo lectura porque el caso de uso backend rechaza sus acciones. El usuario necesita un nuevo intento válido. La pantalla permite ajustes de evidencia PARTIAL cuando el backend lo admite.

## 23. Diferencias entre contrato y código real

| Esperado | Real inspeccionado | Impacto y tratamiento frontend | Cambio backend necesario |
| --- | --- | --- | --- |
| Marcado Writing por token/carácter si hay alineación | Análisis Writing contiene texto y métricas; no alineación | Editor de texto completo; no se inventa un diff/tokenización evaluativa | Exponer alineación original/revisada para habilitar edición granular |
| Detalle Speaking word/phoneme de proveedor si existe | GET ofrece alineación del comparador de texto Whisper; no detalle fonético de Azure | Se muestran operaciones de texto recibidas; no se afirma que sean fonemas | Exponer un contrato explícito del detalle Azure si se requiere |
| `reviewed_analysis` conservado tras combinar texto y overrides | Override recompone scoring_components y puede eliminar el análisis revisado, aunque el texto revisado persiste | Se muestra texto revisado y análisis sólo si existe; no se recalcula en Flutter | Conservar `reviewed_analysis` al actualizar componentes |
| Fuentes persistentes por métrica en revisiones sucesivas | `_metric_sources_for_action` marca como automática toda clave no incluida en el último override; correct_evidence marca Azure automático incluso si conserva valores previamente ajustados | Se muestra lo recibido; la etiqueta de origen puede perder trazabilidad después de acciones combinadas/sucesivas | Combinar fuentes anteriores con cambios de la acción; preservar procedencia de valores retenidos |
| Confirmar equivale siempre al automático | Confirm conserva valores vigentes y limpia fuentes/flag de ajuste | Acción visible sólo sin revisión previa; revert explícito para restaurar | Si se quiere confirmar después de ajustes, definir semántica y conservar procedencia |
| Resultado PATCH completo con intervención | PATCH entrega sólo original/current final score | GET posterior aporta resultado e intervención vigentes | Ninguno para este flujo; ampliar respuesta sólo si se quiere evitar GET |
| Nombre del revisor y diff histórico | Eventos GET tienen teacher_id, correcciones y métricas enviadas, sin nombre/before-after | Identificador y cambios declarados legibles | Ampliar el DTO de historia si se necesita nombre/diff |
| Texto revisado potencialmente vacío | Caso de uso exige string no vacío para correct_evidence | Validación explícita; no se permite borrar todo el texto | Definir un flujo servidor específico si se necesita marcar ausencia total de texto |
| Longitud máxima de motivo | No hay max_length declarado en schema/caso de uso actual | Trim obligatorio sin límite ficticio de caracteres | Declarar límite si el producto lo necesita |

Estas diferencias se documentan; no se hicieron correcciones en el backend ni se sustituyó su scoring.

## 24. Pasos de prueba manual

Usar un entorno de pruebas autenticado, con un intento COMPLETED que contenga Writing y Speaking, URLs accesibles y al menos un caso PARTIAL. Los siguientes pasos quedan para validación con servidor y dispositivo reales:

1. Abrir historial → evaluación → ejercicio. Confirmar que el botón no aparece en Multiple Choice, Order Syllables, tipos Listening ni intentos sin completar.
2. Writing favorable: ampliar imagen, hacer zoom/pan, corregir `EL PERO CORRE` a `EL PERRO CORRE` sólo si coincide con la imagen; escribir motivo; guardar. Comprobar PATCH correct_evidence, versión enviada, original intacto y resultados devueltos.
3. Writing desfavorable: corregir un OCR demasiado favorable al texto realmente escrito. Verificar que la interfaz acepta una corrección que reduce score según backend, sin imponer una mejora.
4. Speaking: reproducir/pausar/reanudar, mover posición y reiniciar. Corregir la transcripción según audio; comprobar lexical_match y score retornados, sin cambiar automáticamente Azure en Flutter.
5. Speaking override: probar 0, 100 y decimal; comprobar rechazo de negativos, >100, NaN, texto y borrar un valor existente. Enviar sólo las claves modificadas con observación.
6. Combinado: cambiar transcripción y dos métricas. Inspeccionar dos PATCH secuenciales y que el segundo use la versión devuelta por el primero. Provocar fallo del segundo; comprobar mensaje de éxito parcial y reintento sólo de métricas, sin repetir correct_evidence.
7. Confirm: sin edición previa, introducir motivo y confirmar. Verificar que no se envían métricas y que aparece estado confirmado.
8. Revert: introducir motivo, abrir diálogo y cancelar; no debe enviarse PATCH. Repetir y aceptar; verificar valores automáticos, texto revisado retirado y eventos históricos conservados.
9. Conflicto: abrir el mismo ejercicio en dos sesiones. Guardar desde una y después intentar guardar la otra. Verificar 409, recarga, borrador descartado y nueva versión, sin sobrescribir.
10. Red: interrumpir GET inicial y reintentar; interrumpir GET después de PATCH exitoso y comprobar que no se repite el PATCH. Simular timeout del PATCH y verificar reconciliación antes de guardar otra vez.
11. Navegación: editar y volver con gesto/botón; comprobar diálogo de descarte. Guardar y volver a detalle → resultado/historial; verificar score, promedios, resumen e intervención actuales del servidor.
12. Evidencia: renovar URL caducada; revisar estados de imagen/audio ausentes o fallidos. Confirmar que no se pueden subir archivos desde revisión y que una captura antigua bloquea nuevos envíos al recibir ASSESSMENT_EVIDENCE_LOCKED.
13. Accesibilidad: repetir en teléfono/tablet, con texto ampliado y teclado abierto; comprobar observación, botones, foco, lectura de etiquetas y controles multimedia.
