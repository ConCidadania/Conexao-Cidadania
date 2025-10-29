import '../../domain/services/auth_service.dart';
import '../../domain/errors/user_failures.dart';

class LogoutUser {
  final AuthService _authService;

  LogoutUser(this._authService);

  Future<void> call() async {
    try {
      await _authService.logout();
    } catch (e) {
      if (e is UserFailure) rethrow;
      throw UseCaseFailure('Failed to logout user: ${e.toString()}');
    }
  }
}
