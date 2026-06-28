Corrige la pantalla de perfil docente para que use correctamente los datos reales obtenidos desde:

GET /api/v1/teachers/me

Problema actual:

* La cabecera muestra correctamente el nombre, correo e institución reales.
* Sin embargo, los campos editables aparecen vacíos y solo muestran placeholders genéricos como “Juan”, “Pérez”, “[juan.perez@email.com](mailto:juan.perez@email.com)”, etc.
* El formulario marca error de campo obligatorio apenas entra a la pantalla.
* El botón “Guardar cambios” aparece habilitado aunque no se haya modificado ningún dato.

Comportamiento esperado:

1. Precargar los campos con la información real del perfil actual.
2. No mostrar errores al abrir la pantalla.
3. Detectar si existen cambios respecto al perfil original.
4. Habilitar “Guardar cambios” únicamente cuando:

    * existe al menos un cambio real
    * el formulario es válido
    * no hay una operación en curso
5. “Cancelar” debe restaurar los datos originales.
6. Después de guardar correctamente:

    * actualizar el perfil global
    * actualizar los valores originales del formulario
    * volver a deshabilitar “Guardar cambios”
    * mostrar confirmación
7. No realizar PUT si no existen cambios.

Mantener:

* MVVM
* AuthSessionManager o currentTeacher store existente
* TeacherRepository
* PUT /api/v1/teachers/me
* diseño actual
* navegación actual
* arquitectura existente

No modificar módulos no relacionados.

## Fuente de datos

El perfil actual está disponible mediante:

AuthSessionManager.currentTeacher

o el store equivalente ya existente.

El modelo contiene:

* teacherId
* name
* lastname
* email
* instituteName
* phone

No usar placeholders como datos iniciales.

Los placeholders pueden mantenerse solo como hintText cuando el campo no tenga valor, pero el controller debe contener el valor real del perfil.

## Inicialización del ViewModel

El TeacherProfileViewModel debe recibir o cargar el TeacherProfile actual.

Crear una copia original inmutable:

```dart
TeacherProfile? _originalProfile;
```

Y controladores o estado editable:

```dart
nameController
lastnameController
emailController
instituteController
phoneController
```

Al inicializar:

```dart
void initialize(TeacherProfile profile) {
  _originalProfile = profile;

  nameController.text = profile.name;
  lastnameController.text = profile.lastname;
  emailController.text = profile.email;
  instituteController.text = profile.instituteName;
  phoneController.text = profile.phone;

  clearValidationErrors();
  _attachListeners();
  notifyListeners();
}
```

No ejecutar initialize repetidamente en cada build.

Evitar sobrescribir lo que el usuario está editando cuando el widget se reconstruye.

Usar una bandera:

```dart
bool _initialized = false;
```

o inicializar desde `initState`, `didChangeDependencies` o desde el mecanismo de inyección existente.

## Detección de cambios

Agregar:

```dart
bool get hasChanges
```

Debe comparar valores normalizados contra el perfil original.

Ejemplo conceptual:

```dart
String _normalize(String value) => value.trim();

bool get hasChanges {
  final original = _originalProfile;
  if (original == null) return false;

  return _normalize(nameController.text) != _normalize(original.name) ||
      _normalize(lastnameController.text) != _normalize(original.lastname) ||
      _normalize(emailController.text) != _normalize(original.email) ||
      _normalize(instituteController.text) !=
          _normalize(original.instituteName) ||
      _normalize(phoneController.text) != _normalize(original.phone);
}
```

La comparación debe ignorar espacios accidentales al inicio y final.

No comparar objetos por referencia.

## Estado del botón Guardar cambios

Agregar:

```dart
bool get canSave =>
    hasChanges &&
    isFormValid &&
    !isLoading;
```

El botón debe usar:

```dart
onPressed: viewModel.canSave
    ? () => viewModel.saveChanges()
    : null;
```

Visualmente:

* habilitado: azul
* deshabilitado: gris o estilo disabled del tema

No dejar el botón habilitado si no hay cambios.

## Validación

No mostrar errores al entrar a la pantalla.

Agregar estado como:

```dart
bool _hasAttemptedSubmit = false;
```

Los errores deben mostrarse:

* después de que el usuario interactúe con el campo, o
* después de intentar guardar

No validar como obligatorio inmediatamente al inicializar.

Al precargar datos válidos:

* no debe aparecer “Los nombres son obligatorios”
* no debe aparecer borde rojo

Validaciones:

* nombre obligatorio
* apellido obligatorio
* email válido
* institución según contrato real
* teléfono válido

## Cancelar

El botón “Cancelar” debe:

1. Restaurar los valores de `_originalProfile`.
2. Limpiar errores.
3. Quitar foco del teclado.
4. Dejar `hasChanges == false`.
5. Deshabilitar Guardar cambios.

Ejemplo:

```dart
void resetForm() {
  final original = _originalProfile;
  if (original == null) return;

  nameController.text = original.name;
  lastnameController.text = original.lastname;
  emailController.text = original.email;
  instituteController.text = original.instituteName;
  phoneController.text = original.phone;

  _hasAttemptedSubmit = false;
  clearValidationErrors();
  notifyListeners();
}
```

Si no hay cambios, Cancelar puede quedar habilitado o deshabilitado según el diseño, pero no debe ejecutar ninguna petición.

## Guardar cambios

Al presionar Guardar cambios:

1. Verificar `hasChanges`.
2. Validar formulario.
3. Activar loading.
4. Construir request con valores normalizados.
5. Ejecutar PUT `/api/v1/teachers/me`.
6. Obtener el perfil actualizado:

    * desde la respuesta, si el backend lo devuelve
    * o ejecutar GET `/api/v1/teachers/me` si PUT solo devuelve mensaje
7. Actualizar `AuthSessionManager.currentTeacher`.
8. Reemplazar `_originalProfile` por el perfil actualizado.
9. Precargar nuevamente los controllers con la respuesta real.
10. Desactivar loading.
11. Mostrar mensaje:
    “Perfil actualizado correctamente.”
12. `hasChanges` debe quedar en false.

No navegar fuera de la pantalla automáticamente salvo que el flujo actual ya lo haga.

## Manejo de respuesta PUT

No asumir la respuesta.

Revisar Swagger:

* Si PUT devuelve TeacherProfile:

    * mapear directamente
* Si devuelve solo `message`:

    * ejecutar GET `/teachers/me`
    * actualizar perfil global con esa respuesta

No inventar campos.

## Perfil global

Después de actualizar, cualquier pantalla que consuma:

```dart
AuthSessionManager.currentTeacher
```

debe reflejar los cambios automáticamente.

Ejemplo:

* saludo del dashboard
* nombre en header
* correo
* institución
* teléfono

No mantener otra copia mock separada en la UI.

## TextEditingController

Asegurar:

* crear controllers una sola vez
* agregar listeners una sola vez
* remover listeners si aplica
* hacer dispose de controllers
* llamar notifyListeners cuando cambia un campo
* no crear controllers dentro de build

Ejemplo:

```dart
void _onFieldChanged() {
  notifyListeners();
}
```

## Carga inicial

Mientras el perfil aún no está disponible:

* mostrar loader o skeleton
* no mostrar formulario vacío
* no mostrar placeholders como si fueran datos reales

Si `currentTeacher == null`, ejecutar carga de perfil o mostrar estado de carga/error.

## Evitar sobrescritura al reconstruir

No hacer esto dentro de build:

```dart
controller.text = profile.name;
```

Eso puede sobrescribir lo que el usuario está escribiendo.

Inicializar una sola vez y actualizar solamente:

* al entrar a la pantalla
* al cancelar
* después de guardar exitosamente
* cuando cambie realmente el usuario autenticado

## Criterios de aceptación

1. La pantalla abre con los datos reales del docente en los campos.
2. La cabecera y los campos muestran la misma información.
3. No aparecen errores al abrir.
4. Guardar cambios inicia deshabilitado.
5. Cambiar un campo válido habilita Guardal deshabilita Guardar cambios.
7. Cancelar restaura todos los campos.
8. Cancelar limpia errores.r cambios.
6. Volver el campo a su valor origina
9. Guardar envía únicamente los valores actuales.
10. No se ejecuta PUT si no hay cambios.
11. Después de guardar, el perfil global se actualiza.
12. Después de guardar, el botón vuelve a deshabilitarse.
13. Los datos permanecen correctos al reconstruir la pantalla.
14. No se crean controllers dentro de build.
15. flutter analyze no muestra errores.

Al finalizar, explicar:

* cuál era la causa de que los campos salieran vacíos
* qué archivos se modificaron
* cómo se detectan cambios
* cómo se actualiza el perfil global
* cómo se evita validar al entrar
