import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../services/auth_service.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  double _calorieGoal = 2000;
  bool _isLoading = false;
  String? _error;
  String? _success;

  Future<void> _register() async {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() => _error = 'Please fill in all fields');
      return;
    }
    if (_passwordController.text.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters');
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _error = 'Passwords do not match');
      return;
    }
    if (!_emailController.text.contains('@') || !_emailController.text.contains('.')) {
      setState(() => _error = 'Please enter a valid email address');
      return;
    }

    setState(() { _isLoading = true; _error = null; _success = null; });

    try {
      await ref.read(authProvider.notifier).register(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
        calorieGoal: _calorieGoal.toInt(),
      );
      // Registration successful - the auth state change will navigate away
    } catch (e) {
      final errorMsg = e.toString().replaceFirst('Exception: ', '');
      
      // Check if the error is actually a success message (email confirmation)
      if (errorMsg.contains('Registration successful')) {
        setState(() {
          _success = errorMsg;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = errorMsg;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: AppColors.orangeGradient,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 6))],
                ),
                child: const Icon(Icons.person_add, size: 32, color: Colors.white),
              ),
              const SizedBox(height: 20),
              Text('Create Account', style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text('Join FoodIQ and start tracking your nutrition', style: GoogleFonts.poppins(fontSize: 15, color: Colors.grey)),
              const SizedBox(height: 28),

              // Error message
              if (_error != null)
                Container(
                  padding: const EdgeInsets.all(14),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.error.withOpacity(0.3)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(_error!, style: GoogleFonts.poppins(color: AppColors.error, fontSize: 13, height: 1.4)),
                      ),
                    ],
                  ),
                ),

              // Success message (email confirmation)
              if (_success != null)
                Container(
                  padding: const EdgeInsets.all(14),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.success.withOpacity(0.3)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_circle_outline, color: AppColors.success, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(_success!, style: GoogleFonts.poppins(color: AppColors.success, fontSize: 13, height: 1.4)),
                      ),
                    ],
                  ),
                ),

              // Name
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 14),
              // Email
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                  helperText: 'Use a real email you can access',
                ),
              ),
              const SizedBox(height: 14),
              // Password
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password (min 6 chars)',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
              const SizedBox(height: 14),
              // Confirm Password
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                onSubmitted: (_) => _register(),
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
              const SizedBox(height: 20),

              // Calorie Goal Slider
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primaryBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Daily Calorie Goal', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16)),
                        Text('${_calorieGoal.toInt()} kcal', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary)),
                      ],
                    ),
                    Slider(
                      value: _calorieGoal,
                      min: 1000,
                      max: 4000,
                      divisions: 30,
                      activeColor: AppColors.primary,
                      onChanged: (v) => setState(() => _calorieGoal = v),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('1000', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                        Text('4000', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Register Button
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 2,
                  ),
                  child: _isLoading
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text('Create Account', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 20),

              // Info note
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (isDark ? AppColors.darkCard : AppColors.cream),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 18, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'You may need to confirm your email before signing in.',
                        style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600], height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
