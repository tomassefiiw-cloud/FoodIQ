import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/supabase_service.dart';

// ============================================================================
// Auth State
// ============================================================================
sealed class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthAuthenticated extends AuthState {
  final UserModel user;
  const AuthAuthenticated(this.user);
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

// ============================================================================
// Auth Notifier
// ============================================================================
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

  /// Register a new account.
  ///
  /// Per product flow: after a successful sign-up we DO NOT auto-enter the app.
  /// Instead we sign the user out (if a session was created) and keep them
  /// unauthenticated, so the Register screen can redirect them to the Login
  /// page. They then log in with the same credentials and land on Home.
  Future<void> register(String name, String email, String password,
      {int calorieGoal = 2000}) async {
    final user = await AuthService.register(
      name: name,
      email: email,
      password: password,
      calorieGoal: calorieGoal,
    );
    if (user == null) {
      throw Exception('Registration failed');
    }
    // Ensure the account & profile are created, but don't keep the session —
    // the user must sign in from the Login page.
    try {
      await AuthService.logout();
    } catch (_) {/* ignore */}
    state = const AuthUnauthenticated();
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

// ============================================================================
// Dark Mode Provider — PERSISTENT (SharedPreferences-backed)
// ============================================================================
class DarkModeNotifier extends StateNotifier<bool> {
  DarkModeNotifier() : super(false) {
    _load();
  }

  static const _key = 'dark_mode_enabled';

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      state = prefs.getBool(_key) ?? false;
    } catch (_) {
      // ignore; default false
    }
  }

  Future<void> set(bool value) async {
    state = value;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_key, value);
    } catch (_) {/* ignore */}
  }

  Future<void> toggle() async => set(!state);
}

final darkModeProvider =
    StateNotifierProvider<DarkModeNotifier, bool>((ref) => DarkModeNotifier());

// ============================================================================
// Current User Provider
// ============================================================================
final currentUserProvider = Provider<UserModel?>((ref) {
  final authState = ref.watch(authProvider);
  if (authState is AuthAuthenticated) return authState.user;
  return null;
});
