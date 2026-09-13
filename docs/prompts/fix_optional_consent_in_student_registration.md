Corrige el flujo de registro de estudiante para incluir la carga de consentimiento en la UI, pero sin volverla obligatoria para crear al estudiante.

Problema actual:

* La pantalla `Registrar estudiante` no muestra ninguna sección para consentimiento.
* El backend sí tiene endpoint para subir consentimiento:
  `POST /api/v1/students/{student_id}/consent/upload`
* Actualmente se puede registrar un estudiante sin siquiera visualizar la opción de consentimiento.
* Esto deja incompleto el flujo de negocio y la experiencia del docente.

Objetivo:
Modificar la pantalla y la lógica de registro de estudiante para que el consentimiento aparezca claramente dentro del flujo de alta del estudiante, pero sin hacerlo obligatorio.

Mantener:

* MVVM
* arquitectura por capas
* backend real
* interceptor auth existente
* diseño visual general
* navegación actual
* módulo de aulas ya integrado

No inventar endpoints.
No modificar backend.
No romper el CRUD actual de estudiantes.

## Backend disponible

### Crear estudiante

`POST /api/v1/classrooms/{classroom_id}/students`

Request:

```json id="jlwm59"
{
  "code": "string",
  "age": 4,
  "gender": "BOY"
}
```

Response:

```json id="3s840k"
{
  "student_id": "uuid",
  "classroom_id": "uuid",
  "code": "string",
  "age": 0,
  "gender": "string",
  "is_active": true,
  "created_at": "2026-06-29T00:27:52.892Z",
  "updated_at": "2026-06-29T00:27:52.892Z"
}
```

### Upload consentimiento

`POST /api/v1/students/{student_id}/consent/upload`

Content-Type:
`multipart/form-data`

Field requerido:

* `file`

Response:

```json id="1g3n48"
{
  "consent_id": "uuid",
  "student_id": "uuid",
  "status": true,
  "consent_date": "2026-06-29T00:34:17.962Z",
  "revoked_at": "2026-06-29T00:34:17.962Z",
  "evidence_blob_path": "string",
  "created_at": "2026-06-29T00:34:17.962Z",
  "updated_at": "2026-06-29T00:34:17.962Z"
}
```

## Nueva regla de negocio

El consentimiento NO debe ser obligatorio para registrar al estudiante.

Pero sí debe cumplirse esto:

* la pantalla `Registrar estudiante` debe mostrar una sección visible de consentimiento
* el docente debe poder seleccionar un archivo desde esa misma pantalla
* si el docente adjunta archivo, al guardar se debe subir automáticamente después de crear el estudiante
* si no adjunta archivo, el estudiante se crea igual
* el detalle del estudiante debe reflejar que el consentimiento está:

    * cargado
    * o pendiente

## Flujo esperado

### Caso A: registrar estudiante sin consentimiento

1. Docente completa:

    * código
    * edad
    * género
2. No selecciona archivo
3. Presiona registrar
4. Se crea el estudiante
5. Se navega correctamente
6. El detalle del estudiante muestra consentimiento pendiente

### Caso B: registrar estudiante con consentimiento

1. Docente completa:

    * código
    * edad
    * género
2. Selecciona archivo de consentimiento
3. Presiona registrar
4. Se crea el estudiante
5. Con el `student_id` retornado, se sube el consentimiento
6. Si todo sale bien:

    * mostrar éxito completo
    * detalle del estudiante debe mostrar consentimiento cargado

### Caso C: estudiante creado pero upload falla

1. Se crea estudiante correctamente
2. Falla upload del consentimiento
3. No se pierde el estudiante
4. Mostrar mensaje claro:
   `El estudiante fue registrado, pero no se pudo subir el consentimiento. Puedes intentarlo nuevamente desde el detalle del estudiante.`
5. El detalle del estudiante debe mostrar consentimiento pendiente

## Cambios en UI de Registrar estudiante

Agregar en la pantalla `Registrar estudiante` una sección nueva debajo de los campos del estudiante.

Sección:

* Título: `Consentimiento`
* Texto de apoyo:
  `Puedes adjuntar ahora el documento de consentimiento o hacerlo más adelante desde el detalle del estudiante.`
* Card o fila visual con estado del archivo
* Botón:

    * `Seleccionar archivo`
* Si ya se seleccionó archivo:

    * mostrar nombre del archivo
    * tamaño si es posible
    * opción de quitar/reemplazar archivo
* Si no hay archivo:

    * mostrar estado visual:
      `Sin consentimiento adjunto`

La sección debe ser visible siempre, aunque no sea obligatoria.

No romper el diseño general del Figma. Integrarla visualmente de forma consistente.

## Validación

El consentimiento NO debe bloquear la creación del estudiante.

Validaciones obligatorias:

* code obligatorio
* age obligatorio
* gender obligatorio

El archivo de consentimiento:

* opcional
* si existe, debe ser un archivo válido
* si no existe, no debe impedir guardar

## Selección de archivo

Implementar selección de archivo usando la solución más estable ya usada o permitida en el proyecto, por ejemplo `file_picker`.

Requisitos:

* permitir seleccionar PDF o imagen si backend lo soporta
* guardar temporalmente el archivo en estado local
* no subir el archivo inmediatamente al seleccionarlo
* solo subirlo después de crear el estudiante y solo si existe
* permitir reemplazarlo
* permitir quitarlo antes de guardar

Si la documentación no aclara tipos aceptados:

* aceptar al menos `pdf`, `jpg`, `jpeg`, `png`

## Arquitectura requerida

Mantener flujo:

Page
-> ViewModel
-> StudentRepository
-> StudentRemoteDataSource
-> ApiClient

Para consentimiento:
Page
-> ViewModel
-> StudentRepository.uploadConsent(studentId, file)
-> StudentRemoteDataSource
-> multipart/form-data

No hacer upload desde la página directamente.
No hacer HTTP desde el ViewModel.

## ViewModel de registro

Extender `StudentFormViewModel` o el ViewModel actual.

Agregar estado:

* `selectedConsentFile`
* `isUploadingConsent`
* `isSubmitting`
* `fieldErrors`
* `generalError`

Métodos sugeridos:

* `pickConsentFile()`
* `removeConsentFile()`
* `createStudentWithOptionalConsent(String classroomId)`

Flujo de `createStudentWithOptionalConsent`:

1. validar campos obligatorios
2. activar loading
3. crear estudiante
4. si la creación falla, terminar
5. si existe archivo seleccionado:

    * subir consentimiento usando `student.studentId`
6. si no existe archivo:

    * finalizar como éxito simple
7. si upload falla:

    * retornar éxito parcial
8. desactivar loading

## Repository

Asegurar que `StudentRepository` tenga:

```dart id="rxtemm"
Future<Student> createStudent(
  String classroomId,
  CreateStudentRequest request,
);

Future<StudentConsent> uploadConsent(
  String studentId,
  File file,
);
```

El upload debe usar `multipart/form-data` real con el campo exacto:

* `file`

## Comportamiento al guardar

### Caso sin consentimiento

Mensaje:
`Estudiante registrado correctamente.`

### Caso con consentimiento exitoso

Mensaje:
`Estudiante registrado correctamente con consentimiento adjunto.`

### Caso con consentimiento fallido

Mensaje:
`El estudiante fue registrado, pero no se pudo subir el consentimiento. Puedes intentarlo nuevamente desde el detalle del estudiante.`

En ese caso:

* navegar igual
* mostrar estado pendiente en detalle

## Detalle del estudiante

Asegurar que en `Detalle del estudiante`:

* se consulte el estado del consentimiento con
  `GET /api/v1/students/{student_id}/consent`
* si no existe o no está cargado, mostrar estado:
  `Consentimiento pendiente`
* si existe, mostrar estado cargado
* exista acción para:

    * subir consentimiento
    * reintentar carga si está pendiente
    * revocar si ya existe

Esto es importante porque el consentimiento ya no es obligatorio al momento del alta, pero sí debe poder gestionarse claramente después.

## Ajustes visuales necesarios

Revisar si el Figma de `Registrar estudiante` o `Detalle del estudiante` tenía espacio para consentimiento o privacidad.
Si no existe, agregar una sección simple, limpia y consistente.

No crear una pantalla nueva si no hace falta.
Resolverlo dentro del flujo actual.

## Manejo de errores

Casos:

* error al crear estudiante
* error al subir consentimiento
* archivo inválido
* sin conexión
* timeout
* 401 con refresh automático existente
* respuesta inesperada del backend

Mensajes amigables:

* `Estudiante registrado correctamente.`
* `Estudiante registrado correctamente con consentimiento adjunto.`
* `El estudiante fue registrado, pero el consentimiento quedó pendiente.`
* `No se pudo subir el consentimiento.`
* `Revisa tu conexión e inténtalo nuevamente.`

No mostrar JSON crudo.

## Criterios de aceptación

1. La pantalla Registrar estudiante muestra una sección de consentimiento.
2. Se puede seleccionar un archivo.
3. El nombre del archivo se muestra en la UI.
4. Se puede registrar un estudiante aunque no haya consentimiento adjunto.
5. Si hay archivo, al registrar se sube después de crear el estudiante.
6. El upload usa `multipart/form-data` con campo `file`.
7. Si ambas operaciones salen bien, se muestra éxito completo.
8. Si el estudiante se crea pero el consentimiento falla, se muestra éxito parcial.
9. Si no se adjunta archivo, se muestra éxito simple.
10. El detalle del estudiante refleja correctamente si el consentimiento está cargado o pendiente.
11. Se puede reintentar la carga desde detalle del estudiante.
12. flutter analyze no muestra errores.

Al finalizar, explica:

* qué archivos cambiaste
* cómo resolviste el flujo opcional del consentimiento
* cómo manejaste el caso de éxito parcial
* cómo se refleja el estado del consentimiento en detalle del estudiante
* si hubo que ajustar la UI respecto al Figma
