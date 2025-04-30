import '../models/user_model.dart';

abstract class AuthRepository {
  Future<UserModel?> getCurrentUser();
  Future<UserModel> login({required String email, required String password});
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  });
  Future<void> logout();
  Future<UserModel> updateProfile({
    required String name,
    String? password,
  });
  Future<void> deleteUser(String id);
  Future<List<UserModel>> getAllUsers();
  Future<void> updateUserRole(String id, UserRole role);
}
