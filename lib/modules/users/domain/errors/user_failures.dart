// Base class for all user-related failures
abstract class UserFailure implements Exception {
  final String message;
  const UserFailure(this.message);
}

// Authentication failures
class AuthenticationFailure extends UserFailure {
  const AuthenticationFailure(super.message);
}

class UserNotFoundFailure extends UserFailure {
  const UserNotFoundFailure(super.message);
}

class UserAlreadyExistsFailure extends UserFailure {
  const UserAlreadyExistsFailure(super.message);
}

// Validation failures
class ValidationFailure extends UserFailure {
  const ValidationFailure(super.message);
}

// Repository failures
class RepositoryFailure extends UserFailure {
  const RepositoryFailure(super.message);
}

// Use case failures
class UseCaseFailure extends UserFailure {
  const UseCaseFailure(super.message);
}
