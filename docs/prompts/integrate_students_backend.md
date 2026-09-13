# Integración real del módulo de estudiantes

Necesito reemplazar los datos mockeados del módulo de estudiantes por integración real con el backend, manteniendo la arquitectura MVVM, separación por capas y buenas prácticas existentes en la aplicación Flutter TamizIA.

Ya están implementados o en proceso:

* autenticación real
* sesión con access token / refresh token
* interceptor Bearer
* refresh automático
* perfil docente real
* módulo de aulas real o integrado
* navegación desde aula a estudiantes

Todos los endpoints de estudiantes requieren autenticación y deben usar el access token a través del interceptor existente. No leer tokens manualmente desde las páginas o ViewModels.

---

# 1. Endpoints disponibles

## Estudiantes por aula

```text id="ygxbsv"
POST   /api/v1/classrooms/{classroom_id}/students
GET    /api/v1/classrooms/{classroom_id}/students
```

## Estudiante individual

```text id="mxa8cl"
GET    /api/v1/students/{student_id}
PUT    /api/v1/students/{student_id}
DELETE /api/v1/students/{student_id}
```

## Consentimiento

```text id="9rtr8q"
POST   /api/v1/students/{student_id}/consent/upload
POST   /api/v1/students/{student_id}/consent/revoke
GET    /api/v1/students/consent/template
GET    /api/v1/students/{student_id}/consent
GET    /api/v1/students/{student_id}/consent/download
```

Antes de implementar, inspeccionar Swagger y confirmar:

* request body exacto
* response body exacto
* status codes
* tipos MIME
* formato de errores
* si `gender` es enum estricto
* si `consent/download` devuelve string, URL, path o archivo

No inventar contratos.

---

# 2. Contrato de creación de estudiante

Endpoint:

```http id="3jagp4"
POST /api/v1/classrooms/{classroom_id}/students
Authorization: Bearer <access_token>
Content-Type: application/json
```

Path param:

* `classroom_id`: requerido

Request body:

```json id="2sc5x6"
{
  "code": "string",
  "age": 4,
  "gender": "BOY"
}
```

Respuesta:

```json id="7vqk5p"
{
  "student_id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "classroom_id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "code": "string",
  "age": 0,
  "gender": "string",
  "is_active": true,
  "created_at": "2026-06-29T00:27:52.892Z",
  "updated_at": "2026-06-29T00:27:52.892Z"
}
```

Importante:

* para crear estudiante se usa `classroom_id`
* no se debe pedir al usuario que seleccione aula manualmente si ya llegó desde el detalle del aula
* el formulario debe estar contextualizado al aula actual

---

# 3. Contrato de listado de estudiantes por aula

Endpoint:

```http id="3w7tns"
GET /api/v1/classrooms/{classroom_id}/students
Authorization: Bearer <access_token>
```

Respuesta:

```json id="l28l9t"
[
  {
    "student_id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
    "classroom_id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
    "code": "string",
    "age": 0,
    "gender": "string",
    "is_active": true,
    "created_at": "2026-06-29T00:32:57.491Z",
    "updated_at": "2026-06-29T00:32:57.491Z"
  }
]
```

Esta lista debe usarse para poblar la sección de estudiantes dentro del detalle de aula y/o la pantalla correspondiente.

---

# 4. Contrato de detalle de estudiante

Endpoint:

```http id="jtgoe3"
GET /api/v1/students/{student_id}
Authorization: Bearer <access_token>
```

Respuesta:

```json id="qalz2q"
{
  "student_id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "classroom_id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "code": "string",
  "age": 0,
  "gender": "string",
  "is_active": true,
  "created_at": "2026-06-29T00:33:15.153Z",
  "updated_at": "2026-06-29T00:33:15.153Z"
}
```

---

# 5. Contrato de actualización de estudiante

Endpoint:

```http id="k5vno1"
PUT /api/v1/students/{student_id}
Authorization: Bearer <access_token>
Content-Type: application/json
```

Request body:

```json id="dof2p7"
{
  "code": "string",
  "age": 4,
  "gender": "BOY"
}
```

Respuesta:

```json id="s5p8qz"
{
  "student_id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "classroom_id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "code": "string",
  "age": 0,
  "gender": "string",
  "is_active": true,
  "created_at": "2026-06-29T00:33:25.795Z",
  "updated_at": "2026-06-29T00:33:25.795Z"
}
```

---

# 6. Contrato de eliminación de estudiante

Endpoint:

```http id="geqdu6"
DELETE /api/v1/students/{student_id}
Authorization: Bearer <access_token>
```

Respuesta exitosa:

* `204 No Content`

No intentar parsear JSON en una respuesta 204.

---

# 7. Contratos de consentimiento

## Upload consentimiento

Endpoint:

```http id="d0jf99"
POST /api/v1/students/{student_id}/consent/upload
Authorization: Bearer <access_token>
Content-Type: multipart/form-data
```

Field requerido:

* `file`

Respuesta:

```json id="9m8dnt"
{
  "consent_id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "student_id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "status": true,
  "consent_date": "2026-06-29T00:34:17.962Z",
  "revoked_at": "2026-06-29T00:34:17.962Z",
  "evidence_blob_path": "string",
  "created_at": "2026-06-29T00:34:17.962Z",
  "updated_at": "2026-06-29T00:34:17.962Z"
}
```

## Revoke consentimiento

Endpoint:

```http id="wgan68"
POST /api/v1/students/{student_id}/consent/revoke
Authorization: Bearer <access_token>
```

Respuesta:

```json id="5xrmse"
{
  "consent_id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "student_id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "status": true,
  "consent_date": "2026-06-29T00:34:42.254Z",
  "revoked_at": "2026-06-29T00:34:42.254Z",
  "evidence_blob_path": "string",
  "created_at": "2026-06-29T00:34:42.254Z",
  "updated_at": "2026-06-29T00:34:42.254Z"
}
```

## Obtener estado del consentimiento

Endpoint:

```http id="51dy44"
GET /api/v1/students/{student_id}/consent
Authorization: Bearer <access_token>
```

Respuesta:

```json id="zg5j8y"
{
  "consent_id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "student_id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "status": true,
  "consent_date": "2026-06-29T00:35:33.969Z",
  "revoked_at": "2026-06-29T00:35:33.969Z",
  "evidence_blob_path": "string",
  "created_at": "2026-06-29T00:35:33.969Z",
  "updated_at": "2026-06-29T00:35:33.969Z"
}
```

## Descargar template

Endpoint:

```http id="6yotnk"
GET /api/v1/students/consent/template
Authorization: Bearer <access_token>
```

Swagger muestra ejemplo genérico:

```json id="isk7x0"
{
  "additionalProp1": {}
}
```

No asumir el tipo final sin verificar la respuesta real:

* puede ser URL
* JSON
* binario
* blob
* string

Inspeccionar en Swagger o probar el endpoint.

## Descargar consentimiento

Endpoint:

```http id="i7p0uo"
GET /api/v1/students/{student_id}/consent/download
Authorization: Bearer <access_token>
```

Swagger muestra ejemplo `"string"`.

No asumir si eso significa:

* URL firmada
* path
* base64
* contenido literal

Verificar primero el contrato real antes de diseñar el comportamiento UI.

---

# 8. Alcance de esta implementación

Implementar como prioridad:

1. Listar estudiantes por aula.
2. Registrar estudiante en un aula.
3. Ver detalle de estudiante.
4. Editar estudiante.
5. Eliminar estudiante.
6. Integrar estado de consentimiento en detalle de estudiante.
7. Integrar revoke consent.
8. Dejar preparada la subida de consentimiento.
9. Ajustar pantallas existentes para que coincidan con el backend.

Si algún endpoint de consentimiento no tiene contrato suficientemente claro en Swagger, dejarlo desacoplado y preparado, sin inventar lógica.

---

# 9. Entidad Student

Crear entidad inmutable:

```dart id="2v2y5u"
class Student {
  final String studentId;
  final String classroomId;
  final String code;
  final int age;
  final String gender;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

Agregar getters útiles si hace sentido:

```dart id="kyjlwm"
bool get hasValidAge => age > 0;
String get displayCode => code;
```

No usar mapas crudos en la UI.

---

# 10. Entidad StudentConsent

Crear entidad separada:

```dart id="3d1qfp"
class StudentConsent {
  final String consentId;
  final String studentId;
  final bool status;
  final DateTime? consentDate;
  final DateTime? revokedAt;
  final String? evidenceBlobPath;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

No mezclar consent dentro de Student si eso complica el contrato. Puede mantenerse como recurso separado.

---

# 11. DTOs requeridos

Crear DTOs equivalentes:

```text id="rb8r7s"
student_dto.dart
create_student_request_dto.dart
update_student_request_dto.dart
student_consent_dto.dart
```

Request DTO exacto:

```json id="3u03w5"
{
  "code": "string",
  "age": 4,
  "gender": "BOY"
}
```

No enviar:

* classroom_id en el body
* is_active
* created_at
* updated_at
* consent

`classroom_id` debe ir en la ruta.

---

# 12. Repository y data source

Mantener flujo:

```text id="7yp73r"
Page
  -> ViewModel
    -> StudentRepository
      -> StudentRemoteDataSource
        -> ApiClient
```

Contrato sugerido:

```dart id="qd5w4e"
abstract interface class StudentRepository {
  Future<List<Student>> getStudentsByClassroom(String classroomId);
  Future<Student> createStudent(String classroomId, CreateStudentRequest request);
  Future<Student> getStudentById(String studentId);
  Future<Student> updateStudent(String studentId, UpdateStudentRequest request);
  Future<void> deleteStudent(String studentId);

  Future<StudentConsent> getConsent(String studentId);
  Future<StudentConsent> revokeConsent(String studentId);
  Future<StudentConsent> uploadConsent(String studentId, File file);

  Future<dynamic> downloadConsentTemplate();
  Future<dynamic> downloadConsent(String studentId);
}
```

Si `downloadConsentTemplate` o `downloadConsent` tienen un tipo claro real, reemplazar `dynamic` por el tipo correcto.

---

# 13. Pantallas a revisar

Comparar contra el Figma del bloque 2 y corregir lo necesario para que cuadre con el backend real.

Pantallas:

```text id="wgv0y4"
Detalle de Aula
Registrar estudiante
Detalle del Estudiante
Editar estudiante
```

Objetivo:

* quitar campos mock
* quitar datos inventados
* usar IDs reales
* usar responses reales
* ajustar formularios a lo que el backend sí soporta

---

# 14. Registrar estudiante

La pantalla `Registrar estudiante` debe alinearse al backend actual.

Backend soporta solo:

* code
* age
* gender

Por lo tanto, si la UI actual tiene campos como:

* nombres
* alias
* grado
* aula seleccionada
* seudónimo adicional
* otros campos no soportados

hacer una de estas dos cosas:

1. eliminarlos del flujo real
2. ocultarlos temporalmente
3. dejarlos fuera del request si solo son decorativos, pero no es lo ideal

La recomendación es:

* usar únicamente los campos reales soportados por el backend

Formulario real:

* Código del estudiante
* Edad
* Género

Y debe mostrarse el aula actual como contexto no editable, por ejemplo:

```text id="ykpw3v"
Aula: 3ro A
```

pero no como campo seleccionable, porque `classroom_id` ya viene desde la ruta/navegación.

Validaciones:

* `code`: obligatorio, trim
* `age`: obligatorio, entero válido, rango razonable
* `gender`: obligatorio, valores válidos del backend

No inventar un aula en el body.

---

# 15. Gender

Swagger muestra ejemplo:

```text id="ezr9n5"
BOY
```

Verificar si el backend usa enum estricto, por ejemplo:

```text id="heow6b"
BOY
GIRL
OTHER
```

o solo `BOY` / `GIRL`.

La UI puede mostrar etiquetas amigables:

```text id="pqtiow"
Niño
Niña
Otro
```

pero debe enviar exactamente el valor esperado por la API.

No enviar minúsculas si backend espera mayúsculas.

---

# 16. Listado de estudiantes en Detalle de Aula

`Detalle de Aula` debe dejar de usar estudiantes dummy y cargar:

```http id="m2k4fw"
GET /api/v1/classrooms/{classroom_id}/students
```

Comportamiento:

* loading inicial
* lista real
* pull-to-refresh
* estado vacío
* estado error
* buscar localmente por código si la UI ya tiene búsqueda
* tap en estudiante -> navegar con `student_id` real a detalle

Si la lista viene vacía, mostrar:

```text id="q1u4y8"
Aún no hay estudiantes registrados en esta aula.
```

Acción:

```text id="ot6xut"
Registrar estudiante
```

No mostrar nombres ficticios si el backend no los maneja.

Mostrar cards con:

* código
* edad
* género
* estado activo/inactivo si aplica

No mostrar campos que el backend no devuelve.

---

# 17. Detalle del estudiante

Pantalla debe usar:

```http id="a5s0xq"
GET /api/v1/students/{student_id}
```

Mostrar datos reales:

* código
* edad
* género
* estado activo
* classroomId o aula contextual si se tiene
* createdAt / updatedAt solo si tiene sentido visual

No mostrar nombre completo ficticio si backend no lo devuelve.

Si el Figma estaba pensado con más campos, ajustarlo a lo realmente soportado por backend.

Agregar sección de consentimiento:

* estado actual de consentimiento
* fecha de consentimiento
* fecha de revocación si existe
* acciones disponibles según estado

Si el contrato no devuelve el aula detallada, no inventarla. Puede usarse el aula previa en navegación si ya se conoce, o dejar solo el `classroomId`.

---

# 18. Editar estudiante

Pantalla debe precargarse con:

```http id="58m3c7"
GET /api/v1/students/{student_id}
```

Campos editables reales:

* code
* age
* gender

No mostrar campos que no se pueden persistir.

Comportamiento:

* detectar cambios
* habilitar Guardar solo cuando hay cambios válidos
* Cancelar restaura
* PUT solo si hay cambios
* actualizar lista local y detalle

Mensaje:

```text id="xfgiek"
Estudiante actualizado correctamente.
```

---

# 19. Eliminar estudiante

Usar:

```http id="1s6i1r"
DELETE /api/v1/students/{student_id}
```

Antes mostrar confirmación.

Título:

```text id="62iq9t"
¿Eliminar estudiante?
```

Mensaje:

```text id="p181y8"
Esta acción eliminará al estudiante del aula.
```

Botones:

* Cancelar
* Eliminar

Después:

* remover de la lista local
* volver al detalle de aula
* mostrar confirmación

Mensaje:

```text id="8hqqg0"
Estudiante eliminado correctamente.
```

No intentar parsear body en 204.

---

# 20. Consentimiento

## Estado de consentimiento

En detalle del estudiante cargar:

```http id="vj2ejx"
GET /api/v1/students/{student_id}/consent
```

Mostrar:

* Consentimiento registrado: sí/no
* Fecha de consentimiento
* Revocado: sí/no
* Fecha de revocación si aplica

Si no existe consentimiento o el backend responde error apropiado, manejarlo como estado vacío controlado.

## Revocar consentimiento

Agregar acción:

```http id="660ffg"
POST /api/v1/students/{student_id}/consent/revoke
```

Mostrar confirmación antes.

Título:

```text id="6prm4l"
¿Revocar consentimiento?
```

Mensaje:

```text id="d3v7gw"
El estudiante ya no podrá continuar con evaluaciones que requieran consentimiento.
```

Después actualizar el estado en pantalla.

## Upload consentimiento

Preparar el flujo para subir archivo real usando multipart/form-data.

Comportamiento esperado:

* seleccionar archivo desde dispositivo
* enviar en campo `file`
* actualizar estado de consentimiento
* mostrar confirmación

Si todavía no existe el picker o el soporte de archivos en la app, dejarlo preparado pero funcional si se puede implementar con poco riesgo.

No inventar otro nombre de campo distinto a `file`.

## Download consentimiento y template

Como Swagger no deja claro el tipo real de respuesta:

* inspeccionar primero el content-type y la respuesta real
* si no es claro, dejar método desacoplado y una acción placeholder bien documentada
* no inventar descarga si el backend no está claro

---

# 21. Navegación

Flujo esperado:

```text id="g271rr"
Detalle de Aula(classroomId)
  -> Registrar estudiante(classroomId)
  -> Detalle del Estudiante(studentId)
      -> Editar estudiante(studentId)
```

Después de crear estudiante:

* volver al detalle de aula
* refrescar lista
* mostrar el nuevo estudiante

Después de editar:

* volver al detalle de estudiante o quedarse ahí
* actualizar info

Después de eliminar:

* volver al detalle de aula
* quitar estudiante de la lista

Usar IDs reales, no objetos mock.

---

# 22. Ajustes de UI y Figma

Comparar las pantallas existentes del bloque 2 con el contrato real del backend.

Si sobran campos en Figma respecto al backend:

* priorizar consistencia con el backend real
* simplificar la UI
* no dejar campos sin uso que confundan

Si falta algo mínimo para operar correctamente:

* agregarlo sin romper el estilo visual

Ejemplos probables:

* quitar nombre/apellido si backend no lo soporta
* quitar selección manual de aula si ya viene por `classroom_id`
* mostrar género como dropdown
* mostrar código como identificador principal

Mantener colores, spacing, navegación y componentes del design system.

---

# 23. ViewModels

## StudentsByClassroomViewModel

Estado:

```text id="5n5tp2"
students
filteredStudents
isLoading
isRefreshing
errorMessage
searchQuery
classroomId
```

Métodos:

```dart id="w8yel4"
Future<void> loadStudents(String classroomId);
Future<void> refreshStudents();
void search(String query);
void addStudent(Student student);
void updateStudentInList(Student student);
void removeStudent(String studentId);
```

## StudentDetailViewModel

Estado:

```text id="wys65w"
student
consent
isLoading
isDeleting
isUpdatingConsent
errorMessage
```

Métodos:

```dart id="jv8d9m"
Future<void> loadStudent(String studentId);
Future<void> loadConsent(String studentId);
Future<bool> deleteStudent();
Future<void> revokeConsent();
Future<void> uploadConsent(File file);
```

## StudentFormViewModel

Estado:

```text id="k6xwz2"
code
age
gender
isLoading
hasChanges
isFormValid
fieldErrors
generalError
```

Métodos:

```dart id="rjlwm1"
void initializeForCreate(String classroomId);
void initializeForEdit(Student student);
Future<Student?> createStudent();
Future<Student?> updateStudent(String studentId);
void resetForm();
```

No mostrar errores al entrar.

---

# 24. Manejo de errores

Mapear:

* 400: datos inválidos
* 401: sesión expirada
* 403: sin permisos
* 404: estudiante no encontrado
* 409: posible código duplicado si aplica
* 422: validación
* 500+: error servidor
* timeout
* sin conexión

Mensajes sugeridos:

```text id="o0y6ro"
No se pudieron cargar los estudiantes.
No se pudo registrar el estudiante.
No se pudo actualizar el estudiante.
No se pudo eliminar el estudiante.
El estudiante no fue encontrado.
Revisa los campos ingresados.
La sesión expiró. Inicia sesión nuevamente.
```

Usar el mensaje real del backend cuando sea seguro.

No mostrar JSON crudo.

---

# 25. Autenticación y refresh

Todos los endpoints deben usar el cliente protegido actual.

No duplicar lógica de refresh en StudentRepository.

Ante 401:

* usar refresh existente
* reintentar una sola vez
* si falla, cerrar sesión

No leer secure storage directamente desde la capa de estudiantes.

---

# 26. Estructura sugerida

Adaptar a la arquitectura existente.

```text id="tqjdul"
lib/
  features/
    students/
      data/
        datasources/
          student_remote_data_source.dart
          student_remote_data_source_impl.dart

        models/
          student_dto.dart
          create_student_request_dto.dart
          update_student_request_dto.dart
          student_consent_dto.dart

        repositories/
          student_repository_impl.dart

      domain/
        entities/
          student.dart
          student_consent.dart

        repositories/
          student_repository.dart

      presentation/
        viewmodels/
          students_by_classroom_viewmodel.dart
          student_detail_viewmodel.dart
          student_form_viewmodel.dart

        pages/
          create_student_page.dart
          student_detail_page.dart
          edit_student_page.dart
```

Los mocks pueden quedar solo para tests, no para runtime.

---

# 27. Pruebas

Agregar pruebas para:

## DTOs

* parseo correcto de student
* parseo correcto de consent
* snake_case -> camelCase
* fechas ISO

## Repository

* listar estudiantes por aula
* crear estudiante
* obtener estudiante
* actualizar estudiante
* eliminar con 204
* obtener consentimiento
* revocar consentimiento
* upload multipart

## ViewModels

* loading
* vacío
* error
* create success
* edit success
* delete success
* hasChanges
* no enviar update sin cambios

Las pruebas no deben depender del backend real.

---

# 28. Verificación manual

Probar:

1. Login.
2. Ir a Mis aulas.
3. Abrir detalle de aula real.
4. Cargar lista real de estudiantes.
5. Registrar estudiante usando `classroom_id` real.
6. Confirmar que aparece en la lista.
7. Abrir detalle usando `student_id` real.
8. Editar estudiante.
9. Confirmar actualización.
10. Eliminar estudiante.
11. Confirmar que desaparece de la lista.
12. Consultar consentimiento.
13. Revocar consentimiento.
14. Probar upload de consentimiento si se implementa.
15. Confirmar refresh automático si el token expira.
16. Confirmar que no aparecen datos mock en runtime.

---

# 29. Restricciones

* No modificar backend.
* No inventar campos no soportados.
* No mantener nombres ficticios si backend no los tiene.
* No hacer HTTP desde páginas.
* No duplicar lógica de auth.
* No cambiar módulos de aulas salvo integración necesaria de estudiantes en detalle de aula.
* No implementar evaluaciones aquí.
* No romper Figma innecesariamente.
* No refactorizar módulos ajenos.

---

# 30. Criterios de aceptación

La implementación estará completa si:

1. GET por aula lista estudiantes reales.
2. POST crea estudiante real usando `classroom_id`.
3. GET por `student_id` carga detalle real.
4. PUT actualiza estudiante real.
5. DELETE elimina estudiante real.
6. Se usan IDs reales de aula y estudiante en toda la navegación.
7. No se muestran estudiantes mock.
8. Registrar estudiante solo usa campos soportados por backend.
9. Editar estudiante precarga datos reales.
10. Guardar se habilita solo cuando hay cambios válidos.
11. Detalle de aula muestra lista real.
12. Detalle de estudiante muestra consentimiento real si existe.
13. Revocar consentimiento funciona.
14. Upload consentimiento usa multipart `file` si se implementa.
15. No se inventa comportamiento de download/template si Swagger no es claro.
16. `flutter analyze` no muestra errores.
17. Las pruebas pasan.

---

# 31. Entrega final

Al finalizar explicar:

1. Archivos creados.
2. Archivos modificados.
3. Contratos implementados.
4. Ajustes realizados en las pantallas.
5. Qué campos se quitaron o adaptaron respecto al Figma.
6. Cómo se usa `classroom_id`.
7. Cómo se usa `student_id`.
8. Cómo se integró consentimiento.
9. Qué endpoints quedaron preparados pero no totalmente explotados por falta de claridad en Swagger.
10. Resultados de `flutter analyze`.
11. Resultados de tests.
