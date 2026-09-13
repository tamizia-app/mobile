# TamizIA Design System

Sistema visual implementado en Flutter para el espacio docente y las actividades de estudiantes de primaria. La arquitectura y los datos actuales son la fuente funcional. El sistema se aplica mediante `lib/core/theme/` y `lib/core/widgets/`, con Fredoka incluida como recurso local para títulos, instrucciones y botones infantiles.

## Principios

1. Una tarea principal por actividad. El estímulo conserva el texto del ejercicio; la UI organiza la instrucción, la respuesta y la acción.
2. Jerarquía mediante tamaño, espacio y alineación. Las tarjetas agrupan entidades o evidencia; los resúmenes y secciones no necesitan sombras.
3. Identidad azul en el espacio docente; naranja, menta, amarillo y lila en las actividades infantiles. Un librito estático derivado del logo acompaña las instrucciones. El estímulo y el área de respuesta conservan una composición despejada.
4. La interpretación pertenece al docente. El tamizaje no constituye un diagnóstico y un puntaje no es una probabilidad de dislexia.
5. Controles explícitos, texto escalable y estados acompañados por palabras e iconos.

## Tokens y uso

- `app_colors.dart`: colores semánticos y aliases para código existente.
- `app_text_styles.dart`: estilos completos de texto.
- `app_tokens.dart`: espaciado, radios, tamaños, elevación y superficie compartida.
- `app_theme.dart`: aplicación del sistema a Material 3 como infraestructura de controles.

### Colores

| Token | Valor | Uso |
| --- | --- | --- |
| primary / info | #0056B3 | Acción principal, foco, información |
| primaryContainer | #EAF2FC | Selección y contexto azul |
| secondary | #B5470D | Acento naranja oscuro legible |
| secondaryContainer | #FFECDD | Contexto cálido |
| brandOrange | #EC5B13 | Identidad y pequeños acentos, no texto pequeño blanco |
| background | #F6F7F9 | Espacio docente |
| studentBackground | #FAF8F3 | Actividades de estudiantes |
| surface | #FFFFFF | Campos, entidades, entrada con logo opaco existente |
| surfaceVariant | #EEF1F5 | Fondos secundarios y deshabilitados |
| textPrimary | #202D3A | Texto principal |
| textSecondary | #526170 | Ayuda y contexto |
| textDisabled | #677382 | Controles deshabilitados |
| border | #8291A3 | Contornos de controles |
| divider | #DCE2EA | Separación decorativa |
| success / container | #246448 / #EAF5EE | Confirmación |
| warning / container | #845008 / #FFF3DB | Atención y seguimiento |
| error / container | #B42332 / #FFECEE | Error y acciones destructivas |

Los estados de intervención usan icono, etiqueta y explicación. Una evaluación pendiente se presenta como estado informativo. No calcular colores o niveles a partir del puntaje; utilizar `interventionLevel` recibido.

### Tipografía

Se utiliza la sans-serif nativa de Flutter, Roboto en Android, para el espacio docente y los estímulos evaluados. Fredoka, incluida localmente con licencia OFL, se utiliza en títulos, instrucciones y botones infantiles. Las capturas cargan ambas fuentes para la revisión visual. Las decisiones y fuentes académicas de la adaptación infantil están en [child_exercise_design.md](child_exercise_design.md).

| Estilo | Tamaño lógico | Interlineado | Peso |
| --- | ---: | ---: | --- |
| display | 32 | 1.25 | 700 |
| headingLarge | 28 | 1.3 | 700 |
| headingMedium | 24 | 1.3 | 700 |
| headingSmall | 20 | 1.35 | 700 |
| bodyLarge | 18 | 1.5 | normal |
| bodyMedium | 16 | 1.5 | normal |
| bodySmall | 14 | 1.5 | normal |
| labelLarge | 16 | 1.35 | 600 |
| labelMedium | 14 | 1.4 | 600 |
| studentInstruction (Fredoka) | 23 | 1.35 | 500 |
| studentTitle (Fredoka) | 22 | 1.25 | 500 |
| studentButton (Fredoka) | 20 | 1.3 | 500 |
| studentStimulus | 28 | 1.5 | 500 |

Alineación izquierda para instrucciones y lectura; evitar justificar, comprimir el texto con `FittedBox`, limitar líneas críticas o anular el escalado del sistema. Los nombres de entidad largos pueden ocupar más de una línea.

### Espacio, radios y elevación

`AppSpacing`: 4, 8, 12, 16, 24, 32, 40 y 48. Página de actividad: 24. La separación entre acciones aumenta antes de una acción destructiva.

`AppRadius`: 4 para etiquetas, 8 para controles, 12 para tarjetas, 16 para paneles y diálogos. Elevación 0 en tarjetas y 2 en el botón flotante. Las dimensiones del canvas, la captura y las restricciones de viewport son tamaños funcionales, no tokens de espaciado.

## Componentes

### Acciones

`PrimaryButton` admite variantes `primary`, `secondary`, `tertiary` y `danger`, icono opcional, `isLoading` y contexto `student`. Altura mínima docente 52; estudiante 64; crece cuando el texto lo necesita. `StudentActionButton` conserva compatibilidad con la API anterior y usa este componente. `AppActionGroup` apila acciones en anchura limitada o con texto grande.

No usar iconos aislados para grabar, guardar o continuar. Los iconos de volver, contraseña y reproducción tienen tooltip/etiqueta. Las acciones de borrar o eliminar son secundarias y mantienen las confirmaciones existentes. Los controles nativos conservan estados de foco, pulsación y deshabilitado.

### Formularios

`AppTextField` usa `TextFormField` y decoración del tema. Etiqueta persistente; ejemplo como hint; errores junto al campo y hasta cuatro líneas de ayuda/error. Se conservan controladores, validadores, tipos de teclado y reglas de consentimiento. Formularios de autenticación limitados a 520 de ancho y desplazables con teclado.

### Entidades y datos

- `StudentCard`: código, edad, estado con texto/icono y aula cuando ese contexto se conoce.
- `ClassroomCard`: nombre, grado, sección y año. La cantidad se muestra en el detalle utilizando la lista cargada; no se inventa un contador en el catálogo.
- `ExerciseCard`: icono, tipo escrito, descripción, duración real y grado.
- `MetricCard`: número y explicación compactos, sin convertir todos los datos en tarjetas cuadradas.
- `AppDetailRow`: etiqueta y valor se apilan cuando el espacio o la escala lo requiere.
- `AppAdaptiveCollection`: columnas en función del espacio y del tamaño de texto; altura intrínseca.
- `AppSectionHeader`, `AppStatusBadge`, `InfoBanner`: títulos, estados y ayuda consistentes.

### Estados y resultados

`AppLoadingState` incluye contexto. `AppEmptyState` combina título, explicación y una acción existente cuando corresponde. `ErrorMessage` añade semántica de región viva. No prometer que una respuesta se guardó cuando el estado real no lo confirma.

`AssessmentResultSummary` organiza nivel recibido, significado, puntaje, pendientes y aviso no diagnóstico. La revisión conserva audio, escritura y métricas técnicas dentro de secciones desplegables. No cambia umbrales, denominadores ni elegibilidad.

## Dos contextos de uso

**Docente:** navegación persistente, acciones frecuentes antes del resumen, listas escaneables, metadatos compactos, formularios consistentes y evidencia progresiva. Los accesos del dashboard llevan a flujos existentes con el contexto requerido.

**Estudiante:** `StudentActivityLayout` limita la anchura a 640, mantiene fondo cálido y contenido desplazable. `StudentTaskHeading` organiza progreso e instrucción. Lectura: texto grande, grabar/detener explícito, pausa y guardado. Escritura: frase y canvas con controles separados. Elección: selección con marca e información semántica. Sílabas: tocar además de arrastrar. No se agregan sonidos, rankings, premios, pistas de corrección ni animaciones que alteren la medición.

Tras finalizar se solicita entregar el dispositivo al docente. El botón «Docente: ver resultados» es una separación de presentación, no una nueva barrera de autenticación.

## Accesibilidad y verificación

Controles principales de 48–64 unidades lógicas o más, texto escalable, scroll, etiquetas persistentes, iconos acompañados, estado seleccionado en semántica y jerarquía de encabezados. Los pares semánticos de texto comprobados superan 4.5:1. Los divisores decorativos no sustituyen contornos de controles. No se afirma certificación WCAG ni validación clínica o de usabilidad con niños.

Las reglas táctiles se inspiran en el trabajo de [Anthony et al. (2019)](https://init.cise.ufl.edu/publications/physical-dimensions-of-childrens-touchscreen-interactions-lessons-from-five-years-of-study-on-the-mtagic-project/). Los tamaños 48/64 son decisiones del producto; no son un valor experimental atribuido al artículo ni una equivalencia entre unidades Flutter y CSS.

La tipografía y composición se alinean con la [guía BDA de 2023](https://cdn.bdadyslexia.org.uk/uploads/documents/Advice/style-guide/BDA-Style-Guide-2023.pdf?v=1680514568): sans-serif, espacio entre líneas y presentación clara. Se pudo consultar el extracto indexado oficial; la descarga directa devolvió 403.

La consistencia y sencillez infantil toman como referencia [Latiff, Razali e Ismail (2019)](https://www.ijrte.org/wp-content/uploads/papers/v8i3/C5434098319.pdf). [Cahyani et al. (2024)](https://online-journals.org/index.php/i-jim/article/view/47973) orienta el diseño centrado en usuarios con dificultades lectoras. La adaptación a tamizaje omite la gamificación de aprendizaje durante la evaluación medida.

[WCAG 2.2: tamaño mínimo de objetivos](https://www.w3.org/WAI/WCAG22/Understanding/target-size-minimum.html) se utiliza como referencia de accesibilidad junto con contraste, información no dependiente del color y reflujo. Hace falta una sesión de TalkBack y evaluación con docentes/estudiantes para comprobar la experiencia asistiva y la comprensión en uso real.
