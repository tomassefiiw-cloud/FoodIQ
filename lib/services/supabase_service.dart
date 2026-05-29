import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants/app_config.dart';

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;
  
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
    );
  }
  
  // Auth shortcuts
  static GoTrueClient get auth => client.auth;
  static User? get currentUser => auth.currentUser;
  static String? get currentUserId => currentUser?.id;
  static bool get isAuthenticated => currentUser != null;
  
  // Table shortcuts
  static PostgrestQueryBuilder get profiles => client.from('profiles');
  static PostgrestQueryBuilder get calorieLogs => client.from('calorie_logs');
  static PostgrestQueryBuilder get waterLogs => client.from('water_logs');
  static PostgrestQueryBuilder get customFoods => client.from('custom_foods');
  static PostgrestQueryBuilder get userSettings => client.from('user_settings');
}
