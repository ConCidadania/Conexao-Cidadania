import 'package:firebase_auth/firebase_auth.dart' as auth;

import '../../domain/services/auth_service.dart';
import '../../domain/value_objects/email_address.dart';
import '../../domain/value_objects/user_id.dart';
import '../../domain/errors/user_failures.dart';

class FirebaseAuthService implements AuthService {
  final auth.FirebaseAuth _auth;

  FirebaseAuthService({auth.FirebaseAuth? firebaseAuth})
      : _auth = firebaseAuth ?? auth.FirebaseAuth.instance;

  @override
  Future<UserId> register(EmailAddress email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.value,
        password: password,
      );
      final uid = credential.user?.uid;
      if (uid == null || uid.isEmpty) {
        throw const AuthenticationFailure('Failed to retrieve user id after registration');
      }
      return UserId.fromString(uid);
    } on auth.FirebaseAuthException catch (e) {
      throw _mapAuthException(e);
    } catch (e) {
      throw AuthenticationFailure('Registration failed: ${e.toString()}');
    }
  }

  @override
  Future<UserId> login(EmailAddress email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.value,
        password: password,
      );
      final uid = credential.user?.uid;
      if (uid == null || uid.isEmpty) {
        throw const AuthenticationFailure('Failed to retrieve user id after login');
      }
      return UserId.fromString(uid);
    } on auth.FirebaseAuthException catch (e) {
      throw _mapAuthException(e);
    } catch (e) {
      throw AuthenticationFailure('Login failed: ${e.toString()}');
    }
  }

  @override
  Future<void> resetPassword(EmailAddress email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.value);
    } on auth.FirebaseAuthException catch (e) {
      throw _mapAuthException(e);
    } catch (e) {
      throw AuthenticationFailure('Password reset failed: ${e.toString()}');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } on auth.FirebaseAuthException catch (e) {
      throw _mapAuthException(e);
    } catch (e) {
      throw AuthenticationFailure('Logout failed: ${e.toString()}');
    }
  }

  @override
  UserId? currentUserId() {
    final user = _auth.currentUser;
    if (user == null || user.uid.isEmpty) return null;
    try {
      return UserId.fromString(user.uid);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    return _auth.currentUser != null;
  }

  UserFailure _mapAuthException(auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return const UserNotFoundFailure('Usuário não encontrado.');
      case 'wrong-password':
        return const AuthenticationFailure('Senha incorreta.');
      case 'email-already-in-use':
        return const UserAlreadyExistsFailure('Este e-mail já está em uso.');
      case 'weak-password':
        return const AuthenticationFailure('A senha é muito fraca.');
      case 'invalid-email':
        return const AuthenticationFailure('E-mail inválido.');
      default:
        return AuthenticationFailure('Erro de autenticação: ${e.code}');
    }
  }
}


