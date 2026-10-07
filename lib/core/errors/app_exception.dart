class AppException implements Exception {
  const AppException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException([
    super.message = "Check your connection and try again.",
  ]);
}

class AuthException extends AppException {
  const AuthException(super.message);
}

class PermissionException extends AppException {
  const PermissionException([super.message = 'You do not have permission to do that.']);
}
