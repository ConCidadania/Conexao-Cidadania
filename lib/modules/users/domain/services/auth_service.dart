import '../value_objects/user_id.dart';
import '../value_objects/email_address.dart';

abstract class AuthService {
  Future<UserId> register(EmailAddress email, String password);
  Future<UserId> login(EmailAddress email, String password);
  Future<void> resetPassword(EmailAddress email);
  Future<void> logout();
  UserId? currentUserId();
  Future<bool> isLoggedIn();
}
