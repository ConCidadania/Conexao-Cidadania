import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/app_user.dart';
import '../../domain/errors/user_failures.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/value_objects/user_id.dart';
import '../mappers/app_user_mapper.dart';

class FirebaseUserRepository implements UserRepository {
  static const String _collectionName = 'users';

  final FirebaseFirestore _firestore;

  FirebaseUserRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(_collectionName);

  @override
  Future<AppUser> create(AppUser user) async {
    try {
      final data = AppUserMapper.toFirestore(user);
      await _collection.add(data);
      return user;
    } on FirebaseException catch (e) {
      throw RepositoryFailure('Failed to create user: ${e.message ?? e.code}');
    } catch (e) {
      throw RepositoryFailure('Failed to create user: ${e.toString()}');
    }
  }

  @override
  Future<void> update(UserId id, AppUser user) async {
    try {
      final docId = await _findDocumentIdByUid(id);
      final updated = user.copyWith(updatedAt: DateTime.now());
      await _collection.doc(docId).update(AppUserMapper.toFirestore(updated));
    } on FirebaseException catch (e) {
      throw RepositoryFailure('Failed to update user: ${e.message ?? e.code}');
    } catch (e) {
      throw RepositoryFailure('Failed to update user: ${e.toString()}');
    }
  }

  @override
  Future<AppUser?> findByUid(UserId id) async {
    try {
      final snapshot = await _collection.where('uid', isEqualTo: id.value).limit(1).get();
      if (snapshot.docs.isEmpty) return null;
      return AppUserMapper.fromFirestore(snapshot.docs.first);
    } on FirebaseException catch (e) {
      throw RepositoryFailure('Failed to find user: ${e.message ?? e.code}');
    } catch (e) {
      throw RepositoryFailure('Failed to find user: ${e.toString()}');
    }
  }

  @override
  Stream<List<AppUser>> fetchAll({String orderBy = 'createdAt'}) {
    try {
      final query = _collection.orderBy(orderBy);
      return query.snapshots().map((snapshot) =>
          snapshot.docs.map((d) => AppUserMapper.fromFirestore(d)).toList());
    } catch (e) {
      return Stream.error(RepositoryFailure('Failed to fetch users: ${e.toString()}'));
    }
  }

  @override
  Future<void> delete(UserId id) async {
    try {
      final docId = await _findDocumentIdByUid(id);
      await _collection.doc(docId).delete();
    } on FirebaseException catch (e) {
      throw RepositoryFailure('Failed to delete user: ${e.message ?? e.code}');
    } catch (e) {
      throw RepositoryFailure('Failed to delete user: ${e.toString()}');
    }
  }

  Future<String> _findDocumentIdByUid(UserId id) async {
    final snapshot = await _collection.where('uid', isEqualTo: id.value).limit(1).get();
    if (snapshot.docs.isEmpty) {
      throw const UserNotFoundFailure('Usuário não encontrado.');
    }
    return snapshot.docs.first.id;
  }
}


