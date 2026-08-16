import 'package:dio/dio.dart';

import 'api_exception.dart';

abstract final class ApiErrorMapper {
  static ApiException map(Object error) {
    if (error is ApiException) {
      return error;
    }
    if (error is! DioException) {
      return const UnknownApiException(
        'No se pudo completar la solicitud. Inténtalo nuevamente.',
      );
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiTimeoutException(
          'El servidor tardó demasiado en responder.',
        );
      case DioExceptionType.connectionError:
        return const NetworkException('No se pudo conectar con el servidor.');
      case DioExceptionType.badResponse:
        return _mapStatus(error.response);
      case DioExceptionType.cancel:
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return const UnknownApiException(
          'No se pudo completar la solicitud. Inténtalo nuevamente.',
        );
    }
  }

  static ApiException _mapStatus(Response<dynamic>? response) {
    final statusCode = response?.statusCode;
    final data = response?.data;
    final backendMessage = _extractMessage(data);
    final path = response?.requestOptions.path ?? '';
    final isClassroomRequest =
        path.contains('/classrooms') && !path.contains('/students');
    final isStudentRequest =
        path.contains('/students') && !path.contains('/consent');

    if (statusCode == 400) {
      return ValidationException(
        backendMessage ?? 'Revisa los datos ingresados.',
        fieldErrors: _extractFieldErrors(data),
      );
    }
    if (statusCode == 401) {
      if (path.endsWith('/auth/signin')) {
        return const UnauthorizedException('Correo o contraseña incorrectos.');
      }
      if (path.endsWith('/auth/reset-password')) {
        return const UnauthorizedException(
          'El enlace de recuperación no es válido o ha expirado.',
        );
      }
      return const UnauthorizedException(
        'La sesión expiró. Inicia sesión nuevamente.',
      );
    }
    if (statusCode == 403) {
      return const ForbiddenException(
        'La sesión expiró. Inicia sesión nuevamente.',
      );
    }
    if (statusCode == 404) {
      if (isClassroomRequest) {
        return const NotFoundException('El aula no fue encontrada.');
      }
      if (isStudentRequest) {
        return const NotFoundException('El estudiante no fue encontrado.');
      }
      return NotFoundException(
        backendMessage ?? 'No se encontró el recurso solicitado.',
      );
    }
    if (statusCode == 409) {
      if (isClassroomRequest) {
        return const ConflictException('Ya existe un aula con esos datos.');
      }
      if (isStudentRequest) {
        return const ConflictException(
          'Ya existe un estudiante con ese código.',
        );
      }
      return const ConflictException('El correo ya se encuentra registrado.');
    }
    if (statusCode == 422) {
      return ValidationException(
        backendMessage ?? 'Revisa los datos ingresados.',
        fieldErrors: _extractFieldErrors(data),
      );
    }
    if (statusCode == 429) {
      return const TooManyRequestsException(
        'Demasiadas solicitudes. Inténtalo nuevamente en unos minutos.',
      );
    }
    if (statusCode != null && statusCode >= 500) {
      return const ServerException(
        'Ocurrió un error en el servidor. Inténtalo nuevamente.',
      );
    }
    return const UnknownApiException(
      'No se pudo completar la solicitud. Inténtalo nuevamente.',
    );
  }

  static String? _extractMessage(dynamic data) {
    if (data is! Map<String, dynamic>) {
      return null;
    }
    final detail = data['detail'];
    if (detail is String && detail.trim().isNotEmpty) {
      return detail.trim();
    }
    if (detail is List && detail.isNotEmpty) {
      final first = detail.first;
      if (first is Map<String, dynamic>) {
        final message = first['msg'];
        if (message is String && message.trim().isNotEmpty) {
          return message.trim();
        }
      }
    }
    return null;
  }

  static Map<String, String> _extractFieldErrors(dynamic data) {
    if (data is! Map<String, dynamic>) {
      return const {};
    }
    final detail = data['detail'];
    if (detail is! List) {
      return const {};
    }

    final errors = <String, String>{};
    for (final item in detail) {
      if (item is! Map<String, dynamic>) {
        continue;
      }
      final loc = item['loc'];
      final message = item['msg'];
      if (loc is List && loc.isNotEmpty && message is String) {
        final field = loc.last.toString();
        errors[field] = _friendlyValidationMessage(field, message);
      }
    }
    return errors;
  }

  static String _friendlyValidationMessage(String field, String message) {
    if (field == 'email') {
      return 'Ingresa un correo electrónico válido.';
    }
    if ((field == 'password' || field == 'new_password') &&
        message.contains('at least 8')) {
      return 'La contraseña debe tener como mínimo 8 caracteres.';
    }
    if (message.trim().isEmpty) {
      return 'Revisa este campo.';
    }
    return message;
  }
}
