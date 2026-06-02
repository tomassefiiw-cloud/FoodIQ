import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'main.dart'; // for AppLifecycleNotifier
import 'screens/auth/login_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'providers/auth_provider.dart';

class FoodIQApp extends ConsumerStatefulWidget {
  const FoodIQApp({super.key});

  @override
  ConsumerState<FoodIQApp> createState() => _FoodIQAppState();
}

class _FoodIQAppState extends ConsumerState<FoodIQApp> with WidgetsBindingObserver {
  late final AppLifecycleNotifier _lifecycleNotifier;

  @override
  void initState() {
    super.initState();
    // Register lifecycle observer to re-schedule notifications on resume
    _lifecycleNotifier = AppLifecycleNotifier();
    WidgetsBinding.instance.addObserver(_lifecycleNotifier);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_lifecycleNotifier);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final darkMode = ref.watch(darkModeProvider);

    return MaterialApp(
      title: 'FoodIQ',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
      home: _getHomeScreen(authState),
    );
  }

  Widget _getHomeScreen(AuthState authState) {
    if (authState is AuthAuthenticated) return const DashboardScreen();
    if (authState is AuthUnauthenticated) return const AuthGate();
    return const SplashScreen();
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Theme.of(context).primaryColor, const Color(0xFFFF8C5A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.restaurant_menu, size: 80, color: Colors.white.withOpacity(0.9)),
              const SizedBox(height: 20),
              const Text(
                'FoodIQ',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Smart Ethiopian Calorie Tracking with AI',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.85),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 40),
              const CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _showOnboarding = true;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _showOnboarding = !(prefs.getBool('onboarding_complete') ?? false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showOnboarding) {
      return OnboardingScreen(onComplete: () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('onboarding_complete', true);
        setState(() => _showOnboarding = false);
      });
    }
    return const LoginScreen();
  }
}
