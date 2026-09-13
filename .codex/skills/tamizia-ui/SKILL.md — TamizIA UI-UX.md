---
name: tamizia-ui
description: >
  Reglas de diseño, implementación y revisión UI/UX para TamizIA.
  Usar esta skill al crear, modificar, refactorizar o revisar cualquier
  pantalla, componente visual, flujo de interacción, tema, estilo,
  accesibilidad o experiencia de usuario de la aplicación Flutter.
---

# TamizIA UI/UX Skill

## 1. Purpose

Esta skill define las reglas obligatorias de diseño UI/UX de **TamizIA**, una aplicación móvil orientada al apoyo en la identificación temprana de indicadores de riesgo de dislexia mediante actividades digitales de lectura y escritura en estudiantes de educación primaria.

La aplicación tiene dos contextos de usuario diferentes:

1. **Docente**
   - Necesita eficiencia.
   - Claridad.
   - Confianza.
   - Visualización rápida de información.
   - Flujos profesionales.

2. **Estudiante de primaria**
   - Necesita instrucciones simples.
   - Baja carga cognitiva.
   - Alta legibilidad.
   - Interacciones táctiles sencillas.
   - Feedback claro.
   - Interfaz amigable sin distracciones excesivas.

Nunca tratar ambas experiencias como si fueran exactamente el mismo usuario.

---

# 2. When to use this skill

Aplicar esta skill siempre que la tarea involucre:

- UI.
- UX.
- Flutter widgets visuales.
- Screens.
- Pages.
- Views.
- Components.
- Theme.
- Colors.
- Typography.
- Buttons.
- Forms.
- Cards.
- Navigation.
- Modals.
- Dialogs.
- Empty states.
- Loading states.
- Error states.
- Student activities.
- Teacher dashboard.
- Results.
- Accessibility.
- Responsive design.
- Design system.
- Figma.
- Visual refactoring.

También utilizarla si el usuario pide:

- "mejora esta pantalla"
- "hazlo más bonito"
- "moderniza el diseño"
- "que no parezca generado por IA"
- "adáptalo a niños"
- "hazlo más profesional"
- "hazlo igual al Figma"
- "mejora la UX"

---

# 3. Product context

TamizIA NO diagnostica dislexia.

Es una herramienta de apoyo para tamizaje temprano.

Funciones principales:

- autenticación docente;
- perfil docente;
- gestión de aulas;
- gestión de estudiantes;
- catálogo de ejercicios;
- configuración de evaluaciones;
- sesiones de evaluación;
- lectura en voz alta;
- escritura digital;
- captura de audio;
- captura de trazos;
- procesamiento de evidencias;
- resultados;
- indicadores;
- historial;
- consentimiento;
- privacidad.

No introducir lenguaje que haga parecer que el sistema proporciona un diagnóstico clínico.

Preferir:

> Riesgo orientativo

> Indicadores observados

> Se recomienda seguimiento

Evitar:

> El estudiante tiene dislexia

> Diagnóstico positivo

> Dislexia detectada

---

# 4. Sources of truth

Usar este orden:

1. Código Flutter actual → fuente de verdad funcional.
2. Figma V4 Final → referencia visual.
3. TamizIA Design System → fuente de verdad visual.
4. Esta skill → reglas generales.

Figma:

https://www.figma.com/design/g2eiw5xbrowss8Q0fcz0Em/TAMIZIA?node-id=0-1&t=SR251r6WZjrHOkeL-1

La versión **V4 Final** es la referencia visual más cercana al producto real.

No copiar Figma ciegamente.

Si Figma y código difieren:

- conservar funcionalidad existente;
- respetar navegación real;
- mantener integraciones;
- adaptar visualmente el flujo real.

Nunca eliminar funcionalidad solamente para hacer que una pantalla coincida con Figma.

---

# 5. Design foundation

El diseño de TamizIA se fundamenta principalmente en:

## Child-Computer Interaction

Referencia principal:

Latiff, H. S. A., Razali, R., & Ismail, F. F. (2019).  
*User Interface Design Guidelines for Children Mobile Learning Applications.*

Aplicar:

- navegación sencilla;
- interacción predecible;
- lenguaje acorde con la edad;
- elementos táctiles grandes;
- instrucciones breves;
- iconografía comprensible;
- feedback inmediato;
- consistencia;
- contenido visual entendible.

---

## UI para niños con dislexia

Referencia principal:

Cahyani, D. E., Wahyuningsih, S., Rahmadani, D., Khotimah, K., & Atan, N. A. (2024).  
*User Interface Design for Dyslexia Children Learning Application using Design Thinking Approach.*

Aplicar:

- diseño simple;
- baja carga cognitiva;
- información progresiva;
- tipografía legible;
- apoyo visual;
- instrucciones claras;
- feedback positivo;
- elementos multisensoriales solamente cuando aporten valor.

---

## Touch interaction for children

Referencia:

Anthony, L. (2019).  
*Physical Dimensions of Children's Touchscreen Interactions.*

Considerar que los estudiantes tienen menor precisión táctil que usuarios adultos.

Por ello:

- targets táctiles amplios;
- suficiente espacio entre acciones;
- evitar controles pequeños;
- minimizar gestos complejos;
- preferir acciones explícitas.

---

## Dyslexia-friendly content

Tomar como referencia la **British Dyslexia Association Dyslexia Style Guide**.

Aplicar:

- fuentes sans-serif;
- tamaño cómodo;
- espaciado suficiente;
- párrafos breves;
- alineación izquierda;
- evitar texto justificado;
- evitar cursivas largas;
- evitar mayúsculas sostenidas;
- evitar subrayados innecesarios;
- evitar fondos visualmente ruidosos;
- utilizar buen contraste.

---

## Accessibility

Aplicar principios compatibles con WCAG 2.2:

- contraste suficiente;
- controles táctiles accesibles;
- semántica;
- escalabilidad de texto;
- jerarquía clara;
- no transmitir información exclusivamente mediante color;
- labels comprensibles.

---

# 6. Design personality

TamizIA debe sentirse:

- educativa;
- moderna;
- amigable;
- cálida;
- limpia;
- segura;
- profesional;
- accesible;
- coherente.

Para estudiantes:

- divertida de manera moderada;
- cercana;
- fácil de entender.

Para docentes:

- profesional;
- ordenada;
- eficiente.

NO convertir TamizIA en:

- un videojuego;
- una copia de Duolingo;
- una app para niños de preescolar;
- una app llena de colores;
- un dashboard corporativo frío;
- una colección de cards sin jerarquía;
- una interfaz típica generada automáticamente por IA.

---

# 7. Avoid "AI-generated UI"

Evitar especialmente patrones visuales genéricos como:

- todo dentro de cards;
- border radius 24-32 en absolutamente todo;
- gradientes por todas partes;
- sombras excesivas;
- glassmorphism;
- blobs decorativos innecesarios;
- iconos aleatorios;
- exceso de emojis;
- demasiados colores;
- todos los componentes centrados;
- textos genéricos;
- pantallas visualmente aisladas entre sí.

Cada decisión visual debe tener una razón:

- jerarquía;
- accesibilidad;
- legibilidad;
- comprensión;
- facilidad táctil;
- consistencia;
- eficiencia.

---

# 8. TamizIA Design System

No hardcodear estilos repetidamente.

Centralizar:

- colors;
- typography;
- spacing;
- radius;
- shadows/elevation;
- iconography;
- component variants;
- semantic states.

Preferir una estructura similar a:

```text
lib/
  core/
    theme/
      tamizia_colors.dart
      tamizia_typography.dart
      tamizia_spacing.dart
      tamizia_radius.dart
      tamizia_theme.dart
```

Adaptar nombres y ubicación a la arquitectura real del proyecto.

No crear una segunda arquitectura paralela si ya existe un sistema equivalente.

---

# 9. Color rules

Primero inspeccionar la identidad existente.

No reemplazar arbitrariamente toda la paleta.

Definir colores semánticos equivalentes a:

```text
primary
primaryContainer

secondary
secondaryContainer

background

surface
surfaceVariant

textPrimary
textSecondary
textDisabled

border
divider

success
warning
error
info
```

## Teacher UI

Preferir superficies limpias y tonos más neutrales.

## Student UI

Permitir acentos más vivos sin generar ruido visual.

## Critical rule

Nunca comunicar un estado solamente mediante color.

Incorrecto:

```text
🟢
🟡
🔴
```

Correcto:

```text
✓ Riesgo orientativo bajo
! Riesgo orientativo moderado
! Requiere seguimiento
```

Color + icono + texto.

---

# 10. Typography

Priorizar sans-serif altamente legible.

Fuentes aceptables dependiendo de lo que ya exista en el proyecto:

- Atkinson Hyperlegible;
- Open Sans;
- Lexend;
- Nunito Sans;
- Roboto;
- equivalente legible.

No agregar una nueva dependencia tipográfica sin necesidad.

Crear jerarquía tipográfica reutilizable:

```text
display

headingLarge
headingMedium
headingSmall

bodyLarge
bodyMedium
bodySmall

labelLarge
labelMedium
labelSmall
```

Para estudiantes:

- utilizar tamaños ligeramente superiores;
- interlineado cómodo;
- frases breves;
- evitar párrafos largos.

No utilizar tipografías decorativas para instrucciones o contenido evaluado.

---

# 11. Spacing

Usar spacing sistemático.

Preferencia:

```text
4
8
12
16
24
32
40
48
```

No utilizar constantemente valores arbitrarios.

Ejemplos a cuestionar:

```text
13
17
19
23
27
```

Mantener suficiente espacio entre:

- secciones;
- botones;
- textos;
- campos;
- controles táctiles.

Whitespace forma parte de la jerarquía.

---

# 12. Radius

Usar radius según jerarquía.

Ejemplo conceptual:

```text
small
medium
large
```

No utilizar el mismo radius enorme para:

- inputs;
- cards;
- botones;
- dialogs;
- badges;
- containers.

Evitar el aspecto "bubble UI" genérico.

---

# 13. Buttons

Mantener variantes claras:

```text
Primary
Secondary
Tertiary
Danger
Icon
```

Los botones principales deben:

- ser fáciles de identificar;
- tener buen target táctil;
- tener texto claro;
- mostrar estados loading/disabled/pressed.

Para estudiantes evitar botones solo con icono cuando la acción no sea obvia.

Preferir:

```text
Continuar →
```

sobre:

```text
→
```

---

# 14. Touch targets

Especialmente en student UI:

- utilizar zonas táctiles generosas;
- separar botones conflictivos;
- evitar targets diminutos;
- evitar acciones críticas en zonas muy próximas.

No sacrificar facilidad de interacción para hacer una pantalla visualmente más compacta.

---

# 15. Icons

Utilizar una familia consistente.

No mezclar sin razón:

- Material;
- Cupertino;
- emojis;
- SVGs de estilos incompatibles;
- outline y filled arbitrariamente.

Los iconos complementan el texto.

No deben sustituir contenido crítico.

---

# 16. Cards

No usar cards automáticamente.

Usarlas para:

- representar entidades;
- agrupar información relacionada;
- seleccionar opciones;
- mostrar resúmenes.

Antes de crear una card considerar si bastaría con:

- spacing;
- divider;
- typography;
- background;
- section header.

Evitar dashboard lleno de rectángulos blancos flotantes.

---

# 17. Shadows

Mantener elevación discreta.

Evitar:

- sombras oscuras;
- grandes blur;
- glow;
- neumorphism.

Priorizar jerarquía mediante:

- spacing;
- size;
- typography;
- contrast.

---

# 18. Student UX rules

Las pantallas utilizadas directamente por niños son críticas.

## One primary task

Cada pantalla de evaluación debe tener UNA tarea principal.

Ejemplo:

```text
Lee esta oración en voz alta

El perro corre por el parque.

[Comenzar]
```

No agregar información administrativa.

---

## Instructions

Utilizar instrucciones cortas.

Preferir:

> Lee la oración en voz alta.

Evitar:

> A continuación deberás proceder a realizar la lectura correspondiente al texto presentado...

---

## Progress

Se puede mostrar contexto:

> Actividad 2 de 5

No utilizar rankings ni presión competitiva.

---

## During assessment

Reducir distracciones.

Durante lectura/escritura evitar:

- monedas;
- XP;
- confetti;
- animaciones continuas;
- sonidos decorativos;
- rankings;
- recompensas que alteren el comportamiento.

TamizIA está midiendo desempeño.

La interfaz no debe contaminar innecesariamente la medición.

---

## After task

Feedback breve y positivo:

> ¡Listo! Guardamos tu respuesta.

No mostrar al estudiante:

- WER;
- CER;
- pronunciation score;
- accuracy técnica;
- riesgo;
- indicadores clínicos.

---

# 19. Teacher UX rules

El docente necesita eficiencia.

Priorizar:

- scanability;
- búsqueda rápida;
- claridad;
- acciones frecuentes;
- información contextual.

Evitar interfaces excesivamente infantiles en módulos administrativos.

---

# 20. Dashboard

No utilizar cards gigantes para cada dato.

Priorizar:

1. contexto;
2. acciones frecuentes;
3. aulas;
4. evaluaciones recientes;
5. información útil.

Evitar métricas decorativas que no aporten decisiones.

---

# 21. Classroom UI

Un aula debería poder reconocerse rápidamente.

Mostrar solamente información útil, como:

- grado;
- sección;
- estudiantes;
- año cuando corresponda.

La acción principal debe ser entrar al aula.

Edición/eliminación deben ser secundarias.

---

# 22. Students UI

Permitir escaneo rápido.

Priorizar:

- seudónimo/código;
- edad/grado si corresponde;
- estado relevante;
- último resultado si aporta valor.

No mostrar datos personales innecesarios.

Respetar la seudonimización del producto.

---

# 23. Exercise catalog

Distinguir claramente:

- lectura;
- escritura;
- combinado.

Cada ejercicio debe incluir como mínimo:

- nombre;
- tipo;
- explicación breve;
- acción.

No depender solamente del color para distinguirlos.

---

# 24. Assessment setup

Antes de comenzar debe quedar claro:

- estudiante;
- actividad;
- qué va a ocurrir;
- preparación requerida.

Evitar formularios innecesarios.

---

# 25. Reading activity

La lectura debe dominar visualmente la pantalla.

Priorizar:

1. instrucción;
2. texto a leer;
3. estado de grabación;
4. acción principal.

Eliminar elementos irrelevantes.

El texto estímulo debe ser altamente legible.

---

# 26. Writing activity

El área de escritura debe tener prioridad.

Evitar:

- toolbars enormes;
- demasiados botones;
- elementos alrededor del canvas.

Las acciones críticas deben ser claras:

- comenzar;
- borrar cuando esté permitido;
- terminar.

No introducir herramientas que cambien la naturaleza del ejercicio sin requerimiento funcional.

---

# 27. Results

Esta pantalla es crítica.

Mostrar progresivamente:

## 1. Resultado general

Ejemplo:

> Riesgo orientativo moderado

## 2. Interpretación

> Se observaron algunos indicadores que podrían requerir seguimiento.

## 3. Indicadores principales

Presentar primero indicadores comprensibles.

## 4. Datos técnicos

Detalles secundarios.

## 5. Recomendación

Próximo paso sugerido.

## 6. Disclaimer

Siempre dejar claro:

> Este resultado es orientativo y no constituye un diagnóstico clínico.

No utilizar lenguaje alarmista.

---

# 28. Forms

Los campos deben incluir:

- label persistente;
- hint/example si ayuda;
- error cercano al campo;
- estados disabled;
- keyboard correcto;
- validación clara.

No utilizar placeholder como único label.

---

# 29. Empty states

No dejar áreas vacías sin explicación.

Estructura:

```text
Título
Descripción breve
Acción
Ilustración opcional
```

Ejemplo:

```text
Aún no hay estudiantes

Registra al primer estudiante para comenzar.

[Agregar estudiante]
```

---

# 30. Loading states

No utilizar siempre un spinner central aislado.

Elegir según contexto:

- button loading;
- progress indicator;
- skeleton;
- status text.

Procesamiento largo:

> Estamos procesando la evaluación…

---

# 31. Error states

Un buen error responde:

1. ¿Qué ocurrió?
2. ¿Qué puedo hacer?

Ejemplo:

> No pudimos cargar los resultados.

> Revisa tu conexión e inténtalo nuevamente.

No mostrar directamente:

> HTTP 500

Nunca prometer que datos están guardados si la implementación no lo garantiza.

---

# 32. Feedback

Cada acción importante debe producir feedback visible.

Ejemplos:

- guardado;
- creación;
- eliminación;
- grabación iniciada;
- evaluación terminada;
- error;
- procesamiento.

Evitar feedback ambiguo.

---

# 33. Motion

Utilizar animación únicamente si mejora comprensión.

Adecuado:

- cambio de estado;
- progreso;
- aparición;
- expansión;
- confirmación.

Evitar:

- animaciones permanentes;
- bouncing decorativo;
- backgrounds animados;
- transiciones lentas.

No alterar tiempos de una evaluación.

---

# 34. Responsive Flutter

Nunca asumir un único dispositivo.

Revisar:

- teléfonos pequeños;
- teléfonos grandes;
- tablets si están soportadas;
- teclado abierto;
- text scaling;
- textos largos.

Evitar:

```dart
width: 390
height: 844
```

como estructura principal de layout.

Preferir:

- LayoutBuilder;
- MediaQuery cuando sea apropiado;
- Expanded;
- Flexible;
- constraints;
- responsive padding.

No sobreusar MediaQuery para absolutamente todo.

---

# 35. Accessibility in Flutter

Cuando corresponda revisar:

```dart
Semantics
Tooltip
MediaQuery.textScaler
Focus
SafeArea
```

No ocultar información importante a tecnologías de asistencia.

Mantener orden lógico de lectura.

---

# 36. Reusable components

Si un patrón aparece varias veces, considerar componente.

Ejemplos conceptuales:

```text
TamiziaButton
TamiziaTextField
TamiziaStatusBadge
TamiziaEmptyState
TamiziaSectionHeader
TamiziaClassroomCard
TamiziaStudentTile
TamiziaExerciseCard
TamiziaMetricCard
TamiziaResultSummary
```

No crear componentes artificialmente pequeños sin beneficio.

Evitar:

```text
TamiziaSizedBox16
TamiziaWhiteContainer
TamiziaRow
```

El componente debe expresar intención de producto.

---

# 37. Preserve architecture

UI refactoring NO justifica reescribir arquitectura.

Mantener cuando sea razonable:

- providers;
- blocs;
- controllers;
- repositories;
- services;
- API clients;
- routes;
- state management.

No mover lógica de negocio a widgets.

---

# 38. Never break functional contracts

No modificar por razones visuales:

- endpoints;
- request models;
- response models;
- DB schemas;
- authentication;
- AI processing;
- OCR;
- Speech services;
- risk calculation.

Si una modificación funcional resulta inevitable:

documentarla explícitamente.

---

# 39. Workflow before editing a screen

Antes de modificar una pantalla:

1. Leer implementación actual completa.
2. Identificar estado y lógica.
3. Identificar componentes compartidos.
4. Revisar si existe equivalente en Figma V4.
5. Identificar usuario:
   - teacher;
   - student.
6. Determinar objetivo principal.
7. Detectar problemas visuales.
8. Reutilizar design tokens.
9. Implementar.
10. Ejecutar formatter/analyzer/tests correspondientes.
11. Revisar visualmente si el entorno lo permite.

---

# 40. Visual review checklist

Antes de considerar una pantalla terminada comprobar:

- [ ] Existe una acción principal evidente.
- [ ] La jerarquía visual es clara.
- [ ] Typography proviene del design system.
- [ ] Colors provienen del design system.
- [ ] Spacing es consistente.
- [ ] No existen tamaños hardcodeados innecesarios.
- [ ] No hay overflow.
- [ ] Los botones tienen target suficiente.
- [ ] Estados disabled son claros.
- [ ] Loading está contemplado.
- [ ] Error está contemplado.
- [ ] Empty state está contemplado si aplica.
- [ ] El contraste es adecuado.
- [ ] La pantalla no depende solo del color.
- [ ] Iconografía es consistente.
- [ ] La pantalla se siente parte de TamizIA.
- [ ] No parece una plantilla AI genérica.

---

# 41. Student screen checklist

Además comprobar:

- [ ] Una tarea principal.
- [ ] Instrucción breve.
- [ ] Texto legible.
- [ ] Controles grandes.
- [ ] Pocas decisiones.
- [ ] Pocos elementos simultáneos.
- [ ] Sin métricas técnicas.
- [ ] Sin lenguaje clínico.
- [ ] Sin distracciones durante medición.
- [ ] Feedback positivo.
- [ ] Flujo predecible.

---

# 42. Teacher screen checklist

Además comprobar:

- [ ] Información escaneable.
- [ ] Acciones frecuentes visibles.
- [ ] Información secundaria no compite.
- [ ] No existe apariencia excesivamente infantil.
- [ ] Resultados son interpretables.
- [ ] Datos sensibles son mínimos.
- [ ] Los niveles orientativos están explicados.

---

# 43. Code quality

Después de cambios relevantes ejecutar cuando sea posible:

```bash
dart format .
flutter analyze
flutter test
```

Si todo el test suite es demasiado amplio, ejecutar tests relacionados primero.

No introducir nuevos analyzer errors.

---

# 44. Documentation

Si se modifica significativamente el sistema visual, actualizar:

```text
docs/tamizia_design_system.md
```

Registrar decisiones importantes como:

- nuevo token;
- nuevo componente;
- cambio de tipografía;
- cambio de semántica de color;
- patrón nuevo;
- modificación importante de interacción.

---

# 45. Academic traceability

Cuando sea relevante documentar el motivo de una decisión mediante alguna de estas categorías:

```text
CCI
Dyslexia accessibility
Touch accessibility
WCAG
Cognitive load
Consistency
Teacher efficiency
Assessment integrity
```

Ejemplo:

```text
Decision:
Increase the primary action touch target.

Reason:
Touch accessibility / Child-Computer Interaction.

Reference:
Anthony (2019).
```

No es necesario llenar el código de comentarios académicos.

Las referencias pertenecen principalmente a documentación de diseño.

---

# 46. Figma rule

Figma es referencia, no especificación funcional absoluta.

Al implementar una pantalla desde Figma:

1. identificar intención;
2. identificar componentes;
3. comparar con código real;
4. conservar comportamiento;
5. aplicar design system;
6. adaptar responsive;
7. corregir problemas de accesibilidad.

Nunca implementar coordenadas absolutas provenientes de Figma como layout Flutter.

---

# 47. Do not invent assets

Antes de crear:

- iconos;
- ilustraciones;
- mascotas;
- imágenes;
- logos;

revisar assets existentes.

No reemplazar identidad gráfica sin necesidad.

Si falta un asset:

usar temporalmente un elemento coherente con el sistema existente y documentar la necesidad.

---

# 48. Assessment integrity

TamizIA mide comportamiento durante actividades.

La interfaz no debe modificar innecesariamente dicho comportamiento.

Durante evaluación evitar:

- presión temporal visual no requerida;
- cuenta regresiva si no forma parte de la prueba;
- recompensas durante ejecución;
- estímulos adicionales;
- pistas;
- correcciones automáticas visibles;
- animaciones distractoras.

Esta regla tiene prioridad sobre hacer la interfaz "más divertida".

---

# 49. Tone of voice

Texto dirigido a estudiantes:

- corto;
- positivo;
- claro;
- directo.

Ejemplo:

> Lee esta oración en voz alta.

> Cuando estés listo, toca “Comenzar”.

Texto dirigido a docentes:

- profesional;
- simple;
- informativo.

Ejemplo:

> La evaluación se procesó correctamente.

Evitar lenguaje robótico:

> El procedimiento ha sido ejecutado satisfactoriamente.

---

# 50. Definition of done

Una modificación UI/UX se considera terminada solamente cuando:

- mantiene la funcionalidad;
- utiliza el design system;
- mantiene consistencia;
- es responsive;
- contempla accesibilidad;
- no introduce overflow;
- contempla estados principales;
- distingue teacher/student UX;
- mantiene lenguaje no diagnóstico;
- supera analyzer/tests relevantes;
- visualmente pertenece al mismo producto.

---

# 51. Priority rule

Cuando existan conflictos entre decisiones, utilizar este orden:

1. Integridad de la evaluación.
2. Funcionalidad.
3. Accesibilidad.
4. Comprensión del usuario.
5. Consistencia.
6. Eficiencia.
7. Estética.

Nunca sacrificar los primeros puntos únicamente para hacer una pantalla más llamativa.

---

# 52. Final principle

TamizIA no debe diseñarse para demostrar cuánto diseño puede agregarse.

Debe diseñarse para que:

**un niño entienda qué hacer sin esfuerzo y un docente entienda qué ocurrió sin ser experto en inteligencia artificial.**

Toda decisión de UI/UX debe apoyar ese objetivo.