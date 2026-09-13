# Integración del backend de autenticación en Flutter

Necesito integrar el módulo AUTH de la aplicación Flutter TamizIA con el backend real, manteniendo la arquitectura MVVM y las buenas prácticas existentes.

## Endpoints disponibles

* `POST /api/v1/auth/signup`
* `POST /api/v1/auth/signin`

Backend local:

* Flutter Web/Desktop: `http://localhost:8000`
* Android Emulator: `http://10.0.2.2:8000`
* Dispositivo físico: utilizar la IP local de la computadora, nunca `localhost`

No hardcodear la URL completa dentro de páginas, widgets ni ViewModels.

---

## Alcance

Implementar únicamente:

1. Registro real de docente.
2. Inicio de sesión real.
3. Nuevo campo teléfono en el formulario de registro.
4. Manejo de loading, éxito y errores del backend.
5. Persistencia segura del token si el backend lo devuelve.
6. Navegación al dashboard después de iniciar sesión correctamente.

No modificar todavía:

* Recuperación de contraseña.
* Aulas.
* Estudiantes.
* Ejercicios.
* Perfil docente.
* Backend.
* Contrato de la API.
* Diseño visual general del Figma.

---

## Contrato de registro

Endpoint:

```http
POST /api/v1/auth/signup
Content-Type: application/json
```

Request body:

```json
{
  "name": "string",
  "lastname": "string",
  "email": "user@example.com",
  "password": "string",
  "institute_name": "string",
  "phone": "string"
}
```

Mapeo desde la interfaz:

* Nombres → `name`
* Apellidos → `lastname`
* Correo Electrónico → `email`
* Contraseña → `password`
* Institución Educativa → `institute_name`
* Teléfono → `phone`

`confirmPassword` y `acceptedTerms` solo se validan en frontend y no deben enviarse al backend, salvo que el contrato real indique lo contrario.

Antes de implementar los modelos de respuesta, revisar en Swagger el schema exacto de las respuestas exitosas y de error. No inventar propiedades como `token`, `user`, `message` o `refresh_token` sin comprobar el contrato real.

---

## Contrato de inicio de sesión

Endpoint:

```http
POST /api/v1/auth/signin
Content-Type: application/json
```

Request body:

```json
{
  "email": "user@example.com",
  "password": "string"
}
```

Antes de implementar el parseo, revisar en Swagger la respuesta real del endpoint y modelarla exactamente.

---

## Campo nuevo de teléfono

Agregar en la pantalla `Crear cuenta docente`, preferiblemente después del correo electrónico o después de institución educativa, respetando el diseño existente.

Label:

```text
Teléfono *
```

Placeholder:

```text
Ejemplo: 987654321
```

Configuración Flutter:

* `keyboardType: TextInputType.phone`
* Permitir números y, si el backend lo admite, el prefijo `+`.
* Aplicar `TextInputFormatter` apropiado.
* No permitir letras.
* Mostrar error debajo del campo.

Validación mínima:

* Obligatorio.
* Remover espacios antes de validar.
* Aceptar entre 7 y 15 dígitos.
* Permitir opcionalmente `+` al inicio.
* No enviar espacios, guiones ni paréntesis al backend, salvo que la API documente otro formato.

Ejemplos válidos:

```text
987654321
+51987654321
```

Ejemplos inválidos:

```text
abc987
123
987 654 abc
```

---

## Arquitectura requerida

Mantener el flujo:

```text
Page
  -> ViewModel
    -> AuthRepository
      -> AuthRemoteDataSource
        -> HTTP API
```

No realizar peticiones HTTP directamente desde:

* páginas
* widgets
* formularios
* ViewModels

Los ViewModels deben depender de una abstracción, no de una implementación concreta de red.

Estructura sugerida:

```text
lib/
  core/
    config/
      environment.dart
      api_config.dart

    network/
      api_client.dart
      api_exception.dart
      api_error_mapper.dart

    storage/
      token_storage.dart
      secure_token_storage.dart

  features/
    auth/
      data/
        datasources/
          auth_remote_data_source.dart
          auth_remote_data_source_impl.dart

        models/
          signup_request_dto.dart
          signin_request_dto.dart
          auth_response_dto.dart
          api_error_response_dto.dart

        repositories/
          auth_repository_impl.dart

      domain/
        entities/
          authenticated_user.dart
          auth_session.dart

        repositories/
          auth_repository.dart

      presentation/
        viewmodels/
          login_viewmodel.dart
          register_viewmodel.dart

        pages/
          login_page.dart
          register_page.dart
```

Adaptar esta estructura a la que ya existe en el proyecto. No duplicar clases o carpetas si ya existe una arquitectura equivalente.

---

## Configuración de URL base

Crear una configuración centralizada.

Ejemplo conceptual:

```dart
abstract final class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );
}
```

No repetir la base URL en cada servicio.

Permitir ejecutar:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

Para dispositivo físico:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.X.X:8000
```

No usar la IP de ejemplo como valor definitivo sin verificar la IP real.

---

## Cliente HTTP

Usar la dependencia de red que ya tenga el proyecto.

Si no existe ninguna, usar una sola opción adecuada, por ejemplo `dio`, y centralizarla en `ApiClient`.

El cliente debe configurar:

* `baseUrl`
* `Content-Type: application/json`
* `Accept: application/json`
* timeout de conexión
* timeout de recepción
* serialización JSON
* manejo centralizado de errores
* interceptor para token, únicamente si ya existe token
* logging solo en modo debug
* nunca imprimir contraseñas, tokens ni datos sensibles

No crear una instancia nueva de Dio/http en cada petición.

---

## Requests y DTOs

Crear DTOs inmutables y con métodos `toJson()`.

### SignupRequestDto

Propiedades:

```text
name
lastname
email
password
instituteName
phone
```

El JSON debe usar exactamente:

```text
name
lastname
email
password
institute_name
phone
```

### SigninRequestDto

Propiedades:

```text
email
password
```

No enviar controladores, widgets ni objetos de UI a la capa de datos.

---

## AuthRepository

Contrato esperado, ajustándolo a la respuesta real del backend:

```dart
abstract interface class AuthRepository {
  Future<AuthSession> signUp(SignupRequest request);
  Future<AuthSession> signIn(SigninRequest request);
  Future<void> signOut();
}
```

Si `signup` no devuelve una sesión o token, adaptar su retorno al contrato real y navegar a login después del registro exitoso.

No asumir que signup inicia sesión automáticamente.

---

## AuthRemoteDataSource

Responsabilidades:

* Ejecutar `POST /api/v1/auth/signup`.
* Ejecutar `POST /api/v1/auth/signin`.
* Convertir request DTO a JSON.
* Parsear respuestas reales.
* Transformar errores HTTP en excepciones tipadas.
* No manejar navegación.
* No mostrar SnackBars.
* No depender de BuildContext.

---

## Registro

Actualizar `RegisterViewModel` para incluir:

```text
phone
isLoading
fieldErrors
generalError
```

Flujo:

1. Validar formulario local.
2. Impedir doble envío.
3. Activar loading.
4. Construir request.
5. Ejecutar `repository.signUp`.
6. Desactivar loading.
7. Mostrar confirmación.
8. Navegar según respuesta real:

    * Si signup crea la cuenta sin sesión: ir a login.
    * Si signup devuelve sesión válida: guardar token y navegar al dashboard.

Mientras carga:

* Deshabilitar botón `Registrarme`.
* Mostrar indicador de progreso dentro del botón.
* No permitir múltiples peticiones.

No limpiar el formulario si la petición falla.

---

## Inicio de sesión

Actualizar `LoginViewModel` para consumir `AuthRepository.signIn`.

Flujo:

1. Validar email y contraseña localmente.
2. Impedir doble envío.
3. Activar loading.
4. Enviar request.
5. Parsear respuesta.
6. Guardar token de forma segura si existe.
7. Navegar a `/teacher/home`.
8. Limpiar errores anteriores.

Mientras carga:

* Deshabilitar botón.
* Mostrar indicador de progreso.
* Evitar doble tap.

No guardar la contraseña.

---

## Persistencia segura de sesión

Si el backend devuelve access token:

* Usar `flutter_secure_storage`.
* No usar `SharedPreferences` para tokens.
* Crear abstracción `TokenStorage`.
* Implementar `SecureTokenStorage`.
* Guardar únicamente los valores necesarios.
* Eliminar tokens al cerrar sesión.

Ejemplo de contrato:

```dart
abstract interface class TokenStorage {
  Future<void> saveAccessToken(String token);
  Future<String?> readAccessToken();
  Future<void> clear();
}
```

Si el backend también devuelve refresh token, almacenarlo de forma segura, pero solo si está documentado en Swagger.

No inventar refresh token.

---

## Interceptor de autenticación

Si existe access token:

* Agregar automáticamente:

```http
Authorization: Bearer <token>
```

No agregar el token en signup ni signin.

No implementar todavía refresh automático si el backend no tiene endpoint documentado.

Ante `401` en módulos protegidos:

* Limpiar sesión.
* Redirigir a login mediante el mecanismo de navegación existente.
* No crear ciclos infinitos de reintento.

---

## Manejo de errores

Crear excepciones o errores tipados:

```text
NetworkException
TimeoutException
UnauthorizedException
ValidationException
ConflictException
ServerException
UnknownApiException
```

Mapeo recomendado:

* Sin conexión → `No se pudo conectar con el servidor.`
* Timeout → `El servidor tardó demasiado en responder.`
* 400 → mostrar mensaje del backend o validación general.
* 401 → `Correo o contraseña incorrectos.`
* 409 → `El correo ya se encuentra registrado.`
* 422 → mapear errores por campo si la respuesta los incluye.
* 500 o superior → `Ocurrió un error en el servidor. Inténtalo nuevamente.`
* Respuesta inesperada → mensaje genérico seguro.

Usar siempre el formato real de errores del backend. Inspeccionar Swagger y, si es necesario, ejecutar los endpoints para comprobar el cuerpo de error.

No mostrar al usuario:

* stack traces
* excepciones técnicas
* HTML
* JSON crudo
* URL interna
* tokens

---

## Validaciones del registro

Mantener las existentes y agregar teléfono:

* Nombres obligatorio.
* Apellidos obligatorio.
* Correo obligatorio y válido.
* Teléfono obligatorio y válido.
* Contraseña mínimo 8 caracteres.
* Confirmar contraseña debe coincidir.
* Términos y condiciones obligatorios.
* Institución según el contrato del backend.

Importante: Swagger muestra `institute_name` en el request. Por eso, confirmar si el backend lo exige realmente. Si es requerido, quitar el texto “Opcional” de la UI y validarlo como obligatorio. No enviar `null` si el backend espera un `string`.

---

## Desarrollo local Android

Revisar la configuración Android.

Para desarrollo con HTTP local:

```xml
<uses-permission android:name="android.permission.INTERNET" />
```

Si Android bloquea tráfico HTTP, permitir cleartext únicamente para desarrollo mediante una configuración segura de debug.

No debilitar permanentemente la configuración de release.

No usar `localhost` desde el emulador Android. Usar:

```text
http://10.0.2.2:8000
```

El backend debe escuchar en una interfaz accesible, por ejemplo:

```bash
uvicorn app.main:app --host 0.0.0.0 --port 8000
```

No modificar el backend salvo que sea necesario para permitir conexiones del dispositivo.

---

## CORS

Si se prueba Flutter Web, verificar que el backend permita el origen de desarrollo correspondiente.

No intentar resolver CORS desde Flutter.

No desactivar CORS globalmente de forma insegura en producción.

---

## Pruebas requeridas

Agregar o actualizar pruebas para:

### Validadores

* teléfono válido
* teléfono demasiado corto
* teléfono con letras
* teléfono con prefijo internacional
* contraseñas distintas
* email inválido

### DTOs

* `SignupRequestDto.toJson()` usa `institute_name`.
* No envía `confirmPassword`.
* No envía `acceptedTerms`.
* `SigninRequestDto.toJson()` contiene solo email y password.

### Repositorio/ViewModels

* signup exitoso
* signup con email duplicado
* signup con error de validación
* signin exitoso
* signin con credenciales incorrectas
* error de conexión
* loading se activa y desactiva
* se evita doble envío
* token se guarda después de signin exitoso

Usar mocks/fakes en tests. Los tests no deben depender del backend real.

---

## Verificación manual

Comprobar:

1. El registro muestra el nuevo campo teléfono.
2. El teléfono se valida correctamente.
3. El request signup contiene exactamente:

```json
{
  "name": "...",
  "lastname": "...",
  "email": "...",
  "password": "...",
  "institute_name": "...",
  "phone": "..."
}
```

4. `confirmPassword` no se envía.
5. `acceptedTerms` no se envía.
6. Signin envía únicamente email y password.
7. El loading evita múltiples peticiones.
8. Los errores del backend se muestran de forma amigable.
9. El token se guarda de forma segura si existe.
10. Login exitoso navega al dashboard.
11. Las pantallas anteriores conservan el diseño.
12. No quedan datos mockeados en el flujo de auth real.
13. Los demás módulos siguen utilizando sus mocks actuales.
14. `flutter analyze` no tiene errores.
15. Las pruebas nuevas pasan.

---

## Restricciones

* No modificar el backend.
* No inventar campos de respuesta.
* No inventar endpoints.
* No integrar Google Sign-In.
* No integrar Firebase.
* No implementar recuperación de contraseña.
* No guardar contraseñas.
* No imprimir tokens.
* No colocar lógica HTTP dentro de ViewModels o páginas.
* No romper las rutas existentes.
* No refactorizar módulos no relacionados.

---

## Resultado esperado

Al finalizar:

1. Explica qué archivos creaste y modificaste.
2. Indica la respuesta exacta observada para signup y signin.
3. Indica dónde se configura `API_BASE_URL`.
4. Explica cómo ejecutar en Android Emulator.
5. Explica cómo ejecutar en dispositivo físico.
6. Indica cómo se almacenan los tokens.
7. Menciona qué errores del backend fueron mapeados.
8. Ejecuta `flutter analyze`.
9. Ejecuta las pruebas relacionadas con auth.
10. Informa cualquier incompatibilidad real encontrada en el contrato de Swagger.
