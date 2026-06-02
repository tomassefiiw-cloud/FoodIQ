import 'api_keys.dart';

class AppConfig {
  // Supabase - loaded from api_keys.dart (base64 encoded for security)
  static final String supabaseUrl = ApiKeys.supabaseUrl;
  static final String supabaseAnonKey = ApiKeys.supabaseAnonKey;
  
  // Gemini API - loaded from api_keys.dart
  static final String geminiApiKey = ApiKeys.geminiApiKey;
  
  // Groq API - loaded from api_keys.dart
  static final String groqApiKey = ApiKeys.groqApiKey;
  
  // App Info
  static const String appName = 'FoodIQ';
  static const String appVersion = '1.1.0';
  static const String appTagline = 'Smart Ethiopian Calorie Tracking with AI';
  
  // Default Goals
  static const int defaultCalorieGoal = 2000;
  static const int defaultWaterGoal = 2000;
  static const double mlPerGlass = 250.0;
  
  // Premium
  static const double premiumPrice = 200.0;
  static const String premiumCurrency = 'ETB';
  
  // AI Models
  static const String groqChatModel = 'llama-3.3-70b-versatile';
  static const String geminiVisionModel = 'gemini-2.0-flash';
  
  // Notification Channels
  static const String mealReminderChannelId = 'foodiq_meal_reminder';
  static const String mealReminderChannelName = 'Meal Reminders';
  
  // Default Reminder Times
  static const String defaultBreakfastTime = '08:00';
  static const String defaultLunchTime = '12:30';
  static const String defaultDinnerTime = '19:00';
}
