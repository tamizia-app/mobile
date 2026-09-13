# Auditoría UI/UX de TamizIA

Fecha: 12 de septiembre de 2026. Auditoría previa a la implementación.

## Alcance y fuentes

Se inspeccionaron las 32 páginas de `lib/features/*/presentation/pages`, navegación de `app.dart`, widgets compartidos, tema, assets, pubspec y estados de presentación. Se aplica la skill local `.codex/skills/tamizia-ui/SKILL.md — TamizIA UI-UX.md`.

El enlace Figma no fue accesible desde la herramienta web. Se revisaron las exportaciones locales de `docs/figma`, especialmente login, dashboard y lectura. Conservan azul #0056B3, naranja y fondos claros. No se pudo confirmar que estas exportaciones correspondan exactamente a V4 Final; no se declara fidelidad a esa versión. El antiguo ui-spec describe flujos simulados y no sustituye a la implementación conectada actual.

Hay cambios previos del usuario en autenticación, dashboard, perfil, historial, modelos, tests, logo e iconos. Se preservan. El alcance es presentación: no se cambian endpoints, modelos, almacenamiento, cálculo de puntuaciones, validación de consentimiento ni procesamiento.

## A. Problemas actuales

| Categoría | Evidencia | Consecuencia / prioridad |
|---|---|---|
| Consistencia visual | Decenas de colores hex locales; estudiante mezcla naranja brillante, marrón, violeta y azul | Pantallas que parecen productos distintos. Alta |
| Typography | `AppTheme` declara Inter, sin fuentes registradas en pubspec; pesos 800/900 generalizados; textos 10–13 | Fallback implícito, jerarquía plana y lectura difícil. Alta |
| Spacing | Márgenes 18/22/26/27; separaciones 70/78 en perfil y recuperación | Pérdida de espacio útil y ritmo irregular. Media |
| Colors | Blanco sobre naranja brillante en opciones y botones; progreso pendiente en tarjeta roja | Contraste y semántica confusa. Alta |
| Hierarchy | Dashboard abre con cuatro métricas cuadradas; editar/eliminar aula antes que estudiantes; catálogo con ilustración genérica de 140 px | Acciones frecuentes desplazadas. Alta |
| Accessibility | Header usa Stack con título y acciones superpuestos; checkbox 22 px; botón reduce texto con FittedBox | Texto ampliado y targets insuficientes. Alta |
| Child UX | `formed_word`, “Subir”, “Audio temporal listo para subir”; micrófono con GestureDetector sin etiqueta de botón | Lenguaje técnico y acción ambigua. Crítica |
| Dyslexia accessibility | Estímulo centrado y ultranegrita; instrucciones centradas extensas; mayúsculas del reloj | Dificulta seguir las líneas. Alta |
| Interaction | InkWell sobre Container opaco oculta feedback; selección de palabra cambia sólo borde; dos botones primarios en resultados | Estados y prioridad poco claros. Alta |
| Responsive | Grillas con altura 126/150 o aspect ratio fijo; lectura y escritura con Column no desplazable; encabezados de altura fija | Riesgo de overflow en móvil pequeño / texto 200%. Crítica |
| Components | Campos, filas descriptivas, tarjetas y estados de error repetidos | Mantenimiento inconsistente. Alta |
| Resultados | Puntuación dominante sin significado; niveles sin icono; falta aviso no diagnóstico; abreviaturas Pron/Prec/CER | Difícil interpretación docente. Crítica |
| Loading / empty / error | Spinners aislados; estados vacíos sin siguiente paso; detalles de servidor en copy | Incertidumbre sobre qué hacer. Alta |

## B. Duplicación

- `StudentCard` y `_StudentCard` de lista global: unificar conservando contexto de aula y estado.
- `MetricCard` y `WarningMetricCard`: mismo patrón de dato; pendiente debe ser informativo.
- `_DetailRow`, `_SummaryRow`, `_InfoRow`, `_row`: compartir fila adaptable de etiqueta/valor.
- `_ErrorState`, `_TemplatesState`, `_ClassroomsErrorState`: compartir estado con título, explicación y acción existente.
- Bordes/paddings de inputs y botones: llevar al tema, preservar controladores y validadores.
- `_ScoreCard` y `_ResultCard`: compartir resumen orientativo, conservar el nivel recibido.

## C. Pantallas críticas

1. Lectura, escritura, sílabas y elección: integridad de captura, prioridad de tarea, controles grandes, sin feedback de corrección.
2. Resultados y revisión: interpretación del nivel recibido, evidencia conservada y no diagnóstico.
3. Configuración y consentimiento: bloquear exactamente según reglas existentes, no inventar disponibilidad ni guardado.
4. Dashboard, aulas y estudiantes: acceso rápido, escaneo, densidad y estados vacíos.
5. Login, registro, recuperación y perfil: campos persistentes, teclado, errores y texto ampliado.

`StudentInstructionsPage` corresponde a un flujo anterior y no está registrado en el router actual. Se conserva; la preparación activa ocurre en preview y sesión del intento. No reconectar esa ruta pasando argumentos incompatibles.

## D. Riesgos de regresión

- No tocar cronómetros, captura de audio/trazos, coordenadas, pixelRatio ni formatos de subida.
- El nivel `interventionLevel` es el valor del servidor; no inferir riesgo de un porcentaje ni introducir umbrales.
- Cambiar distribución del área de escritura puede modificar el espacio disponible: conservar el painter y su contrato, probar el gesto y revisar dispositivo real.
- Proteger retorno de rutas que transporta Student/Classroom/bool y triggers de recarga.
- No transformar ausencia de datos en cero, éxito o promesa de datos guardados.
- Respetar los cálculos y explicaciones añadidos previamente al historial.
- La validación visual con datos de prueba no verifica micrófono, backend ni consentimiento real.

## E. Propuesta: TamizIA Design System

- Conservar azul principal; naranja de marca como acento limitado y tono oscuro para texto legible.
- Fondos docentes neutros cálidos, superficie blanca; estudiante papel cálido, azul en acciones, naranja sólo contextual.
- Sans-serif nativa de Flutter (Roboto en Android), sin descargar fuentes ni agregar dependencias.
- Escala de espaciado 4/8/12/16/24/32/40/48; radios 4/8/12/16; elevación mínima.
- Tipografía semántica 14–32, cuerpo 16, instrucción 20 y estímulo 28 con interlineado 1.5.
- Botones mínimos 48/52 docente, 64 estudiante, altura flexible; icono + texto + estado explícito.
- Componentes de estado, fila de datos adaptable, badge, sección, resumen de resultado y layout infantil.
- Texto escalable sin FittedBox. Columnas por anchura disponible y escala; scroll en contenido extenso.

## F. Orden de implementación y verificación

1. Tokens, tema, tipografía y componentes base.
2. Autenticación y docente: dashboard, aulas, estudiantes, formularios, perfil y catálogos.
3. Preparación y actividades infantiles, sin modificar lógica medida.
4. Resultados, historial, estados y privacidad.
5. Ejecutar app / renders de widgets reales por grupo; revisar móvil pequeño, tablet, texto ampliado y teclado. Ejecutar analyzer y tests existentes; añadir pruebas de regresión de layout y semántica relevantes.
6. Documentar decisiones, fuentes y límites de verificación en `tamizia_design_system.md` y `ui_ux_changes.md`.
