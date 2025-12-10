import '../models/user_model.dart';
import 'supabase_service.dart';

class UserService {
  final _supabase = SupabaseService.client;

  // CREATE - Add new user
  Future<UserModel?> createUser(UserModel user) async {
    try {
      print('Creating user with data: ${user.toJson()}');
      
      final response = await _supabase
          .from('users')
          .insert(user.toJson())
          .select();

      if (response.isEmpty) {
        throw Exception('No response from database after insert');
      }

      print('User created successfully with response: ${response.first}');
      // ignore: unnecessary_cast
      return UserModel.fromJson(response.first as Map<String, dynamic>);
    } catch (e) {
      print('Error creating user: $e');
      print('Error type: ${e.runtimeType}');
      if (e.toString().contains('duplicate key') || e.toString().contains('unique')) {
        throw Exception('Email already registered. Please try a different email.');
      } else if (e.toString().contains('not') && e.toString().contains('insert')) {
        throw Exception('You do not have permission to create an account. Please contact support.');
      } else {
        throw Exception('Unable to create account: ${e.toString()}');
      }
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
