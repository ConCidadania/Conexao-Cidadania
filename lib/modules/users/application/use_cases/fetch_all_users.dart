import '../../domain/entities/app_user.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/errors/user_failures.dart';

class FetchAllUsers {
  final UserRepository _userRepository;

  FetchAllUsers(this._userRepository);

  Stream<List<AppUser>> call({
    String orderBy = 'createdAt',
  }) {
    try {
      return _userRepository.fetchAll(orderBy: orderBy);
    } catch (e) {
      if (e is UserFailure) rethrow;
      throw UseCaseFailure('Failed to fetch users: ${e.toString()}');
    }
  }
}
