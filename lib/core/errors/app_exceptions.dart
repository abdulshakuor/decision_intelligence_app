class AppException implements Exception {
  final String message;
  final String? prefix;

  AppException(this.message, [this.prefix]);

  @override
  String toString() => '${prefix ?? ""}$message';
}

class ApiException extends AppException {
  final int? statusCode;
  ApiException(String message, [this.statusCode])
    : super(message, "API Error: ");
}

class NetworkException extends AppException {
  NetworkException(String message) : super(message, "Network Error: ");
}

class AuthException extends AppException {
  AuthException(String message) : super(message, "Authentication Error: ");
}

class ValidationException extends AppException {
  ValidationException(String message) : super(message, "Validation Error: ");
}
