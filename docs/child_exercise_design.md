# Interfaz infantil de ejercicios

Implementado el 13 de septiembre de 2026 en preparación, lectura, escritura, elección de palabras y formación con sílabas.

## Decisiones y fundamento

| Decisión | Referencia y alcance |
| --- | --- |
| Personaje familiar junto a la instrucción; naranja, menta, amarillo y lila; iconos con texto | [Latiff, Razali e Ismail (2019), User Interface Design Guidelines for Children Mobile Learning Applications](https://www.ijrte.org/wp-content/uploads/papers/v8i3/C5434098319.pdf). Guía obtenida mediante revisión, prototipo y evaluación experta. Orienta el diseño infantil; no demuestra la validez de una prueba de tamizaje. |
| Instrucciones grandes, separadas del estímulo, con Fredoka redondeada | La fuente concreta es una elección de diseño, no una prescripción de los artículos. [Kuster et al. (2018), Dyslexie font does not benefit reading in children with or without dyslexia](https://link.springer.com/article/10.1007/s11881-017-0154-6) no encontró una ventaja de lectura atribuible a Dyslexie. No se atribuye un efecto terapéutico a Fredoka. Palabras, sílabas y textos evaluados conservan su tipografía sencilla. |
| Personaje pequeño y estático, superficie de lectura/escritura limpia | [Fisher, Godwin y Seltman (2014), Visual Environment, Attention Allocation, and Learning in Young Children](https://www.psychologicalscience.org/journals/psychological-science/0956797614533801/) encontró mayor distracción en aulas experimentales muy decoradas. Aplicarlo a la densidad visual de una app es una inferencia de diseño; el estudio no comparó estas pantallas. |
| Diseño que debe contrastarse con niños y docentes | [Cahyani et al. (2024), User Interface Design for Dyslexia Children Learning Application using Design Thinking Approach](https://online-journals.org/index.php/i-jim/article/view/47973) reporta una evaluación SUS de 82 para su aplicación de aprendizaje. Ese resultado pertenece a su producto y no valida TamizIA. |

La mascota acompaña la instrucción y no responde a los aciertos o errores. No se incorporaron puntuaciones ficticias, pistas, sonidos ni recompensas. El tamaño mínimo del lienzo sigue siendo 480 unidades lógicas y los contactos iniciados en él pertenecen al dibujo, no al scroll. La disposición se apila con texto grande o poco ancho.

## Recursos

- `assets/fonts/fredoka/Fredoka.ttf`: fuente variable incluida localmente, disponible sin conexión. [Repositorio oficial de Google Fonts](https://github.com/google/fonts/tree/main/ofl/fredoka); licencia SIL Open Font License en `assets/fonts/fredoka/OFL.txt`.
- `assets/images/tamizia_companion.png`: adaptación del librito del logo original mediante la herramienta integrada ImageGen, sin utilizar CLI. Fondo menta para integrarlo en la tarjeta de instrucciones.
- `docs/ui_child_review/`: capturas reales de widgets Flutter con fuentes cargadas para revisión visual.

## Prompt del personaje

Primera adaptación con el logo como referencia:

> Use case: identity-preserve. Asset type: small mascot cutout for a children's Spanish literacy assessment app. Adapt ONLY the friendly turquoise book character in the provided TamizIA logo into a standalone mascot. Keep its turquoise book body, navy big eyes, coral cheeks and bookmark, little white mitten hands, and yellow open book, closely preserving identity and proportions. Remove ALL lettering and the entire wordmark beneath it. Remove the white background: actual transparent background with alpha. Center one complete isolated character filling 85% of a square image, include entire character, no extra objects or decorative particles, no text, no letters, no watermark. Polished clean soft 2D illustration, readable at 72 pixels, cheerful calm smile, no animation. Save as PNG with transparent background.

El primer resultado contenía un damero visible. Prompt final de corrección, usando ese resultado como referencia:

> Precise background edit for a Flutter children's app mascot. Keep the turquoise smiling book character, its face, bookmark, mitten hands, and yellow open book exactly as in this image. REPLACE the entire gray checkerboard with a perfectly solid flat pale mint background color RGB(227,245,241), hexadecimal #E3F5F1. The checkerboard is an error and must be fully removed including between the mittens and book and around the edges. No checks, no texture, no pattern, no gradients in the background, no shadow on the background, no added text or objects. One character centered filling 85% of a square icon, crisp clean edges. Output a PNG.

## Verificación

Pruebas de reflujo: 390×844, 320×640 con texto al 200 %, 800×1100 y 844×390. Pruebas de dibujo: puntos, trazos verticales/horizontales/diagonales, segundo dedo, cancelación y desplazamiento fuera del lienzo. Se revisan también semántica de selección y contratos de evaluación. La revisión automatizada no sustituye una sesión de uso con niños y docentes.
