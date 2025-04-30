import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:material_tracking/features/auth/domain/models/user_model.dart';
import 'package:material_tracking/features/auth/domain/repositories/auth_repository.dart';
import 'package:hive/hive.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  static const String usersBox = 'users';

  AuthRepositoryImpl({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<UserModel?> get authStateChanges =>
      _auth.authStateChanges().asyncMap((user) async {
        if (user == null) return null;
        final userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        if (!userDoc.exists) return null;
        return UserModel.fromJson({'id': userDoc.id, ...userDoc.data()!});
      });

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) return null;

      final userData = UserModel.fromJson({
        'id': doc.id,
        ...doc.data()!,
      });

      await _cacheUser(userData);
      return userData;
    } catch (e) {
      final box = Hive.box<Map>(usersBox);
      final cachedData = box.get(user.uid);
      if (cachedData == null) return null;

      return UserModel.fromJson(Map<String, dynamic>.from(cachedData));
    }
  }

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (credential.user == null) {
      throw Exception('Failed to login');
    }

    final doc =
        await _firestore.collection('users').doc(credential.user!.uid).get();

    if (!doc.exists) {
      throw Exception('User data not found');
    }

    final userData = UserModel.fromJson({
      'id': doc.id,
      ...doc.data()!,
    });

    await _cacheUser(userData);
    return userData;
  }

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (credential.user == null) {
      throw Exception('Failed to create user');
    }

    final user = UserModel(
      id: credential.user!.uid,
      name: name,
      email: email,
      role: UserRole.operator,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _firestore.collection('users').doc(user.id).set(user.toJson());

    await _cacheUser(user);
    return user;
  }

  @override
  Future<void> logout() async {
    await _auth.signOut();
    final box = Hive.box<Map>(usersBox);
    await box.clear();
  }

  @override
  Future<UserModel> updateProfile({
    required String name,
    String? password,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    if (password != null) {
      await user.updatePassword(password);
    }

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) {
      throw Exception('User data not found');
    }

    final updatedUser = UserModel.fromJson({
      'id': doc.id,
      ...doc.data()!,
    }).copyWith(
      name: name,
      updatedAt: DateTime.now(),
    );

    await _firestore
        .collection('users')
        .doc(user.uid)
        .update(updatedUser.toJson());

    await _cacheUser(updatedUser);
    return updatedUser;
  }

  @override
  Future<void> deleteUser(String id) async {
    await _firestore.collection('users').doc(id).delete();
    final box = Hive.box<Map>(usersBox);
    await box.delete(id);
  }

  @override
  Future<List<UserModel>> getAllUsers() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      final users = snapshot.docs
          .map((doc) => UserModel.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();

      final box = Hive.box<Map>(usersBox);
      await box.clear();
      await box.putAll({
        for (var user in users) user.id: user.toJson(),
      });

      return users;
    } catch (e) {
      final box = Hive.box<Map>(usersBox);
      return box.values
          .map((json) => UserModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    }
  }

  @override
  Future<void> updateUserRole(String id, UserRole role) async {
    await _firestore.collection('users').doc(id).update({
      'role': role.name,
      'updatedAt': DateTime.now().toIso8601String(),
    });

    final box = Hive.box<Map>(usersBox);
    final userData = box.get(id);
    if (userData != null) {
      final user = UserModel.fromJson(Map<String, dynamic>.from(userData));
      await _cacheUser(user.copyWith(
        role: role,
        updatedAt: DateTime.now(),
      ));
    }
  }

  Future<void> _cacheUser(UserModel user) async {
    final box = Hive.box<Map>(usersBox);
    await box.put(user.id, user.toJson());
  }
}
