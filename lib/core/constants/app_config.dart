import 'api_keys.dart';

class AppConfig {
  // Supabase (publishable / anon — safe in client)
  static final String supabaseUrl = ApiKeys.supabaseUrl;
  static final String supabaseAnonKey = ApiKeys.supabaseAnonKey;

  // AI keys (all Gemini — Groq fully removed)
  static final String geminiApiKey = ApiKeys.geminiApiKey;
  // Separate Gemini key dedicated to the BMI meal-suggestion feature.
  static final String geminiBmiApiKey = ApiKeys.geminiBmiApiKey;

  // App Info
  static const String appName = 'FoodIQ';
  static const String appVersion = '2.0.0';
  static const String appTagline = 'Smart Ethiopian Calorie Tracking with AI';

  // Default Goals
  static const int defaultCalorieGoal = 2000;
  static const int defaultWaterGoal = 2000;
  static const double mlPerGlass = 250.0;

  // Premium
  static const double premiumPrice = 200.0;
  static const String premiumCurrency = 'ETB';

  // AI Models
  /// Gemini text model used for BMI meal suggestions (uses geminiBmiApiKey).
  static const String geminiBmiModel = 'gemini-2.5-flash-lite';

  /// Gemini text/chat model for the AI Assistant.
  ///
  /// The AI Assistant now runs on Gemini (instead of Groq) so it works
  /// reliably and speaks fluent Amharic. The *-lite variant has the highest
  /// free-tier quota (high RPM/RPD), with a fallback chain below.
  static const String geminiChatModel = 'gemini-2.5-flash-lite';

  /// Fallback chain for the text assistant — tried in order on 429/quota
  /// errors. Highest free-tier quota first.
  static const List<String> geminiChatFallbacks = [
    'gemini-2.5-flash-lite',
    'gemini-flash-lite-latest',
    'gemini-2.0-flash-lite',
    'gemini-2.5-flash',
    'gemini-2.0-flash',
  ];

  /// Primary Gemini vision model — the *-lite variants have much higher
  /// free-tier quotas (30 RPM, 1,500 RPD) compared to flash (15 RPM, 200 RPD).
  static const String geminiVisionModel = 'gemini-2.5-flash-lite';

  /// Fallback chain — tried in order if the primary model returns 429
  /// (quota / rate-limit). Each entry is a model name that supports vision.
  /// Order matters: highest free-tier quota first.
  static const List<String> geminiVisionFallbacks = [
    'gemini-2.5-flash-lite',
    'gemini-flash-lite-latest',
    'gemini-2.0-flash-lite',
    'gemini-2.0-flash',
    'gemini-2.5-flash',
  ];

  // Notification Channels
  static const String mealReminderChannelId = 'foodiq_meal_reminder';
  static const String mealReminderChannelName = 'Meal Reminders';

  // Default Reminder Times
  static const String defaultBreakfastTime = '08:00';
  static const String defaultLunchTime = '12:30';
  static const String defaultDinnerTime = '19:00';
}
