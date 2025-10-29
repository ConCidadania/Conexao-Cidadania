import '../../domain/entities/app_user.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/services/auth_service.dart';
import '../../domain/errors/user_failures.dart';

class RegisterUser {
  final AuthService _authService;
  final UserRepository _userRepository;

  RegisterUser(this._authService, this._userRepository);

  Future<AppUser> call({
    required AppUser userData,
    required String password,
  }) async {
    try {
      // Register user in authentication system
      final userId = await _authService.register(userData.email, password);
      
      // Create user with the returned ID
      final user = userData.copyWith(id: userId);
      
      // Save user data to repository
      return await _userRepository.create(user);
    } catch (e) {
      if (e is UserFailure) rethrow;
      throw UseCaseFailure('Failed to register user: ${e.toString()}');
    }
  }
}
