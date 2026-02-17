class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ConfigurationException extends AppException {
  const ConfigurationException(super.message);
}

class NetworkException extends AppException {
  const NetworkException(super.message);
}

class CorsException extends AppException {
  const CorsException(super.message);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException(super.message);
}

class ServerException extends AppException {
  const ServerException(super.message);
}

class UnknownException extends AppException {
  const UnknownException(super.message);
}

class ApiException extends AppException {
  const ApiException(super.message);
}

class NotFoundException extends AppException {
  const NotFoundException(super.message);
}

class ParsingException extends AppException {
  const ParsingException(super.message);
}
