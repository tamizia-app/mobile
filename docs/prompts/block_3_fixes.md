Necesito corregir y mejorar el BLOCK-3-EXERCISES-CATALOG-ASSESSMENT según pruebas manuales realizadas en Android/emulador.

IMPORTANTE:
- Mantén la arquitectura MVVM existente.
- No implementes backend real.
- No implementes Firebase.
- No implementes Azure real.
- No agregues HTTP, Dio, Retrofit ni base de datos.
- Todo debe seguir mockeado.
- No rompas BLOCK-1-AUTH ni BLOCK-2-DOCENTE-AULA-ESTUDIANTE.
- No cambies el diseño general del Figma, solo corrige funcionalidad, UX, responsive y estados.
- Ejecuta flutter analyze al final y corrige errores importantes.

Observaciones encontradas:

1. Catálogo de ejercicios: búsqueda no funciona.
2. Evaluación de lectura: el timer aparece en 00:15 fijo y no corre.
3. Evaluación de lectura: el botón de grabar no inicia un estado real de grabación simulado.
4. Evaluación de escritura: el área de trazos no permite dibujar.
5. Evaluación de escritura: aparece un trazo quemado de ejemplo que debe eliminarse.
6. Arma la palabra: al tocar una sílaba ya colocada, debería removerse del cuadro.
7. Arma la palabra: además de tap, debe permitir drag and drop de sílabas hacia las cajas.
8. Elige la palabra correcta: la tercera opción no se ve bien en pantallas pequeñas porque queda tapada por el botón siguiente.
9. Los ejercicios tipo juego no deben ser una sola pregunta; deben manejar una pila/lista de preguntas.
10. El botón “Finalizar” no debe aparecer desde el inicio en ejercicios con varias preguntas. Debe aparecer “Siguiente” hasta llegar a la última pregunta.
11. En ejecución de ejercicios, el botón de retroceso no debe salir directamente. Debe mostrar alerta de confirmación para cancelar y advertir que se perderá el progreso.
12. Revisar comportamiento del botón Pausar.

Correcciones requeridas:

A. Catálogo de ejercicios - búsqueda funcional

En la pantalla:
- /exercises/catalog

Implementar búsqueda local sobre los ejercicios mockeados.

Comportamiento:
- Al tocar el icono de búsqueda, mostrar un campo de búsqueda o activar modo búsqueda en el header.
- Filtrar ejercicios por:
    - título
    - descripción
    - categoría
    - tipo
- Si no hay resultados, mostrar mensaje:
  “No se encontraron ejercicios.”
- Debe combinarse con el filtro de chips:
    - Lectura
    - Escritura
    - Juegos
- No usar backend.
- No mostrar SnackBar de “no implementado” para búsqueda, porque ahora sí debe funcionar.

B. Evaluación de lectura - timer y grabación simulada

En la pantalla:
- /assessment/reading

Corregir el timer.

Comportamiento esperado:
- El timer debe iniciar en 00:00.
- El timer NO debe correr automáticamente al entrar.
- Al presionar el botón de micrófono:
    - cambiar estado a grabando
    - iniciar el timer desde 00:00
    - cambiar visualmente el botón de micrófono para indicar grabación activa
- Al volver a presionar micrófono, puede detener/reanudar grabación o mantenerlo como estado de grabación según implementación más simple.
- El botón Pausar debe:
    - detener temporalmente el timer
    - detener captura simulada
    - bloquear interacción principal
    - cambiar texto a “Reanudar”
- Al presionar Reanudar:
    - continúa el timer desde donde quedó
    - vuelve a estado de captura
- Finalizar:
    - detiene el timer
    - llama a MockAssessmentService.finishSession
    - muestra confirmación o navega según flujo actual

Importante:
- No implementar grabación real todavía.
- Dejar TODO claro para futura integración:
    - pedir permisos de micrófono
    - iniciar grabación real
    - guardar audio local temporal
    - enviar audio al backend
    - procesar con Azure Speech Pronunciation Assessment

Ejemplo de TODO:
/// TODO: reemplazar grabación simulada por captura real de audio.
/// Flujo futuro: request microphone permission -> start recorder -> save audio file -> upload to backend.

C. Evaluación de escritura - canvas real para trazos

En la pantalla:
- /assessment/writing

Corregir área de escritura.

Comportamiento esperado:
- Eliminar cualquier trazo quemado o dibujado de ejemplo.
- El usuario debe poder dibujar trazos con el dedo/mouse dentro del área de escritura.
- Implementar un canvas simple usando CustomPainter, GestureDetector o widget equivalente.
- Registrar puntos en memoria local del ViewModel o estado correspondiente.
- El botón “Limpiar” debe borrar todos los trazos.
- El botón “Finalizar” debe finalizar la sesión mock.
- El área de escritura debe respetar el diseño del Figma:
    - borde redondeado
    - fondo blanco
    - placeholder “Escribe aquí...” cuando no hay trazos
    - trazo oscuro
- No implementar OCR real.
- No enviar imagen real al backend.
- Dejar TODO claro:
    - capturar puntos, timestamps y presión si aplica
    - exportar canvas como imagen
    - enviar evidencia al backend
    - procesar con Azure AI Vision/OCR

D. Arma la palabra - interacción mejorada

En la pantalla:
- /assessment/build-word

Actualmente funciona con tap, pero debe mejorar.

Comportamiento requerido:
- Mantener selección por tap:
    - Al tocar una sílaba disponible, se coloca en la primera caja vacía.
- Nuevo comportamiento:
    - Al tocar una sílaba ya colocada dentro de una caja, se remueve y vuelve a estar disponible.
- Implementar drag and drop:
    - El usuario debe poder arrastrar una sílaba hacia una caja.
    - Al soltarla cerca o encima de la caja, debe pegarse como “imán”.
    - Si se suelta fuera de las cajas, debe volver a su posición/lista original.
- Las cajas deben mostrar la sílaba colocada.
- Las sílabas ya usadas no deben duplicarse abajo.
- El botón “Limpiar” debe reiniciar la pregunta actual.
- El botón “Comprobar” debe validar la palabra formada.

Validación mock:
- Palabra objetivo: “casa”
- Sílabas: “ca”, “sa”, “ma”
- Correcto si las cajas quedan: “ca” + “sa”
- Si es correcto, mostrar feedback positivo.
- Si es incorrecto, mostrar feedback de intento.

E. Elige la palabra correcta - responsive y scroll

En la pantalla:
- /assessment/choose-word

Corregir problema visual:
- La tercera opción no se ve porque queda tapada por el botón “Siguiente”.

Comportamiento visual esperado:
- La pantalla debe adaptarse a dispositivos pequeños.
- El contenido debe usar scroll si no entra.
- Los botones inferiores no deben tapar opciones.
- Si se mantiene una barra inferior fija, agregar padding inferior suficiente.
- La tercera opción debe verse y poder tocarse.
- El botón “Siguiente” debe estar después de las opciones o fijo abajo sin cubrir contenido.

Opciones dummy:
- Manzana
- Mansana
- Mazana

Validación mock:
- Correcta: Manzana
- Incorrectas: Mansana, Mazana

F. Ejercicios con varias preguntas

Implementar lógica de pila/lista de preguntas para ejercicios tipo juego:

Aplica a:
- /assessment/build-word
- /assessment/choose-word

No aplica necesariamente a:
- /assessment/reading
- /assessment/writing

Requisitos:
- Crear modelos si hace falta:
    - AssessmentQuestion
    - BuildWordQuestion
    - ChooseWordQuestion
- El ViewModel debe manejar:
    - currentQuestionIndex
    - totalQuestions
    - currentQuestion
    - selectedAnswer o placedSyllables
    - isLastQuestion
    - progressText, por ejemplo “1 de 3”
- Mostrar progreso visual o texto:
  “Pregunta 1 de 3”
- El botón debe comportarse así:
    - Si NO es la última pregunta: mostrar “Siguiente →”
    - Si ES la última pregunta: mostrar “Finalizar”
- No permitir avanzar si no se respondió la pregunta actual.
- Si intenta avanzar sin responder, mostrar mensaje de validación.
- Al pasar a la siguiente pregunta:
    - limpiar selección actual
    - cargar nueva pregunta
- Al finalizar:
    - llamar MockAssessmentService.finishSession
    - mostrar SnackBar o navegar según flujo actual

Datos dummy sugeridos:

BuildWord questions:
1. objetivo: casa
   sílabas: ca, sa, ma
   respuesta: ca + sa
2. objetivo: mesa
   sílabas: me, sa, se
   respuesta: me + sa
3. objetivo: pato
   sílabas: pa, to, ta
   respuesta: pa + to

ChooseWord questions:
1. imagen/ícono: manzana
   opciones: Manzana, Mansana, Mazana
   correcta: Manzana
2. imagen/ícono: casa
   opciones: Casa, Caza, Cassa
   correcta: Casa
3. imagen/ícono: pato
   opciones: Pato, Bato, Patoo
   correcta: Pato

G. Botón Finalizar vs Siguiente

Regla general:
- En ejercicios de una sola captura, como lectura y escritura, puede existir “Finalizar”.
- En ejercicios con varias preguntas, como Arma la palabra y Elige la palabra correcta:
    - mientras no sea la última pregunta: mostrar “Siguiente →”
    - en la última pregunta: mostrar “Finalizar”
- No mostrar Finalizar desde el inicio si hay varias preguntas pendientes.

H. Pausar en ejercicios

Definir comportamiento consistente para todos los ejercicios que tengan botón Pausar.

Regla:
Pausar NO debe permitir que el estudiante siga interactuando normalmente.

Cuando el usuario presiona “Pausar”:
- detener timer si existe
- bloquear interacción principal del ejercicio
- detener captura simulada si existe
- mostrar estado pausado
- cambiar botón a “Reanudar”
- opcionalmente mostrar overlay semitransparente:
  “Evaluación pausada”

Cuando presiona “Reanudar”:
- quitar bloqueo
- continuar timer
- permitir interacción nuevamente

No borrar progreso al pausar.
No finalizar la sesión al pausar.
Registrar en el ViewModel un estado:
- isPaused

Dejar TODO futuro:
- registrar timestamps de pausa/reanudación para que el backend no contamine métricas reales.

I. Confirmación al retroceder o cancelar durante evaluación

En pantallas de evaluación en ejecución:
- /assessment/reading
- /assessment/writing
- /assessment/build-word
- /assessment/choose-word

El botón de retroceso NO debe salir directamente.

Debe mostrar un AlertDialog:

Título:
“¿Cancelar evaluación?”

Mensaje:
“Si sales ahora, se perderá el progreso de esta evaluación.”

Botones:
- “Continuar evaluación”
- “Cancelar evaluación”

Comportamiento:
- Continuar evaluación: cierra el diálogo y mantiene la pantalla.
- Cancelar evaluación: cancela sesión mock y vuelve a la pantalla anterior o al catálogo/configuración según flujo.

También interceptar el botón back del sistema Android con PopScope o WillPopScope:
- Si está en evaluación activa, mostrar la misma alerta.
- No salir sin confirmar.

J. Responsive general del bloque 3

Revisar todas las pantallas del bloque 3:
- Catálogo
- Detalle
- Configurar sesión
- Instrucciones
- Lectura
- Escritura
- Arma la palabra
- Elige palabra

Asegurar:
- No hay overflow.
- Usar SingleChildScrollView cuando el contenido no entra.
- Agregar SafeArea.
- Agregar padding inferior si hay bottom navigation o botones fijos.
- Los botones no tapan contenido.
- Las cards no se cortan.
- El diseño se ve bien en pantallas Android pequeñas y medianas.

K. Mantener mocks y preparación backend

Todo debe seguir mockeado.

No implementar:
- grabación real
- OCR real
- Azure real
- Speech real
- HTTP
- base de datos

Pero dejar TODOs claros en servicios y ViewModels para futura integración.

Ejemplo:
class ApiAssessmentService implements AssessmentService {
// TODO futuro:
// POST /api/assessment-sessions/{id}/audio
// POST /api/assessment-sessions/{id}/writing-evidence
// PATCH /api/assessment-sessions/{id}/pause
// PATCH /api/assessment-sessions/{id}/resume
}

L. Criterios de aceptación

La corrección será aceptada si:

1. La búsqueda del catálogo filtra ejercicios correctamente.
2. El timer de lectura inicia en 00:00 y corre al presionar micrófono.
3. El botón de micrófono cambia estado visual de grabación simulada.
4. Pausar detiene timer/captura simulada y bloquea interacción.
5. Reanudar continúa correctamente.
6. El área de escritura permite dibujar trazos reales.
7. No aparece ningún trazo quemado de ejemplo.
8. Limpiar borra los trazos.
9. Arma la palabra permite tap para colocar sílabas.
10. Arma la palabra permite tocar sílaba colocada para removerla.
11. Arma la palabra permite drag and drop hacia cajas.
12. Elige palabra muestra todas las opciones sin que sean tapadas.
13. Las pantallas con varias preguntas usan “Siguiente” hasta la última.
14. Solo en la última pregunta aparece “Finalizar”.
15. El botón atrás durante evaluación muestra alerta de cancelación.
16. El back del sistema Android también muestra alerta de cancelación.
17. No hay overflows en pantallas pequeñas.
18. flutter analyze no muestra errores.
19. No se implementó backend real ni dependencias de red.
20. La arquitectura MVVM se mantiene limpia.

Al finalizar, explícame:
1. Qué archivos modificaste.
2. Qué ViewModels cambiaste.
3. Qué widgets nuevos creaste.
4. Cómo probar cada corrección.
5. Dónde quedaron los TODOs para backend, audio, OCR y evidencias.