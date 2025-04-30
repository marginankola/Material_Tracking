import 'package:firebase_auth/firebase_auth.dart';
import 'package:material_tracking/features/auth/domain/models/user_model.dart';

abstract class AuthRepository {
  Stream<UserModel?> get authStateChanges;
  Future<UserModel?> getCurrentUser();
  Future<UserModel> signInWithEmailAndPassword(String email, String password);
  Future<void> signOut();
  Future<UserModel> createUser(
    String email,
    String password,
    String name,
    UserRole role,
  );
  Future<void> deleteUser(String userId);
  Future<void> updateUserRole(String userId, UserRole newRole);
  Future<List<UserModel>> getAllUsers();
}
