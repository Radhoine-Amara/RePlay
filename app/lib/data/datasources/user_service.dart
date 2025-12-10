import '../models/user_model.dart';
import 'supabase_service.dart';

class UserService {
  final _supabase = SupabaseService.client;

  // CREATE - Add new user
  Future<UserModel?> createUser(UserModel user) async {
    try {
      final response = await _supabase
          .from('users')
          .insert(user.toJson())
          .select()
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      print('Error creating user: $e');
      throw Exception('Database error: Unable to create user account. ${e.toString()}');
    }
  }

  // READ - Get all users
  Future<List<UserModel>> getAllUsers() async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .order('datecreated', ascending: false);

      return (response as List)
          .map((json) => UserModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching users: $e');
      return [];
    }
  }

  // READ - Get user by ID
  Future<UserModel?> getUserById(int userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('userid', userId)
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      print('Error fetching user: $e');
      return null;
    }
  }

  // READ - Get user by email
  Future<UserModel?> getUserByEmail(String email) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('email', email.toLowerCase().trim())
          .maybeSingle();

      if (response == null) {
        print('No user found for email: $email');
        return null;
      }
      return UserModel.fromJson(response);
    } catch (e) {
      print('Error fetching user by email: $e');
      return null;
    }
  }

  // UPDATE - Update user
  Future<bool> updateUser(int userId, Map<String, dynamic> updates) async {
    try {
      await _supabase.from('users').update(updates).eq('userid', userId);

      return true;
    } catch (e) {
      print('Error updating user: $e');
      return false;
    }
  }

  // DELETE - Delete user
  Future<bool> deleteUser(int userId) async {
    try {
      await _supabase.from('users').delete().eq('userid', userId);

      return true;
    } catch (e) {
      print('Error deleting user: $e');
      return false;
    }
  }
}
