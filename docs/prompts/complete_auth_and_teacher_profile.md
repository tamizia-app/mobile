# Completar autenticación, sesión y perfil docente

Necesito completar la integración real de autenticación y perfil docente en la aplicación Flutter TamizIA.

Actualmente ya se implementaron parcialmente:

* `POST /api/v1/auth/signup`
* `POST /api/v1/auth/signin`

Ahora se debe revisar lo existente y completar correctamente:

1. Persistencia segura de sesión.
2. Renovación automática del access token.
3. Cierre de sesión.
4. Recuperación de contraseña.
5. Restablecimiento de contraseña.
6. Obtención del perfil docente autenticado.
7. Actualización del perfil docente.
8. Estado global controlado de sesión y usuario actual.
9. Protección de rutas.
10. Manejo correcto de errores y expiración.

Mantener:

* Flutter.
* MVVM.
* Separación por capas.
* Buenas prácticas.
* UI actual.
* Rutas existentes.
* Backend real.
* Sin Firebase.
* Sin Supabase.
* Sin mocks para autenticación y perfil docente.

No modificar módulos ajenos salvo para conectar el usuario autenticado y cerrar sesión.

---

# 1. Backend

Base URL configurable:

```text
Android Emulator: http://10.0.2.2:8000
Flutter Web/Desktop: http://localhost:8000
Dispositivo físico: http://IP_LOCAL_PC:8000
```

Usar:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

No hardcodear la URL en páginas, widgets o ViewModels.

---

# 2. Endpoints

## Autenticación

```text
POST /api/v1/auth/signup
POST /api/v1/auth/signin
POST /api/v1/auth/refresh
POST /api/v1/auth/signout
POST /api/v1/auth/forgot-password
PATCH /api/v1/auth/reset-password
```

## Perfil docente

```text
GET /api/v1/teachers/me
PUT /api/v1/teachers/me
```

Los endpoints de perfil requieren:

```http
Authorization: Bearer <access_token>
```

Antes de implementar cada request, revisar el Swagger y confirmar exactamente:

* request body
* status codes
* response body
* errores posibles

No inventar request bodies no documentados.

Especialmente revisar en Swagger el body exacto de:

* `/auth/signout`
* `/auth/refresh`
* `/auth/forgot-password`
* `/auth/reset-password`

---

# 3. Respuesta de signin

El endpoint:

```http
POST /api/v1/auth/signin
```

devuelve:

```json
{
  "access_token": "string",
  "refresh_token": "string",
  "token_type": "bearer",
  "expires_in": 28800
}
```

Crear un DTO y una entidad de sesión.

Ejemplo conceptual:

```dart
class AuthSession {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;
  final DateTime expiresAt;
}
```

Calcular:

```dart
expiresAt = DateTime.now().add(
  Duration(seconds: expiresIn),
);
```

No depender únicamente de `expires_in`; guardar también `expiresAt` para verificar expiración localmente.

---

# 4. Respuesta de refresh

Request documentado:

```json
{
  "refresh_token": "string"
}
```

Respuesta:

```json
{
  "access_token": "string",
  "refresh_token": "string",
  "token_type": "bearer",
  "expires_in": 28800
}
```

Importante:

El backend aplica rotación del refresh token, porque devuelve un nuevo `refresh_token`.

Por lo tanto, después de cada refresh exitoso:

1. Reemplazar access token anterior.
2. Reemplazar refresh token anterior.
3. Reemplazar token type.
4. Recalcular `expiresAt`.
5. Guardar toda la sesión nueva de manera atómica.

Nunca conservar el refresh token anterior después de una renovación exitosa.

---

# 5. Persistencia segura de sesión

Usar:

```text
flutter_secure_storage
```

No usar `SharedPreferences` para tokens.

Crear una abstracción:

```dart
abstract interface class AuthSessionStorage {
  Future<void> saveSession(AuthSession session);
  Future<AuthSession?> readSession();
  Future<void> clearSession();
}
```

Implementar:

```text
SecureAuthSessionStorage
```

Guardar:

* `access_token`
* `refresh_token`
* `token_type`
* `expires_in`
* `expires_at`

No guardar:

* contraseña
* confirmación de contraseña
* datos sensibles innecesarios

El almacenamiento y lectura deben manejar errores sin provocar crash.

---

# 6. Estado global de autenticación

No usar una variable global mutable.

Crear un administrador central de sesión, por ejemplo:

```text
AuthSessionManager
```

Puede implementarse con `ChangeNotifier`, Provider o el mecanismo de estado ya utilizado en el proyecto.

Responsabilidades:

```dart
enum AuthenticationStatus {
  unknown,
  unauthenticated,
  authenticated,
  refreshing,
}
```

Estado esperado:

```text
status
session
currentTeacher
isInitializing
isRefreshing
lastError
```

Métodos sugeridos:

```dart
Future<void> initialize();
Future<void> signIn(String email, String password);
Future<void> signUp(...);
Future<bool> refreshSession();
Future<void> loadCurrentTeacher();
Future<void> updateCurrentTeacher(...);
Future<void> signOut();
Future<String?> getValidAccessToken();
```

`AuthSessionManager` debe:

* restaurar sesión al iniciar la app
* verificar si existe sesión
* renovar token si está expirado o próximo a expirar
* cargar `GET /teachers/me`
* mantener el docente actual en memoria
* notificar cambios a toda la aplicación
* limpiar sesión al cerrar sesión
* limpiar sesión si el refresh token ya no es válido

Las pantallas pueden leer `currentTeacher`, pero no modificarlo directamente.

---

# 7. Inicialización de la aplicación

Al iniciar la app:

1. Leer sesión desde secure storage.
2. Si no existe:

    * marcar `unauthenticated`
    * mostrar login o splash correspondiente.
3. Si existe y access token sigue válido:

    * marcar sesión autenticada
    * ejecutar `GET /api/v1/teachers/me`
4. Si access token expiró o está próximo a expirar:

    * ejecutar refresh.
5. Si refresh funciona:

    * guardar nueva sesión
    * cargar perfil.
6. Si refresh falla con 401/403:

    * limpiar sesión
    * enviar a login.

Mientras se inicializa:

* mostrar splash/loading
* no mostrar momentáneamente una pantalla protegida
* evitar parpadeo login/dashboard

---

# 8. Renovación anticipada

No esperar necesariamente a que expire completamente.

Considerar el token próximo a expirar cuando falten, por ejemplo:

```text
60 segundos
```

Método conceptual:

```dart
bool get isExpiringSoon {
  return DateTime.now().isAfter(
    expiresAt.subtract(const Duration(seconds: 60)),
  );
}
```

Antes de cada petición protegida:

* obtener un access token válido
* refrescar si está por expirar
* luego ejecutar la petición

---

# 9. Interceptor HTTP

Centralizar el cliente HTTP.

Usar la librería ya instalada. Si existe Dio, mantener Dio.

Crear interceptores separados si corresponde:

```text
AuthInterceptor
RefreshTokenInterceptor
DebugLoggingInterceptor
```

## Request interceptor

Para endpoints protegidos:

```http
Authorization: Bearer <access_token>
```

No enviar bearer token en:

* signup
* signin
* refresh
* forgot-password
* reset-password

## Error interceptor

Ante `401` en una petición protegida:

1. Verificar que no sea el propio endpoint `/auth/refresh`.
2. Ejecutar refresh una sola vez.
3. Guardar la nueva sesión.
4. Repetir la petición original con el token nuevo.
5. Evitar bucles infinitos.

Si refresh falla:

* limpiar sesión
* marcar usuario no autenticado
* redirigir a login

No reintentar indefinidamente.

---

# 10. Evitar múltiples refresh simultáneos

Si varias peticiones reciben 401 al mismo tiempo, no ejecutar varios refresh paralelos.

Implementar un lock, `Completer`, mutex o mecanismo equivalente para que:

* solo haya un refresh activo
* las demás peticiones esperen el resultado
* después todas utilicen el nuevo access token

Ejemplo conceptual:

```dart
Future<AuthSession>? _refreshFuture;
```

No iniciar otro refresh mientras `_refreshFuture` esté activo.

---

# 11. Signout

Endpoint:

```http
POST /api/v1/auth/signout
```

Respuesta:

```json
{
  "message": "Logged out successfully."
}
```

Revisar en Swagger el request body exacto.

Si requiere refresh token, enviar exactamente:

```json
{
  "refresh_token": "..."
}
```

Solo hacerlo si el contrato del backend lo confirma.

Flujo:

1. Deshabilitar botón cerrar sesión.
2. Ejecutar endpoint signout.
3. Independientemente de un error de red razonable, limpiar:

    * access token
    * refresh token
    * token type
    * expiresAt
    * perfil actual
4. Marcar usuario como `unauthenticated`.
5. Navegar a login eliminando historial protegido.

No dejar el dashboard accesible con el botón atrás.

Usar navegación equivalente a:

```dart
pushNamedAndRemoveUntil('/login', (_) => false);
```

No mostrar tokens en logs.

---

# 12. Forgot password

Endpoint:

```http
POST /api/v1/auth/forgot-password
```

Request:

```json
{
  "email": "user@example.com"
}
```

Respuesta:

```json
{
  "message": "If the email exists, a reset token has been sent."
}
```

Conectar la pantalla existente de recuperar contraseña.

Comportamiento:

* validar email
* mostrar loading
* evitar doble envío
* ejecutar endpoint real
* mostrar un mensaje neutral aunque el correo no exista
* no revelar si una cuenta está registrada

Mensaje recomendado en UI:

```text
Si el correo existe, recibirás un enlace para restablecer tu contraseña.
```

No mostrar información que permita enumerar cuentas.

---

# 13. Reset password

Endpoint:

```http
PATCH /api/v1/auth/reset-password
```

Request:

```json
{
  "token": "string",
  "new_password": "string"
}
```

Respuesta:

```json
{
  "message": "Password has been reset successfully."
}
```

Crear una pantalla real de restablecimiento de contraseña si todavía no existe.

Campos:

* Nueva contraseña
* Confirmar nueva contraseña

El token debe recibirse:

* desde deep link en el futuro
* o mediante argumento de ruta para pruebas actuales

No pedir al usuario que copie tokens largos en una versión final.

Por ahora permitir una de estas opciones:

1. Ruta interna con argumento `token`.
2. Deep link si ya existe soporte.
3. Campo temporal solo para desarrollo, claramente marcado y no visible en release.

Validaciones:

* token obligatorio
* contraseña mínimo 8 caracteres
* confirmación debe coincidir
* no reutilizar la contraseña actual en memoria
* nunca guardar la contraseña

Al completar:

* mostrar confirmación
* navegar a login
* limpiar campos

---

# 14. Perfil docente

## Obtener perfil

Endpoint:

```http
GET /api/v1/teachers/me
Authorization: Bearer <access_token>
```

Respuesta:

```json
{
  "teacher_id": "2a1b5909-e081-4cc9-b313-a1d349dec2da",
  "name": "Joseph Alexis",
  "lastname": "Huamani Mandujano",
  "email": "josephhm335@gmail.com",
  "institute_name": "upc",
  "phone": "936450356"
}
```

Crear:

```text
TeacherProfileDto
TeacherProfile
TeacherRepository
TeacherRemoteDataSource
TeacherRepositoryImpl
```

Mapeo exacto:

```text
teacher_id -> teacherId
name -> name
lastname -> lastname
email -> email
institute_name -> instituteName
phone -> phone
```

Después de signin exitoso:

1. Guardar sesión.
2. Ejecutar `GET /teachers/me`.
3. Guardar perfil en `AuthSessionManager.currentTeacher`.
4. Navegar al dashboard.

No navegar al dashboard antes de completar el flujo mínimo de sesión y perfil, salvo que se maneje loading correctamente.

El perfil debe estar disponible para:

* dashboard
* perfil docente
* formularios relacionados
* header con saludo
* futuros módulos

No duplicar el perfil en múltiples ViewModels sin necesidad.

---

# 15. Actualizar perfil docente

Endpoint:

```http
PUT /api/v1/teachers/me
Authorization: Bearer <access_token>
```

Request:

```json
{
  "name": "Joseph Alexis",
  "lastname": "Huamani Mandujano",
  "email": "josephhm335@gmail.com",
  "institute_name": "upc",
  "phone": "936450356"
}
```

Revisar la respuesta exacta del backend.

Conectar la pantalla existente de perfil docente.

Campos editables:

* Nombres
* Apellidos
* Correo electrónico
* Institución educativa
* Teléfono

Flujo:

1. Precargar campos desde `currentTeacher`.
2. Validar formulario.
3. Mostrar loading.
4. Ejecutar PUT.
5. Actualizar `currentTeacher` con la respuesta del backend.
6. Notificar a toda la app.
7. Mostrar confirmación.

El dashboard y cualquier header deben actualizarse automáticamente después de editar el perfil.

No asumir que el backend devuelve el perfil actualizado; revisar Swagger. Si solo devuelve un mensaje, volver a ejecutar `GET /teachers/me`.

---

# 16. Modelo de perfil global

Crear una entidad inmutable:

```dart
class TeacherProfile {
  final String teacherId;
  final String name;
  final String lastname;
  final String email;
  final String instituteName;
  final String phone;

  String get fullName => '$name $lastname'.trim();
}
```

No almacenar el perfil como Map dinámico dentro de la UI.

`AuthSessionManager.currentTeacher` debe ser:

```dart
TeacherProfile?
```

No guardar el perfil completo en secure storage salvo necesidad real.

Preferencia:

* tokens: secure storage
* perfil: memoria
* perfil recargado desde `/teachers/me` al iniciar sesión

Si se desea cache temporal, usar una capa separada, pero no es necesaria ahora.

---

# 17. Repositorios

## AuthRepository

Contrato sugerido:

```dart
abstract interface class AuthRepository {
  Future<AuthSession> signIn(SigninRequest request);
  Future<void> signUp(SignupRequest request);
  Future<AuthSession> refresh(String refreshToken);
  Future<void> signOut(String refreshToken);
  Future<String> forgotPassword(String email);
  Future<String> resetPassword({
    required String token,
    required String newPassword,
  });
}
```

Ajustar `signUp` al response real.

## TeacherRepository

```dart
abstract interface class TeacherRepository {
  Future<TeacherProfile> getMyProfile();
  Future<TeacherProfile> updateMyProfile(
    UpdateTeacherProfileRequest request,
  );
}
```

Si PUT no devuelve perfil, usar el tipo real y recargar posteriormente.

---

# 18. Estructura sugerida

Adaptar a la arquitectura existente y no duplicar clases equivalentes.

```text
lib/
  core/
    config/
      api_config.dart

    network/
      api_client.dart
      api_exception.dart
      auth_interceptor.dart
      refresh_token_interceptor.dart

    storage/
      auth_session_storage.dart
      secure_auth_session_storage.dart

    session/
      auth_session_manager.dart
      authentication_status.dart

  features/
    auth/
      data/
        datasources/
          auth_remote_data_source.dart
          auth_remote_data_source_impl.dart

        models/
          auth_session_dto.dart
          signin_request_dto.dart
          signup_request_dto.dart
          refresh_request_dto.dart
          forgot_password_request_dto.dart
          reset_password_request_dto.dart
          message_response_dto.dart

        repositories/
          auth_repository_impl.dart

      domain/
        entities/
          auth_session.dart

        repositories/
          auth_repository.dart

      presentation/
        viewmodels/
          login_viewmodel.dart
          register_viewmodel.dart
          forgot_password_viewmodel.dart
          reset_password_viewmodel.dart

        pages/
          login_page.dart
          register_page.dart
          forgot_password_page.dart
          reset_password_page.dart

    teacher/
      data/
        datasources/
          teacher_remote_data_source.dart
          teacher_remote_data_source_impl.dart

        models/
          teacher_profile_dto.dart
          update_teacher_profile_request_dto.dart

        repositories/
          teacher_repository_impl.dart

      domain/
        entities/
          teacher_profile.dart

        repositories/
          teacher_repository.dart

      presentation/
        viewmodels/
          teacher_profile_viewmodel.dart

        pages/
          teacher_profile_page.dart
```

---

# 19. Rutas protegidas

Las rutas de:

* dashboard
* perfil
* aulas
* estudiantes
* ejercicios
* evaluaciones
* resultados

deben requerir sesión autenticada.

Si no existe sesión válida:

* redirigir a login

Si el estado aún es `unknown` o inicializando:

* mostrar loading
* no decidir todavía

No confiar solo en que el usuario llegó desde login.

---

# 20. Dashboard

Después de obtener el perfil:

* reemplazar saludo mock `Hola, Docente`
* usar el nombre real

Ejemplo:

```text
Hola, Joseph
```

La pantalla de perfil debe mostrar:

* nombre real
* apellido real
* email real
* institución real
* teléfono real

Eliminar datos mock del docente en estas pantallas.

Los demás módulos pueden seguir mockeados por ahora.

---

# 21. Errores

Mapear errores de forma centralizada.

Casos:

* 400: request inválido
* 401: token inválido o credenciales incorrectas
* 403: sesión no autorizada
* 404: recurso no encontrado
* 409: conflicto, por ejemplo correo duplicado
* 422: errores de validación
* 429: demasiadas solicitudes
* 500+: error del servidor
* timeout
* sin conexión
* respuesta inesperada

No mostrar:

* stack trace
* JSON crudo
* HTML
* access token
* refresh token
* URL interna

Mensajes amigables sugeridos:

```text
Correo o contraseña incorrectos.
La sesión expiró. Inicia sesión nuevamente.
No se pudo conectar con el servidor.
El servidor tardó demasiado en responder.
El correo ya se encuentra registrado.
Revisa los campos ingresados.
Ocurrió un error inesperado.
```

---

# 22. Logging seguro

En debug se puede registrar:

* método HTTP
* ruta
* status code
* duración

No registrar:

* password
* new_password
* access_token
* refresh_token
* reset token
* authorization header

Crear sanitización si el interceptor actual imprime bodies o headers.

---

# 23. Pruebas

Agregar pruebas unitarias usando mocks/fakes.

## AuthSessionStorage

* guarda y recupera sesión
* elimina sesión
* conserva `expiresAt`

## AuthSessionManager

* inicializa sin sesión
* inicializa con token válido
* refresca token expirado
* reemplaza refresh token después del refresh
* limpia sesión si refresh falla
* carga perfil después de signin
* limpia perfil al cerrar sesión

## Login

* signin exitoso
* guarda access token
* guarda refresh token
* guarda token type
* guarda expiresAt
* carga perfil
* navega al dashboard

## Refresh

* usa refresh token almacenado
* guarda los nuevos tokens
* no conserva refresh token anterior
* evita refresh simultáneos
* repite petición original una sola vez

## Signout

* llama backend
* limpia storage
* limpia currentTeacher
* cambia estado a unauthenticated

## Forgot password

* valida email
* muestra respuesta neutral

## Reset password

* valida token
* valida contraseñas
* envía `token` y `new_password`

## Perfil docente

* parsea `teacher_id`
* GET carga perfil
* PUT actualiza perfil global
* error 401 intenta refresh

Las pruebas no deben depender del backend real.

---

# 24. Verificación manual

Probar:

1. Crear cuenta con teléfono.
2. Iniciar sesión.
3. Confirmar que se almacenan:

    * access token
    * refresh token
    * token type
    * expiresAt
4. Confirmar que se ejecuta `GET /teachers/me`.
5. Confirmar que dashboard usa nombre real.
6. Confirmar que perfil muestra datos reales.
7. Editar perfil.
8. Confirmar actualización global.
9. Reiniciar app y restaurar sesión.
10. Simular token expirado.
11. Confirmar refresh automático.
12. Confirmar rotación del refresh token.
13. Cerrar sesión.
14. Confirmar que botón atrás no vuelve al dashboard.
15. Ejecutar forgot password.
16. Ejecutar reset password con token válido.
17. Confirmar manejo de token inválido o expirado.
18. Confirmar que no se imprimen tokens ni contraseñas.

---

# 25. Restricciones

* No guardar contraseñas.
* No guardar tokens en SharedPreferences.
* No exponer tokens en logs.
* No usar variables globales mutables.
* No hacer HTTP desde páginas.
* No hacer HTTP directamente desde ViewModels.
* No crear refresh infinito.
* No ejecutar múltiples refresh simultáneos.
* No inventar responses.
* No inventar request bodies.
* No modificar backend.
* No refactorizar módulos no relacionados.
* No reemplazar todavía mocks de aulas, estudiantes o ejercicios.
* No cambiar el diseño visual general.

---

# 26. Criterios de aceptación

La implementación estará completa si:

1. Signin guarda correctamente toda la sesión.
2. Refresh renueva y reemplaza ambos tokens.
3. El access token se agrega automáticamente a endpoints protegidos.
4. Un 401 provoca un único refresh y reintento.
5. Si refresh falla, se limpia la sesión.
6. Signout invalida y limpia la sesión local.
7. Forgot password funciona con backend real.
8. Reset password funciona con backend real.
9. GET `/teachers/me` se ejecuta al autenticar.
10. El docente actual está disponible globalmente mediante un store controlado.
11. PUT `/teachers/me` actualiza el perfil y la UI.
12. Las rutas protegidas bloquean usuarios no autenticados.
13. La sesión se restaura al reiniciar la app.
14. No se guardan contraseñas.
15. No se imprimen tokens.
16. `flutter analyze` no presenta errores.
17. Las pruebas de auth y perfil pasan.

---

# 27. Entrega final

Al finalizar, explicar:

1. Archivos creados.
2. Archivos modificados.
3. Flujo de signin.
4. Flujo de refresh.
5. Cómo se evita refresh simultáneo.
6. Cómo se guarda la sesión.
7. Cómo se carga el perfil.
8. Cómo se actualiza el perfil global.
9. Cómo funciona signout.
10. Cómo se implementaron forgot y reset password.
11. Qué rutas quedaron protegidas.
12. Resultados de `flutter analyze`.
13. Resultados de tests.
14. Cualquier incompatibilidad detectada con Swagger.
