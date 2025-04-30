import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:material_tracking/features/auth/domain/models/user_model.dart';
import 'package:material_tracking/features/auth/domain/repositories/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _usersCollection = 'users';

  @override
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final doc =
          await _firestore.collection(_usersCollection).doc(user.uid).get();
      if (!doc.exists) return null;

      return UserModel.fromJson({
        'id': doc.id,
        ...doc.data()!,
      });
    } on FirebaseException catch (e) {
      throw Exception('Failed to get current user: ${e.message}');
    }
  }

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw Exception('Failed to login');
      }

      final doc = await _firestore
          .collection(_usersCollection)
          .doc(credential.user!.uid)
          .get();

      if (!doc.exists) {
        throw Exception('User data not found');
      }

      return UserModel.fromJson({
        'id': doc.id,
        ...doc.data()!,
      });
    } on FirebaseException catch (e) {
      throw Exception('Failed to login: ${e.message}');
    }
  }

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
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

      await _firestore
          .collection(_usersCollection)
          .doc(user.id)
          .set(user.toJson());

      return user;
    } on FirebaseException catch (e) {
      throw Exception('Failed to register: ${e.message}');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } on FirebaseException catch (e) {
      throw Exception('Failed to logout: ${e.message}');
    }
  }

  @override
  Future<UserModel> updateProfile({
    required String name,
    String? password,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      if (password != null) {
        await user.updatePassword(password);
      }

      final doc =
          await _firestore.collection(_usersCollection).doc(user.uid).get();
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
          .collection(_usersCollection)
          .doc(user.uid)
          .update(updatedUser.toJson());

      return updatedUser;
    } on FirebaseException catch (e) {
      throw Exception('Failed to update profile: ${e.message}');
    }
  }

  @override
  Future<void> deleteUser(String id) async {
    try {
      await _firestore.collection(_usersCollection).doc(id).delete();
      await _auth.currentUser?.delete();
    } on FirebaseException catch (e) {
      throw Exception('Failed to delete user: ${e.message}');
    }
  }

  @override
  Future<List<UserModel>> getAllUsers() async {
    try {
      final snapshot = await _firestore.collection(_usersCollection).get();
      return snapshot.docs
          .map((doc) => UserModel.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    } on FirebaseException catch (e) {
      throw Exception('Failed to get users: ${e.message}');
    }
  }

  @override
  Future<void> updateUserRole(String id, UserRole role) async {
    try {
      await _firestore.collection(_usersCollection).doc(id).update({
        'role': role.name,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } on FirebaseException catch (e) {
      throw Exception('Failed to update user role: ${e.message}');
    }
  }
}
