import '../../domain/entities/app_user.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/services/auth_service.dart';
import '../../domain/errors/user_failures.dart';

class GetCurrentUser {
  final AuthService _authService;
  final UserRepository _userRepository;

  GetCurrentUser(this._authService, this._userRepository);

  Future<AppUser?> call() async {
    try {
      final userId = _authService.currentUserId();
      if (userId == null) {
        return null;
      }

      return await _userRepository.findByUid(userId);
    } catch (e) {
      if (e is UserFailure) rethrow;
      throw UseCaseFailure('Failed to get current user: ${e.toString()}');
    }
  }
}
