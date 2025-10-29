import '../../domain/entities/app_user.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/services/auth_service.dart';
import '../../domain/value_objects/email_address.dart';
import '../../domain/errors/user_failures.dart';

class LoginUser {
  final AuthService _authService;
  final UserRepository _userRepository;

  LoginUser(this._authService, this._userRepository);

  Future<AppUser> call({
    required String email,
    required String password,
  }) async {
    try {
      final emailAddress = EmailAddress.parse(email);
      
      // Authenticate user
      final userId = await _authService.login(emailAddress, password);
      
      // Get user data from repository
      final user = await _userRepository.findByUid(userId);
      if (user == null) {
        throw UserNotFoundFailure('User not found after authentication');
      }
      
      return user;
    } catch (e) {
      if (e is UserFailure) rethrow;
      throw UseCaseFailure('Failed to login user: ${e.toString()}');
    }
  }
}
