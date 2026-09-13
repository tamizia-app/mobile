class ApiException implements Exception {
  const ApiException(this.message, {this.fieldErrors = const {}});

  final String message;
  final Map<String, String> fieldErrors;
}

class NetworkException extends ApiException {
  const NetworkException(super.message);
}

class ApiTimeoutException extends ApiException {
  const ApiTimeoutException(super.message);
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException(super.message);
}

class ForbiddenException extends ApiException {
  const ForbiddenException(super.message);
}

class NotFoundException extends ApiException {
  const NotFoundException(super.message);
}

class TooManyRequestsException extends ApiException {
  const TooManyRequestsException(super.message);
}

class ValidationException extends ApiException {
  const ValidationException(super.message, {super.fieldErrors});
}

class ConflictException extends ApiException {
  const ConflictException(super.message);
}

class ServerException extends ApiException {
  const ServerException(super.message);
}

class UnknownApiException extends ApiException {
  const UnknownApiException(super.message);
}
