# Cambios UI/UX de TamizIA

## Alcance y decisiones de navegación

El rediseño mantiene los servicios, repositorios, contratos, modelos, autenticación, cronómetros y cálculos de evaluación. Se aplica sobre la arquitectura Flutter existente, siguiendo la skill local `tamizia-ui` y la auditoría previa en `ui_ux_audit.md`.

Se documentan dos ajustes de navegación de presentación antes de implementarlos: el acceso «Registrar estudiante» del dashboard enviaba al formulario sin `classroomId`, aunque ese formulario necesita un aula. El acceso ahora abre las aulas para elegir dónde registrar; el alta sigue usando el flujo existente del detalle del aula. El acceso «Resultados» no tenía destino implementado: se sustituye visualmente por «Historial de estudiantes», que abre la lista existente y permite llegar al historial desde cada detalle. No se crean endpoints ni pantallas de datos ficticios.

## Qué cambió y por qué

| Grupo / pantallas | Cambio implementado | Motivo y referencia |
| --- | --- | --- |
| Base visual | Tokens de color, tipografía, espaciado, radios y elevación; tema de inputs, botones y diálogos | Consistencia y mantenimiento; directrices infantiles de Latiff et al. |
| Splash, login, registro, recuperación, restablecimiento | Logo existente, composición contenida, controles comunes, labels persistentes, menos espacio decorativo | Identidad y lectura clara; BDA |
| Dashboard docente | Accesos frecuentes antes de métricas compactas; estado pendiente informativo; accesos a aulas e historial | Eficiencia, jerarquía y navegación predecible |
| Aulas, detalle y formularios | Tarjetas de entidad, datos de grado/sección/año, contador real en detalle, alta visible y eliminar al final | Escaneo y separación de acciones críticas |
| Estudiantes y formularios | Componente común, código/edad/estado, contexto de aula cuando existe, errores y campos uniformes | Privacidad contextual y consistencia |
| Catálogo de ejercicios y detalle | Icono más compacto, tipo escrito, duración real, descripción y acciones jerarquizadas | Comprensión sin depender del color |
| Plantillas, detalle, configuración, preview y sesión | Secciones adaptables, metadatos comunes, consentimiento conservado y procesamiento con texto | Preparación progresiva y feedback comprensible |
| Instrucciones de estudiante | Mismo lenguaje visual infantil, logo existente, instrucción breve y botón grande | Cahyani et al.; adaptación de complejidad a primaria |
| Lectura | Estímulo alineado a izquierda, instrucción de 20, estímulo de 28, grabar/detener con texto, estado y tiempo discreto | BDA, Latiff y Anthony; legibilidad y control explícito |
| Escritura | Frase legible, canvas dentro de contenido desplazable, borde visible, Borrar y Guardar separados | Alcance táctil y claridad espacial |
| Elección y sílabas | Targets amplios; selección con marca/semántica; fichas que se acomodan por filas; se conserva tocar y arrastrar | Anthony; menor exigencia de precisión táctil |
| Cierre y resultados | Confirmación para el estudiante y transición explícita al docente; nivel + icono + explicación; aviso no diagnóstico | Separación de contextos, reducción de carga y regla de producto |
| Revisión de evidencia | Métricas con nombres completos en secciones desplegables; imagen y audio conservados | Información progresiva para docente no experto |
| Historial | Conservar resumen, porcentajes y cambio relativo previos; filas adaptables y estados con etiquetas | Legibilidad con texto largo y prevención de desbordamientos |
| Perfil, privacidad y consentimiento | Inputs, acciones y superficies del sistema; términos con zona táctil completa; reglas existentes intactas | Consistencia y objetivos táctiles amplios |
| Estados vacíos, errores y carga | Componentes con explicación y siguiente paso real; sin garantías inventadas sobre persistencia | Feedback comprensible y navegación predecible |

## Trazabilidad de fuentes

- [Latiff, Razali e Ismail, 2019](https://www.ijrte.org/wp-content/uploads/papers/v8i3/C5434098319.pdf): referencia de consistencia, navegación y presentación para aplicaciones infantiles.
- [Cahyani et al., 2024](https://online-journals.org/index.php/i-jim/article/view/47973): diseño centrado en niños con dislexia; se consultó la ficha y resumen del editor. El estudio corresponde a aprendizaje: no se traslada su gamificación a una evaluación medida.
- [Anthony et al., 2019](https://init.cise.ufl.edu/publications/physical-dimensions-of-childrens-touchscreen-interactions-lessons-from-five-years-of-study-on-the-mtagic-project/): referencia para interacción táctil infantil. Los mínimos 48/64 de TamizIA son una decisión de diseño, no una reproducción de un resultado experimental específico.
- [BDA Style Guide, 2023](https://cdn.bdadyslexia.org.uk/uploads/documents/Advice/style-guide/BDA-Style-Guide-2023.pdf?v=1680514568): sans-serif, espaciado y composición legible; extracto oficial indexado consultado, descarga directa restringida.
- [WCAG 2.2, objetivos táctiles](https://www.w3.org/WAI/WCAG22/Understanding/target-size-minimum.html): referencia de accesibilidad, junto con contraste y estados que no dependan únicamente del color. No se afirma certificación.

## Integridad funcional

No se editaron servicios, repositorios, DTOs, endpoints, viewmodels, persistencia, autenticación ni fórmulas de riesgo durante este rediseño. Los cambios de dominio presentes en `student_assessment_history.dart`, los assets de logo/iconos y su configuración ya existían al comenzar; se conservaron.

El contenido de los ejercicios, el orden, las opciones y las respuestas siguen viniendo de los modelos existentes. Se mantienen cronómetros, retorno `bool` de actividades, subida de audio, painter de trazos, conversión de coordenadas, captura PNG a pixelRatio 2 y envío de tamaño del canvas. La altura visible del canvas ahora se adapta al viewport (320–560), y su contorno/placeholder usan el sistema visual: la geometría disponible y la apariencia de la imagen capturada pueden variar. Hace falta comprobar una subida real y el procesamiento OCR en un dispositivo con backend para validar ese recorrido completo.

La nueva pantalla de entrega al docente es una separación de presentación; no pretende bloquear a un estudiante mediante autenticación. No se deriva intervención a partir del porcentaje. La ausencia de puntaje se muestra como ausencia y los pendientes continúan visibles.

`StudentInstructionsPage` sigue siendo código de un flujo anterior sin ruta activa registrada. Se armonizó su presentación sin reconectarlo al flujo actual ni convertir sus argumentos; la preparación activa ocurre en preview/sesión.

## Revisión visual y límites

La revisión automatizada monta 32 pantallas reales con repositorios de prueba en 390×844, 320×640 con texto 200 %, 800×1100 y 844×390. Se recorre el contenido desplazable, se verifica login con teclado abierto, semántica de selección, dibujo de un trazo, resultados pendientes sin puntaje y navegación de los accesos docentes. Se revisaron capturas de entrada, dashboard, formularios, catálogos, actividades, resultados, preview e historial. Los datos de las capturas son ficticios.

Las capturas se generan con `TAMIZIA_CAPTURE_UI=1 flutter test --no-pub test/ui/redesign_test.dart` en PowerShell, configurando la variable de entorno antes del comando. Están en `docs/ui_review/`. No son golden tests: sirven para inspección, y los tests comprueban excepciones de layout y comportamiento.

Se compiló e instaló el APK debug en Pixel 9 / Android API 37. Se verificó el proceso activo y se inspeccionaron capturas reales de splash y login mediante ADB. El primer `flutter run` perdió la conexión de depuración tras instalar; eso no impidió que la app abriera. Las capturas `android_*` corresponden al emulador; las demás, a widgets con datos de prueba.

El enlace remoto de Figma no pudo consultarse. Se inspeccionaron los exports locales de `docs/figma/`; no se afirma que estén identificados de forma verificable como V4 Final. Se priorizaron los flujos funcionales Flutter y la identidad existente, conforme al encargo.

No se realizó una evaluación con niños/docentes, una sesión completa con TalkBack, ni un recorrido autenticado contra el backend con grabación y procesamiento real. Las pruebas de contratos y presentación no sustituyen esas comprobaciones de integración y usabilidad.

## Validación final

- `flutter analyze --no-pub`: sin incidencias.
- `flutter test --no-pub --reporter expanded`: **80 pruebas aprobadas**, incluyendo las pruebas existentes de autenticación, formularios, consentimiento, contratos y resumen de historial.
- 32 pantallas × 4 configuraciones: sin excepciones de layout en los escenarios comprobados.
- `git diff --check`: sin errores de whitespace.
- Se corrigieron dos desbordamientos detectados durante la revisión: encabezado/acción de estudiantes en aula y metadatos largos del historial.
- Se conservaron los archivos y cambios que ya estaban presentes al iniciar el encargo.

El APK final también se generó con `flutter build apk --debug --no-pub` y se instaló correctamente mediante `adb install -r`, conservando los datos del emulador. Archivo: `build/app/outputs/flutter-apk/app-debug.apk`.

### Capturas de referencia

- [Dashboard](ui_review/dashboard.png)
- [Lectura](ui_review/reading.png)
- [Escritura](ui_review/writing.png)
- [Sílabas](ui_review/syllables.png)
- [Resultados](ui_review/result.png)
- [Inicio de sesión en Android](ui_review/android_login.png)
