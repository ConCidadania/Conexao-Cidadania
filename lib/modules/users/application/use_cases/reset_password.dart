import '../../domain/services/auth_service.dart';
import '../../domain/value_objects/email_address.dart';
import '../../domain/errors/user_failures.dart';

class ResetPassword {
  final AuthService _authService;

  ResetPassword(this._authService);

  Future<void> call({
    required String email,
  }) async {
    try {
      final emailAddress = EmailAddress.parse(email);
      await _authService.resetPassword(emailAddress);
    } catch (e) {
      if (e is UserFailure) rethrow;
      throw UseCaseFailure('Failed to reset password: ${e.toString()}');
    }
  }
}
