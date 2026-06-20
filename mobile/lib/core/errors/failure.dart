sealed class Failure {
  const Failure(this.message);
  final String message;
}

final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection.']);
}

final class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error. Please try again.']);
}

final class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication failed.']);
}

final class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {this.errors});
  final Map<String, List<String>>? errors;
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Resource not found.']);
}
