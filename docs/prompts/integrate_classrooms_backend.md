# Integración real del módulo de aulas

Necesito reemplazar los datos mockeados del módulo de aulas por integración real con el backend, manteniendo la arquitectura MVVM, separación por capas y buenas prácticas existentes en la aplicación Flutter TamizIA.

Ya existe autenticación real con:

* access token
* refresh token
* almacenamiento seguro
* interceptor Bearer
* renovación automática del token
* AuthSessionManager

Todos los endpoints de aulas requieren autenticación:

```http
Authorization: Bearer <access_token>
```

No enviar ni administrar tokens directamente desde páginas o ViewModels. Deben ser agregados por el cliente HTTP/interceptor existente.

---

# 1. Endpoints disponibles

```text
GET    /api/v1/classrooms
POST   /api/v1/classrooms
GET    /api/v1/classrooms/{classroom_id}
PUT    /api/v1/classrooms/{classroom_id}
DELETE /api/v1/classrooms/{classroom_id}
```

Antes de implementar, inspeccionar el Swagger y confirmar:

* status codes
* formato exacto de errores
* respuesta exacta de cada operación
* obligatoriedad de todos los campos
* formato aceptado de `school_year`

No inventar campos.

---

# 2. Contrato de aula

Respuesta observada:

```json
{
  "classroom_id": "3751ecd7-0aa7-44c3-ae3e-36b955b5ee24",
  "homeroom_teacher_id": "2a1b5909-e081-4cc9-b313-a1d349dec2da",
  "name": "3ro A",
  "grade_level": "tercero",
  "section": "A",
  "school_year": "2026-06-18"
}
```

Crear entidad inmutable:

```dart
class Classroom {
  final String classroomId;
  final String homeroomTeacherId;
  final String name;
  final String gradeLevel;
  final String section;
  final DateTime schoolYear;
}
```

Si semánticamente `school_year` representa solo un año académico, revisar el contrato del backend. Actualmente Swagger utiliza una fecha ISO, por ejemplo:

```text
2026-06-28
```

Mientras el backend mantenga ese contrato, modelarlo como `DateTime` y enviarlo como:

```dart
schoolYear.toIso8601String().split('T').first
```

No convertirlo arbitrariamente a entero sin modificar antes el contrato backend.

---

# 3. Mapeo JSON

Crear `ClassroomDto` o equivalente.

Mapeo:

```text
classroom_id         -> classroomId
homeroom_teacher_id  -> homeroomTeacherId
name                 -> name
grade_level          -> gradeLevel
section              -> section
school_year          -> schoolYear
```

El DTO debe validar tipos y lanzar una excepción controlada si la respuesta es inválida.

No usar `Map<String, dynamic>` directamente en las páginas.

---

# 4. Crear aula

Endpoint:

```http
POST /api/v1/classrooms
Content-Type: application/json
Authorization: Bearer <access_token>
```

Request:

```json
{
  "name": "3ro A",
  "grade_level": "tercero",
  "section": "A",
  "school_year": "2026-06-28"
}
```

Respuesta esperada:

```json
{
  "classroom_id": "uuid",
  "homeroom_teacher_id": "uuid",
  "name": "3ro A",
  "grade_level": "tercero",
  "section": "A",
  "school_year": "2026-06-28"
}
```

La pantalla `Crear aula` debe contener exactamente los campos necesarios:

* Nombre del aula
* Grado
* Sección
* Año escolar / fecha académica

Si actualmente falta `school_year`, agregarlo.

Si la pantalla tiene campos que no existen en el contrato, eliminarlos o mantenerlos únicamente si cumplen una función visual y no se envían al backend.

No enviar:

* teacherId
* homeroomTeacherId
* classroomId

El backend debe obtener el docente desde el access token.

---

# 5. Listar aulas

Endpoint:

```http
GET /api/v1/classrooms
Authorization: Bearer <access_token>
```

Respuesta:

```json
[
  {
    "classroom_id": "3751ecd7-0aa7-44c3-ae3e-36b955b5ee24",
    "homeroom_teacher_id": "2a1b5909-e081-4cc9-b313-a1d349dec2da",
    "name": "3ro A",
    "grade_level": "tercero",
    "section": "A",
    "school_year": "2026-06-18"
  }
]
```

La pantalla `Mis aulas` debe:

* cargar datos reales al entrar
* mostrar loading inicial
* mostrar pull-to-refresh
* mostrar estado vacío
* mostrar estado de error con botón reintentar
* dejar de usar aulas dummy
* conservar la búsqueda local sobre las aulas cargadas

Estado vacío:

```text
Aún no tienes aulas registradas.
```

Acción:

```text
Crear mi primera aula
```

La lista debe mostrar:

* nombre
* grado
* sección
* año escolar
* cantidad de estudiantes solo si el backend la devuelve

Importante:

El response actual de aulas no incluye cantidad de estudiantes.

Por lo tanto:

* no mostrar una cantidad falsa
* no mantener valores mock como “24 estudiantes”
* ocultar temporalmente ese texto
* o mostrarlo solamente cuando el backend tenga un campo real o se integre el endpoint de estudiantes por aula

No inventar `studentCount`.

---

# 6. Obtener detalle de aula

Endpoint:

```http
GET /api/v1/classrooms/{classroom_id}
Authorization: Bearer <access_token>
```

Usar el `classroomId` real de la card seleccionada.

No navegar usando objetos mock ni nombres como identificador.

La pantalla `Detalle de Aula` debe mostrar:

* nombre
* grado
* sección
* año escolar
* datos reales de la respuesta

La lista de estudiantes puede seguir temporalmente mockeada solo hasta integrar el módulo de estudiantes, pero debe quedar claramente separada del objeto Classroom.

Preferiblemente:

* mostrar una sección vacía o loading preparado para estudiantes
* no mezclar alumnos mock con un aula real en una versión de integración

Texto temporal recomendado:

```text
La integración de estudiantes se realizará en el siguiente bloque.
```

No mostrar cantidad falsa.

---

# 7. Editar aula

Endpoint:

```http
PUT /api/v1/classrooms/{classroom_id}
Content-Type: application/json
Authorization: Bearer <access_token>
```

Request:

```json
{
  "name": "3ro A",
  "grade_level": "primero",
  "section": "A",
  "school_year": "2026-06-28"
}
```

Respuesta:

```json
{
  "classroom_id": "uuid",
  "homeroom_teacher_id": "uuid",
  "name": "3ro A",
  "grade_level": "primero",
  "section": "A",
  "school_year": "2026-06-28"
}
```

La pantalla `Editar aula` debe:

* recibir `classroomId`
* cargar el aula real por ID o recibir la entidad ya cargada
* precargar los campos con los valores reales
* no mostrar placeholders como si fueran datos
* mantener una copia original
* detectar cambios
* habilitar `Guardar cambios` únicamente cuando:

    * exista al menos un cambio
    * el formulario sea válido
    * no esté cargando

Cancelar debe:

* restaurar valores originales
* limpiar errores
* no ejecutar PUT

Guardar debe:

1. validar
2. ejecutar PUT
3. actualizar el aula en el estado local
4. volver al detalle o lista
5. mostrar confirmación

Mensaje:

```text
Aula actualizada correctamente.
```

No ejecutar PUT si no hay cambios.

---

# 8. Eliminar aula

Endpoint:

```http
DELETE /api/v1/classrooms/{classroom_id}
Authorization: Bearer <access_token>
```

Status exitoso:

```text
204 No Content
```

No intentar parsear JSON en una respuesta 204.

Agregar una opción visible en:

* detalle de aula
* o edición de aula

Antes de eliminar mostrar confirmación:

Título:

```text
¿Eliminar aula?
```

Mensaje:

```text
Esta acción eliminará el aula. Verifica que no existan estudiantes o evaluaciones asociadas antes de continuar.
```

Botones:

* Cancelar
* Eliminar aula

El botón destructivo debe ser rojo.

Después de eliminar:

* remover el aula del estado local
* volver a `Mis aulas`
* mostrar confirmación
* no permitir volver al detalle eliminado mediante back

Mensaje:

```text
Aula eliminada correctamente.
```

Si backend rechaza la eliminación por relaciones asociadas:

```text
No se puede eliminar el aula porque tiene información asociada.
```

Mapear el mensaje real del backend.

---

# 9. Repository y data source

Mantener este flujo:

```text
Page
  -> ViewModel
    -> ClassroomRepository
      -> ClassroomRemoteDataSource
        -> ApiClient
```

Contrato sugerido:

```dart
abstract interface class ClassroomRepository {
  Future<List<Classroom>> getClassrooms();

  Future<Classroom> getClassroomById(
    String classroomId,
  );

  Future<Classroom> createClassroom(
    CreateClassroomRequest request,
  );

  Future<Classroom> updateClassroom(
    String classroomId,
    UpdateClassroomRequest request,
  );

  Future<void> deleteClassroom(
    String classroomId,
  );
}
```

Data source:

```dart
abstract interface class ClassroomRemoteDataSource {
  Future<List<ClassroomDto>> getClassrooms();

  Future<ClassroomDto> getClassroomById(
    String classroomId,
  );

  Future<ClassroomDto> createClassroom(
    CreateClassroomRequestDto request,
  );

  Future<ClassroomDto> updateClassroom(
    String classroomId,
    UpdateClassroomRequestDto request,
  );

  Future<void> deleteClassroom(
    String classroomId,
  );
}
```

No hacer peticiones HTTP desde ViewModels ni páginas.

---

# 10. DTOs de request

Crear:

```text
CreateClassroomRequestDto
UpdateClassroomRequestDto
```

JSON exacto:

```json
{
  "name": "string",
  "grade_level": "primero",
  "section": "A",
  "school_year": "2026-06-28"
}
```

No enviar IDs.

No enviar campos nulos si el backend espera strings requeridos.

---

# 11. ViewModels

## ClassroomsViewModel

Estado:

```text
classrooms
filteredClassrooms
isLoading
isRefreshing
errorMessage
searchQuery
```

Métodos:

```dart
Future<void> loadClassrooms();
Future<void> refreshClassrooms();
void search(String query);
void clearSearch();
void addClassroom(Classroom classroom);
void updateClassroomInList(Classroom classroom);
void removeClassroom(String classroomId);
```

## ClassroomDetailViewModel

Estado:

```text
classroom
isLoading
isDeleting
errorMessage
```

Métodos:

```dart
Future<void> loadClassroom(String id);
Future<bool> deleteClassroom();
```

## ClassroomFormViewModel

Debe servir para crear y editar o mantener ViewModels separados si la arquitectura existente ya lo hace.

Estado:

```text
name
gradeLevel
section
schoolYear
isLoading
hasChanges
isFormValid
fieldErrors
generalError
```

No inicializar errores al abrir.

---

# 12. Formularios y ajustes de UI

Revisar estas pantallas:

```text
Listar aulas
Crear aula
Detalle de Aula
Editar aula
```

Comparar contra:

```text
docs/figma/BLOCK-2-DOCENTE-AULA-ESTUDIANTE/
```

Ajustar únicamente lo necesario para que coincidan con el contrato real.

## Crear aula

Campos reales:

* Nombre del aula
* Grado
* Sección
* Año escolar

## Editar aula

Mismos campos, precargados.

## Listar aulas

No mostrar cantidad de estudiantes mientras no exista ese dato real.

## Detalle de aula

No mostrar alumnos mock asociados a un aula real.

Mantener diseño, colores, tipografía y navegación actuales.

---

# 13. Grade level

Revisar los valores permitidos por el backend.

Swagger muestra ejemplos como:

```text
primero
tercero
```

No permitir valores arbitrarios si el backend usa un enum.

Usar un selector con valores compatibles con el contrato real, por ejemplo:

```text
primero
segundo
tercero
cuarto
quinto
sexto
```

La UI puede mostrarlos capitalizados:

```text
Primero
Segundo
Tercero
Cuarto
Quinto
Sexto
```

Pero enviar al backend el valor exacto esperado:

```text
primero
segundo
tercero
cuarto
quinto
sexto
```

Confirmar el enum exacto en Swagger antes de codificar.

---

# 14. Section

Normalizar:

* trim
* uppercase

Ejemplo:

```text
a -> A
b -> B
```

Validación:

* obligatorio
* longitud razonable
* no enviar espacios

No limitar a una sola letra si el backend acepta secciones como `A1`, pero revisar el contrato antes.

---

# 15. School year

El backend actualmente recibe una fecha:

```text
YYYY-MM-DD
```

La pantalla debe usar:

* DatePicker
* o selector de año convertido a una fecha válida definida por el proyecto

La solución más segura mientras el contrato sea una fecha:

* mostrar un DatePicker
* enviar fecha ISO
* mostrarla en UI con formato amigable

Ejemplo UI:

```text
2026
```

Ejemplo request:

```text
2026-01-01
```

Pero solo usar esta conversión si el equipo acuerda que el backend representa el año escolar mediante una fecha inicial.

No inventar una transformación sin comprobar el significado funcional.

Si el Figma solo muestra “Año escolar”, puede conservar ese label y usar internamente la fecha requerida por API.

---

# 16. Autenticación

Todos los endpoints deben usar el cliente protegido existente.

No leer el token directamente desde secure storage en cada Repository.

El flujo debe ser:

```text
Repository
  -> ApiClient protegido
    -> AuthInterceptor
      -> AuthSessionManager.getValidAccessToken()
```

Ante 401:

* refresh una sola vez
* reintentar petición
* si falla, cerrar sesión

No duplicar lógica de refresh en ClassroomRepository.

---

# 17. Manejo de errores

Mapear:

* 400: datos inválidos
* 401: sesión expirada
* 403: sin permisos
* 404: aula no encontrada
* 409: aula duplicada o conflicto
* 422: validación
* 500+: error servidor
* timeout
* sin conexión

Mensajes sugeridos:

```text
No se pudieron cargar las aulas.
El aula no fue encontrada.
Ya existe un aula con esos datos.
Revisa los campos ingresados.
No se pudo crear el aula.
No se pudo actualizar el aula.
No se pudo eliminar el aula.
```

Usar el mensaje real del backend cuando sea seguro y entendible.

No mostrar JSON crudo.

---

# 18. Estado y actualización local

Después de crear:

* insertar el aula retornada por backend en la lista
* no crear un objeto local con ID inventado

Después de editar:

* reemplazar el aula por `classroomId`

Después de eliminar:

* removerla por `classroomId`

Al volver a la lista:

* evitar recargar innecesariamente si el estado ya se actualizó
* permitir pull-to-refresh para sincronizar

---

# 19. Navegación

Usar IDs reales.

Flujo:

```text
Mis aulas
  -> Detalle de aula(classroomId)
    -> Editar aula(classroomId)
```

Crear:

```text
Mis aulas
  -> Crear aula
```

Después de crear:

* volver a lista
* mostrar nueva aula

Después de editar:

* volver a detalle
* mostrar datos actualizados

Después de eliminar:

* volver a lista eliminando historial del detalle

---

# 20. Estructura sugerida

Adaptar a lo existente; no duplicar clases equivalentes.

```text
lib/
  features/
    classrooms/
      data/
        datasources/
          classroom_remote_data_source.dart
          classroom_remote_data_source_impl.dart

        models/
          classroom_dto.dart
          create_classroom_request_dto.dart
          update_classroom_request_dto.dart

        repositories/
          classroom_repository_impl.dart

      domain/
        entities/
          classroom.dart

        repositories/
          classroom_repository.dart

      presentation/
        viewmodels/
          classrooms_viewmodel.dart
          classroom_detail_viewmodel.dart
          classroom_form_viewmodel.dart

        pages/
          classrooms_page.dart
          create_classroom_page.dart
          classroom_detail_page.dart
          edit_classroom_page.dart
```

Eliminar o dejar fuera del flujo real:

```text
MockClassroomService
```

Puede conservarse solo para tests o previews, pero no debe usarse en runtime.

---

# 21. Pruebas unitarias

Agregar pruebas para:

## DTO

* parsea lista de aulas
* parsea `school_year`
* mapea snake_case
* falla con datos inválidos

## Repository

* lista aulas
* crea aula
* obtiene detalle
* actualiza aula
* elimina aula con 204
* mapea 404
* mapea 409
* mapea 422

## ViewModels

* loading de lista
* estado vacío
* estado error
* búsqueda
* creación exitosa
* edición exitosa
* eliminación exitosa
* `hasChanges`
* no ejecuta PUT sin cambios

Los tests no deben depender del backend real.

---

# 22. Verificación manual

Probar:

1. Login.
2. Abrir Mis aulas.
3. Confirmar GET real.
4. Confirmar que solo se muestran aulas del docente autenticado.
5. Crear aula.
6. Confirmar que aparece en la lista.
7. Abrir detalle.
8. Confirmar GET por ID.
9. Editar aula.
10. Confirmar PUT.
11. Confirmar formulario precargado.
12. Confirmar Guardar deshabilitado sin cambios.
13. Eliminar aula.
14. Confirmar 204.
15. Confirmar que desaparece de la lista.
16. Probar token expirado.
17. Confirmar refresh automático.
18. Probar estado sin aulas.
19. Probar error de conexión.
20. Confirmar que no aparecen cantidades mock de estudiantes.

---

# 23. Restricciones

* No modificar backend.
* No inventar endpoints.
* No inventar studentCount.
* No mantener aulas dummy en runtime.
* No hacer HTTP desde páginas.
* No duplicar manejo de tokens.
* No guardar access token en el ViewModel.
* No cambiar módulos de auth.
* No integrar estudiantes todavía.
* No cambiar diseño general salvo ajustes requeridos por el contrato.
* No refactorizar módulos ajenos.

---

# 24. Criterios de aceptación

La implementación está completa cuando:

1. GET lista aulas reales.
2. POST crea aula real.
3. GET por ID carga detalle real.
4. PUT actualiza aula real.
5. DELETE elimina aula real.
6. Todas las peticiones usan Bearer automáticamente.
7. 401 usa refresh existente.
8. Las pantallas ya no usan aulas dummy.
9. Los formularios coinciden con el contrato backend.
10. La edición precarga datos reales.
11. Guardar se habilita solo cuando hay cambios válidos.
12. La lista maneja loading, vacío y error.
13. No se muestran cantidades falsas de estudiantes.
14. DELETE 204 no intenta parsear JSON.
15. `flutter analyze` no muestra errores.
16. Las pruebas pasan.

---

# 25. Entrega final

Al finalizar explicar:

1. Archivos creados.
2. Archivos modificados.
3. Contratos implementados.
4. Ajustes realizados en las pantallas.
5. Campos eliminados o añadidos.
6. Cómo se usa el token.
7. Cómo funciona refresh.
8. Cómo se sincroniza la lista después de CRUD.
9. Resultados de `flutter analyze`.
10. Resultados de tests.
11. Cualquier diferencia encontrada entre Figma y backend.
v