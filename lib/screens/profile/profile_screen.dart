import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/calorie_provider.dart';
import '../assistant/assistant_screen.dart';
import '../settings/settings_screen.dart';
import '../bmi/bmi_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text('Profile', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppColors.orangeGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    width: 64, height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Center(
                      child: Text(
                        (user?.name ?? 'U')[0].toUpperCase(),
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user?.name ?? 'User', style: TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                        Text(user?.email ?? '', style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.white.withOpacity(0.8))),
                        if (user?.isPremiumActive ?? false) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(color: AppColors.warmGold, borderRadius: BorderRadius.circular(8)),
                            child: Text('⭐ Premium', style: TextStyle(fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Stats
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.restaurant, color: AppColors.primary, size: 28),
                        const SizedBox(height: 8),
                        Text('Tracking', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.grey)),
                        Text('Active', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, color: AppColors.success)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.local_fire_department, color: AppColors.primary, size: 28),
                        const SizedBox(height: 8),
                        Text('Goal', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.grey)),
                        Text('${user?.calorieGoal ?? 2000} kcal', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.water_drop, color: AppColors.waterBlue, size: 28),
                        const SizedBox(height: 8),
                        Text('Water Goal', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.grey)),
                        Text('${user?.waterGoal ?? 2000} ml', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Menu items
            _ProfileMenuItem(icon: Icons.person_outline, title: 'Edit Profile', subtitle: 'Update your personal information', onTap: () {}),
            _ProfileMenuItem(icon: Icons.monitor_weight, title: 'BMI Calculator', subtitle: 'Calculate BMI & get AI meal suggestions', color: AppColors.primary, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BMIScreen()))),
            _ProfileMenuItem(icon: Icons.smart_toy, title: 'AI Assistant', subtitle: 'Chat with our nutrition AI', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AssistantScreen()))),
            _ProfileMenuItem(icon: Icons.restaurant_menu, title: 'Custom Foods', subtitle: 'Manage your custom food items', onTap: () {}),
            _ProfileMenuItem(icon: Icons.workspace_premium, title: 'Premium', subtitle: 'Unlock all features', color: AppColors.warmGold, onTap: () {}),
            _ProfileMenuItem(icon: Icons.settings, title: 'Settings', subtitle: 'Goals, reminders, appearance', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()))),
            const SizedBox(height: 12),
            _ProfileMenuItem(icon: Icons.logout, title: 'Logout', subtitle: 'Sign out of your account', color: AppColors.error, onTap: () async {
              await ref.read(authProvider.notifier).logout();
            }),
            const SizedBox(height: 12),
            _ProfileMenuItem(icon: Icons.delete_forever, title: 'Delete Account', subtitle: 'Permanently remove your data', color: AppColors.error, onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text('Delete Account?', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
                  content: Text('This action is permanent and cannot be undone. All your data will be lost.', style: TextStyle(fontFamily: 'Poppins')),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: TextStyle(fontFamily: 'Poppins'))),
                    ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await ref.read(authProvider.notifier).logout();
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                      child: Text('Delete', style: TextStyle(fontFamily: 'Poppins', color: Colors.white)),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final Color? color;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = color ?? AppColors.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 15)),
                      Text(subtitle, style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.grey[400]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
