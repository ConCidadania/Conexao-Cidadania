import '../entities/app_user.dart';
import '../value_objects/user_id.dart';

abstract class UserRepository {
  Future<AppUser> create(AppUser user);
  Future<void> update(UserId id, AppUser user);
  Future<AppUser?> findByUid(UserId id);
  Stream<List<AppUser>> fetchAll({String orderBy = 'createdAt'});
  Future<void> delete(UserId id);
}
