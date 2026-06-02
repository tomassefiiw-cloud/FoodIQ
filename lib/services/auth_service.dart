import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import 'supabase_service.dart';

class AuthService {

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
        data: {
          'name': name,
          'calorie_goal': calorieGoal,
        },
      );

      if (authResponse.user == null) {
        throw Exception('Registration failed: No user returned');
      }

      final userId = authResponse.user!.id;

      // Check if we have an active session (email confirmation might be needed)
      final session = authResponse.session;
      final emailConfirmed = session != null;

      if (emailConfirmed) {
        // We have a session, create profile directly
        try {
          await _createUserProfile(userId, name, email, calorieGoal);
          await _createUserSettings(userId);
        } catch (e) {
          // Profile might already exist (trigger created it)
          // Try to fetch it instead
        }

        return UserModel(
          id: userId,
          name: name,
          email: email,
          calorieGoal: calorieGoal,
          createdAt: DateTime.now(),
        );
      } else {
        // Email confirmation required - try to sign in immediately
        // In some Supabase configs, auto-confirm is enabled
        // Try a workaround: sign in to see if it works
        try {
          final signInResponse = await SupabaseService.auth.signInWithPassword(
            email: email,
            password: password,
          );

          if (signInResponse.user != null) {
            // We can sign in, so create profile
            try {
              await _createUserProfile(userId, name, email, calorieGoal);
              await _createUserSettings(userId);
            } catch (e) {
              // Profile might already exist from trigger
            }

            return UserModel(
              id: userId,
              name: name,
              email: email,
              calorieGoal: calorieGoal,
              createdAt: DateTime.now(),
            );
          }
        } catch (signInError) {
          // Can't sign in - email confirmation is required
          // The database trigger should have created the profile
          // Check if profile exists (trigger might have created it)
        }

        // Try to fetch the profile that the trigger might have created
        try {
          final profile = await SupabaseService.profiles
              .select()
              .eq('id', userId)
              .single();
          return UserModel.fromJson(profile);
        } catch (e) {
          // Profile doesn't exist yet
        }

        // Email confirmation required - throw a helpful error
        throw Exception(
          'Registration successful! Please check your email ($email) to confirm your account, then sign in. '
          'If you don\'t see the email, check your spam folder.',
        );
      }
    } on AuthException catch (e) {
      // Handle Supabase auth-specific errors
      if (e.message.contains('already registered')) {
        throw Exception('This email is already registered. Try signing in instead.');
      }
      if (e.message.contains('invalid')) {
        throw Exception('Please enter a valid email address.');
      }
      if (e.message.contains('password')) {
        throw Exception('Password does not meet requirements. Use at least 6 characters.');
      }
      rethrow;
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Registration failed. Please try again.');
    }
  }

  // Helper: Create user profile
  static Future<void> _createUserProfile(String userId, String name, String email, int calorieGoal) async {
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
  }

  // Helper: Create user settings
  static Future<void> _createUserSettings(String userId) async {
    await SupabaseService.userSettings.insert({
      'user_id': userId,
      'dark_mode': false,
      'meal_reminders_enabled': false,
      'breakfast_time': '08:00',
      'lunch_time': '12:30',
      'dinner_time': '19:00',
      'onboarding_complete': false,
    });
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

      final userId = authResponse.user!.id;

      // Try to get profile
      var profile = await getUserProfile(userId);

      // If profile doesn't exist, create it (might happen if trigger didn't run)
      if (profile == null) {
        try {
          final userName = authResponse.user?.userMetadata?['name'] ?? email.split('@')[0];
          final calorieGoal = authResponse.user?.userMetadata?['calorie_goal'] ?? 2000;
          await _createUserProfile(userId, userName, email, calorieGoal is int ? calorieGoal : int.tryParse(calorieGoal.toString()) ?? 2000);
          await _createUserSettings(userId);
          profile = await getUserProfile(userId);
        } catch (e) {
          // Profile creation might fail, return a basic model
        }
      }

      return profile ?? UserModel(
        id: userId,
        name: authResponse.user?.userMetadata?['name'] ?? email.split('@')[0],
        email: email,
        createdAt: DateTime.now(),
      );
    } on AuthException catch (e) {
      if (e.message.contains('Email not confirmed')) {
        throw Exception('Please confirm your email address first. Check your inbox and spam folder for the confirmation link.');
      }
      if (e.message.contains('Invalid login credentials')) {
        throw Exception('Invalid email or password. Please try again.');
      }
      rethrow;
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Login failed. Please try again.');
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

  // Password reset
  static Future<bool> resetPassword(String email) async {
    try {
      await SupabaseService.auth.resetPasswordForEmail(email);
      return true;
    } catch (e) {
      return false;
    }
  }
}
