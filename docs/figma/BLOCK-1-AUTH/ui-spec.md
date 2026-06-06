# TamizIA / LectorRisk - UI Spec inicial

## 1. Alcance de esta primera implementación

Implementar únicamente las pantallas iniciales de autenticación de la aplicación móvil:

1. Splash / Bienvenida
2. Inicio de sesión
3. Crear cuenta docente
4. Recuperar contraseña

No implementar dashboard, aulas, estudiantes, ejercicios, perfil, backend, Firebase, Azure ni base de datos.

---

## 2. Nombre visual de la app

En estas pantallas el diseño muestra el nombre:

**LectorRisk**

Sin embargo, en la pantalla de login también aparece el nombre:

**TamizIA**

Para evitar inconsistencias, usar por ahora el nombre que aparece en cada pantalla del Figma:

- Splash: `LectorRisk`
- Login: `TamizIA`
- Registro: `Crear cuenta docente`
- Recuperar contraseña: `Recuperar contraseña`

No cambiar textos del Figma salvo que sea necesario para validaciones.

---

## 3. Estilo general

La interfaz debe ser limpia, educativa, confiable y simple.

### Principios visuales

- Fondo claro.
- Cards blancas.
- Botones azules.
- Inputs con bordes suaves.
- Espaciado amplio.
- Diseño centrado en móvil Android.
- No agregar elementos extra que no estén en el Figma.
- Respetar la composición visual de las capturas.

---

## 4. Paleta de colores

| Nombre | Hex | Uso |
|---|---|---|
| Primary Blue | `#0056B3` | Botones principales, links, iconos activos |
| Secondary Orange | `#EC5B13` | Detalles cálidos o acentos menores |
| Neutral Dark | `#221610` | Títulos y textos principales |
| Neutral Gray | `#4B5563` | Textos secundarios |
| Background Light | `#F3F7FB` | Fondo de pantalla en login, registro y recuperar contraseña |
| Surface White | `#FFFFFF` | Cards y formularios |
| Border Gray | `#D1D5DB` | Bordes de inputs |
| Muted Text | `#6B7280` | Placeholders y textos auxiliares |
| Error Red | `#DC2626` | Mensajes de error |
| Privacy Background | `#FFF7ED` | Caja de privacidad |
| Info Blue Light | `#EFF6FF` | Círculo de icono o detalles informativos |

---

## 5. Tipografía

Usar `Inter` si está disponible. Si no, usar la fuente por defecto de Flutter.

| Estilo | Tamaño aprox. | Peso | Uso |
|---|---:|---|---|
| App Title | 24px | Bold | LectorRisk / TamizIA |
| Page Title | 18px | Bold | Crear cuenta docente, Recuperar contraseña |
| Body | 14px - 16px | Regular | Descripciones |
| Label | 12px - 14px | Medium | Labels de inputs |
| Helper | 11px - 12px | Regular | Mensajes pequeños |
| Button | 14px | Bold | Botones principales |

Reglas:
- Títulos en `Neutral Dark`.
- Descripciones en `Neutral Gray`.
- Links en `Primary Blue`.
- Errores en `Error Red`.

---

## 6. Componentes reutilizables

### PrimaryButton

Uso:
- Comenzar
- Iniciar sesión
- Registrarme
- Enviar enlace de recuperación

Estilo:
- Fondo: `#0056B3`
- Texto: blanco
- Altura: 48px
- Border radius: 8px a 10px
- Ancho completo
- Texto centrado y en negrita
- Sombra suave solo cuando el Figma lo muestre

---

### AppTextField

Uso:
- Email
- Nombres
- Apellidos
- Correo Electrónico
- Institución Educativa

Estilo:
- Fondo: blanco o `#F9FAFB`
- Borde: `#D1D5DB`
- Border radius: 8px
- Altura: 44px a 48px
- Padding horizontal: 12px
- Placeholder gris

Estados:
- Normal: borde gris
- Focus: borde azul
- Error: borde rojo

---

### PasswordField

Uso:
- Contraseña
- Confirmar Contraseña

Debe incluir:
- Icono de ojo a la derecha.
- Opción visual para mostrar/ocultar contraseña.
- Placeholder:
    - `Mínimo 8 caracteres`
    - `Repite tu contraseña`

---

### PrivacyNotice

Caja inferior de privacidad.

Estilo:
- Fondo: `#FFF7ED`
- Borde suave naranja claro
- Icono de escudo azul
- Texto pequeño en gris
- Border radius: 8px
- Padding: 12px

Texto:
`Tus datos y los de tus estudiantes son tratados de manera confidencial y se utilizan exclusivamente para fines de gestión pedagógica dentro de LectorRisk.`

---

### BackHeader

Uso:
- Registro
- Recuperar contraseña

Contenido:
- Flecha hacia atrás a la izquierda.
- Título de pantalla.

Estilo:
- Fondo transparente o blanco según pantalla.
- Altura aproximada: 56px.
- Título en `Neutral Dark`.

---

## 7. Pantalla 1: Splash / Bienvenida

### Ruta sugerida
`/splash`

### Objetivo
Presentar la app y permitir continuar al login.

### Layout
- Fondo blanco o gris muy claro.
- Contenido centrado verticalmente.
- Icono circular superior con borde naranja claro.
- Dentro del círculo, icono de libro con lupa.
- Título:
  `LectorRisk`
- Descripción:
  `Apoyo al tamizaje temprano de dificultades de lectoescritura`
- Botón principal:
  `Comenzar →`

### Comportamiento
- Al presionar `Comenzar`, navegar a `/login`.

### Restricciones
- No agregar animaciones complejas.
- No navegar automáticamente.
- No agregar onboarding adicional.

---

## 8. Pantalla 2: Inicio de sesión

### Ruta sugerida
`/login`

### Objetivo
Permitir que el docente ingrese al sistema.

### Layout
- Fondo general `Background Light`.
- Card blanca centrada.
- Icono circular superior azul claro con icono académico.
- Título:
  `TamizIA`
- Subtítulo:
  `Iniciar sesión`
- Campo:
    - Label: `Email`
    - Placeholder: `ejemplo@escuela.edu`
- Campo:
    - Label: `Contraseña`
    - Ejemplo visual: `password123`
- Mensaje de error, cuando corresponda:
  `La contraseña ingresada no es correcta. Por favor, inténtalo de nuevo.`
- Botón principal:
  `Iniciar sesión`
- Link:
  `¿Olvidaste tu contraseña?`
- Texto inferior:
  `¿No tienes cuenta? Crear cuenta docente`
- Caja inferior de privacidad:
  `Tus datos y los de tus estudiantes serán protegidos`

### Validaciones locales
- Email obligatorio.
- Email con formato válido.
- Contraseña obligatoria.
- Si los campos están vacíos, mostrar error.
- Para esta primera versión, permitir login simulado si el correo tiene formato válido y la contraseña no está vacía.

### Comportamiento
- Link `¿Olvidaste tu contraseña?` navega a `/forgot-password`.
- Link `Crear cuenta docente` navega a `/register`.
- Botón `Iniciar sesión` valida localmente.
- Si todo es válido, mostrar mensaje simulado o navegar a una pantalla dummy simple.
- No conectar backend.

---

## 9. Pantalla 3: Crear cuenta docente

### Ruta sugerida
`/register`

### Objetivo
Permitir que el docente cree una cuenta.

### Layout
- Fondo general `Background Light`.
- Card blanca con sombra suave.
- Header con flecha atrás.
- Título:
  `Crear cuenta docente`
- Texto:
  `Únete a TamizIA para gestionar la evaluación y progreso de tus estudiantes.`
- Campos:
    - `Nombres *`
        - Placeholder: `Ingresa tus nombres`
    - `Apellidos *`
        - Placeholder: `Ingresa tus apellidos`
    - `Correo Electrónico *`
        - Placeholder: `ejemplo@institucion.edu`
    - `Contraseña *`
        - Placeholder: `Mínimo 8 caracteres`
        - Icono de ojo
    - `Confirmar Contraseña *`
        - Placeholder: `Repite tu contraseña`
    - `Institución Educativa (Opcional)`
        - Placeholder: `Nombre de la escuela o colegio`
- Checkbox:
  `Acepto los Términos y Condiciones y la Política de Privacidad.`
- PrivacyNotice.
- Botón:
  `Registrarme`
- Link inferior:
  `¿Ya tienes una cuenta? Inicia sesión aquí`

### Validaciones locales
- Nombres obligatorio.
- Apellidos obligatorio.
- Correo obligatorio.
- Correo con formato válido.
- Contraseña mínimo 8 caracteres.
- Confirmar contraseña obligatorio.
- Confirmar contraseña debe coincidir.
- Debe aceptar términos y condiciones.
- Institución educativa es opcional.

### Comportamiento
- Flecha atrás vuelve a `/login`.
- Link `Inicia sesión aquí` navega a `/login`.
- Si el formulario es válido, mostrar mensaje de registro exitoso simulado y navegar a `/login` o a una pantalla dummy.
- No guardar datos reales.
- No conectar backend.

---

## 10. Pantalla 4: Recuperar contraseña

### Ruta sugerida
`/forgot-password`

### Objetivo
Permitir que el docente solicite un enlace de recuperación.

### Layout
- Fondo general `Background Light`.
- Header con flecha atrás.
- Título:
  `Recuperar contraseña`
- Imagen o ilustración de sobre.
- Subtítulo:
  `Revisa tu correo`
- Texto:
  `Si el correo electrónico coincide con una cuenta existente, recibirás un enlace seguro para restablecer tu acceso al sistema.`
- Campo:
    - Label: `Correo electrónico institucional`
    - Placeholder: `docente@escuela.edu`
- Botón:
  `Enviar enlace de recuperación`
- Link:
  `Volver al inicio de sesión`

### Validaciones locales
- Correo obligatorio.
- Correo con formato válido.

### Comportamiento
- Flecha atrás vuelve a `/login`.
- Link `Volver al inicio de sesión` navega a `/login`.
- Si el correo es válido, mostrar mensaje simulado:
  `Si el correo existe, enviaremos un enlace de recuperación.`
- No enviar correo real.
- No conectar backend.

---

## 11. Navegación requerida

Rutas mínimas:

```text
/splash
/login
/register
/forgot-password


/splash -> /login
/login -> /register
/login -> /forgot-password
/register -> /login
/forgot-password -> /login

