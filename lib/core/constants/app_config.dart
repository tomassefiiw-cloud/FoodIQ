class AppConfig {
  // Supabase
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  
  // Gemini API (for food vision recognition)
  static const String geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');
  
  // Groq API (for AI nutrition assistant)
  static const String groqApiKey = String.fromEnvironment('GROQ_API_KEY');
  
  // App Info
  static const String appName = 'FoodIQ';
  static const String appVersion = '1.0.0';
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
  static const String geminiVisionModel = 'gemini-1.5-flash';
  
  // Notification Channels
  static const String mealReminderChannelId = 'foodiq_meal_reminder';
  static const String mealReminderChannelName = 'Meal Reminders';
  
  // Default Reminder Times
  static const String defaultBreakfastTime = '08:00';
  static const String defaultLunchTime = '12:30';
  static const String defaultDinnerTime = '19:00';
}
