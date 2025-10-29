import '../../domain/entities/app_user.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/value_objects/user_id.dart';
import '../../domain/errors/user_failures.dart';

class EditUser {
  final UserRepository _userRepository;

  EditUser(this._userRepository);

  Future<AppUser> call({
    required UserId userId,
    required AppUser updatedUser,
  }) async {
    try {
      // Validate that the user exists
      final existingUser = await _userRepository.findByUid(userId);
      if (existingUser == null) {
        throw UserNotFoundFailure('User not found');
      }

      // Update user with new data, preserving the original ID and timestamps
      final userToUpdate = updatedUser.copyWith(
        id: userId,
        createdAt: existingUser.createdAt,
      );

      await _userRepository.update(userId, userToUpdate);
      return userToUpdate;
    } catch (e) {
      if (e is UserFailure) rethrow;
      throw UseCaseFailure('Failed to edit user: ${e.toString()}');
    }
  }
}
