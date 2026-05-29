import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'supabase_service.dart';

class AuthService {
  static const _uuid = Uuid();

  // Register with email and password
  static Future<UserModel?> register({
    required String name,
    required String email,
    required String password,
    int calorieGoal = 2000,
  }) async {
    try {
      // Sign up with Supabase Auth
      final authResponse = await SupabaseService.auth.signUp(
        email: email,
        password: password,
      );

      if (authResponse.user == null) return null;

      final userId = authResponse.user!.id;

      // Create profile in profiles table
      await SupabaseService.profiles.insert({
        'id': userId,
        'name': name,
        'email': email,
        'calorie_goal': calorieGoal,
        'water_goal': 2000,
        'is_premium': false,
        'age': 25,
        'weight': 70.0,
        'height': 170.0,
        'gender': 'Not specified',
      });

      // Create default user settings
      await SupabaseService.userSettings.insert({
        'user_id': userId,
        'dark_mode': false,
        'meal_reminders_enabled': false,
        'breakfast_time': '08:00',
        'lunch_time': '12:30',
        'dinner_time': '19:00',
        'onboarding_complete': false,
      });

      return UserModel(
        id: userId,
        name: name,
        email: email,
        calorieGoal: calorieGoal,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      rethrow;
    }
  }

  // Login with email and password
  static Future<UserModel?> login({
    required String email,
    required String password,
  }) async {
    try {
      final authResponse = await SupabaseService.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (authResponse.user == null) return null;

      return await getUserProfile(authResponse.user!.id);
    } catch (e) {
      rethrow;
    }
  }

  // Get user profile from Supabase
  static Future<UserModel?> getUserProfile(String userId) async {
    try {
      final response = await SupabaseService.profiles
          .select()
          .eq('id', userId)
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  // Update user profile
  static Future<bool> updateProfile(UserModel user) async {
    try {
      await SupabaseService.profiles.update({
        'name': user.name,
        'calorie_goal': user.calorieGoal,
        'water_goal': user.waterGoal,
        'is_premium': user.isPremium,
        'premium_expiry': user.premiumExpiry?.toIso8601String(),
        'age': user.age,
        'weight': user.weight,
        'height': user.height,
        'gender': user.gender,
      }).eq('id', user.id);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Logout
  static Future<void> logout() async {
    await SupabaseService.auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user_id');
  }

  // Delete account
  static Future<bool> deleteAccount(String userId) async {
    try {
      await SupabaseService.calorieLogs.delete().eq('user_id', userId);
      await SupabaseService.waterLogs.delete().eq('user_id', userId);
      await SupabaseService.customFoods.delete().eq('user_id', userId);
      await SupabaseService.userSettings.delete().eq('user_id', userId);
      await SupabaseService.profiles.delete().eq('id', userId);
      await SupabaseService.auth.signOut();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Hash password
  static String hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }
}
