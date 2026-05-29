import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/supabase_service.dart';

// Auth State
sealed class AuthState {
  const AuthState();
}
class AuthInitial extends AuthState { const AuthInitial(); }
class AuthAuthenticated extends AuthState {
  final UserModel user;
  const AuthAuthenticated(this.user);
}
class AuthUnauthenticated extends AuthState { const AuthUnauthenticated(); }

// Auth Provider
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthInitial()) {
    _checkSession();
  }

  Future<void> _checkSession() async {
    final user = SupabaseService.currentUser;
    if (user != null) {
      final profile = await AuthService.getUserProfile(user.id);
      if (profile != null) {
        state = AuthAuthenticated(profile);
      } else {
        state = const AuthUnauthenticated();
      }
    } else {
      state = const AuthUnauthenticated();
    }
  }

  Future<void> login(String email, String password) async {
    final user = await AuthService.login(email: email, password: password);
    if (user != null) {
      state = AuthAuthenticated(user);
    } else {
      throw Exception('Login failed');
    }
  }

  Future<void> register(String name, String email, String password, {int calorieGoal = 2000}) async {
    final user = await AuthService.register(
      name: name,
      email: email,
      password: password,
      calorieGoal: calorieGoal,
    );
    if (user != null) {
      state = AuthAuthenticated(user);
    } else {
      throw Exception('Registration failed');
    }
  }

  Future<void> logout() async {
    await AuthService.logout();
    state = const AuthUnauthenticated();
  }

  Future<void> updateProfile(UserModel user) async {
    await AuthService.updateProfile(user);
    state = AuthAuthenticated(user);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

// Dark Mode Provider
final darkModeProvider = StateProvider<bool>((ref) {
  return false;
});

// Current User Provider
final currentUserProvider = Provider<UserModel?>((ref) {
  final authState = ref.watch(authProvider);
  if (authState is AuthAuthenticated) return authState.user;
  return null;
});
