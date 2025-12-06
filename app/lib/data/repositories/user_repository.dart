import 'dart:io';
import '../datasources/user_service.dart';
import '../datasources/supabase_service.dart';
import '../models/user_model.dart';

/// Repository that abstracts user profile operations.
class UserRepository {
  final UserService _userService;

  UserRepository({UserService? userService})
    : _userService = userService ?? UserService();

  /// Create a new user in the database.
  Future<UserModel?> createUser(UserModel user) async {
    return await _userService.createUser(user);
  }

  /// Get all users from the database.
  Future<List<UserModel>> getAllUsers() async {
    return await _userService.getAllUsers();
  }

  /// Get a user by their ID.
  Future<UserModel?> getUserById(int userId) async {
    return await _userService.getUserById(userId);
  }

  /// Get a user by their email.
  Future<UserModel?> getUserByEmail(String email) async {
    return await _userService.getUserByEmail(email);
  }

  /// Update user profile.
  Future<bool> updateUser(int userId, Map<String, dynamic> updates) async {
    return await _userService.updateUser(userId, updates);
  }

  /// Delete a user.
  Future<bool> deleteUser(int userId) async {
    return await _userService.deleteUser(userId);
  }

  /// Upload a profile image to Supabase Storage.
  /// Returns the public URL of the uploaded image.
  Future<String?> uploadProfileImage(File imageFile, int userId) async {
    try {
      final fileName =
          'profile_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = 'profiles/$fileName';

      await SupabaseService.client.storage
          .from('profile-images')
          .upload(filePath, imageFile);

      final publicUrl = SupabaseService.client.storage
          .from('profile-images')
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      print('Error uploading profile image: $e');
      return null;
    }
  }
}
