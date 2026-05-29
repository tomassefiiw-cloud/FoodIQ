class AppStrings {
  // App
  static const String appName = 'FoodIQ';
  static const String tagline = 'Smart Ethiopian Calorie Tracking with AI';
  
  // Auth
  static const String login = 'Login';
  static const String register = 'Register';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String fullName = 'Full Name';
  static const String forgotPassword = 'Forgot Password?';
  static const String noAccount = "Don't have an account?";
  static const String hasAccount = 'Already have an account?';
  static const String signUp = 'Sign Up';
  static const String signIn = 'Sign In';
  static const String logout = 'Logout';
  static const String deleteAccount = 'Delete Account';
  
  // Navigation
  static const String home = 'Home';
  static const String analytics = 'Analytics';
  static const String camera = 'Camera';
  static const String profile = 'Profile';
  
  // Dashboard
  static const String calorieGoal = 'Calorie Goal';
  static const String consumed = 'Consumed';
  static const String remaining = 'Remaining';
  static const String macros = 'Macros';
  static const String protein = 'Protein';
  static const String carbs = 'Carbs';
  static const String fat = 'Fat';
  static const String fiber = 'Fiber';
  static const String waterTracker = 'Water Tracker';
  static const String todayMeals = "Today's Meals";
  static const String addMeal = 'Add Meal';
  
  // Meal Types
  static const String breakfast = 'Breakfast';
  static const String lunch = 'Lunch';
  static const String dinner = 'Dinner';
  static const String snack = 'Snack';
  
  // Food Log
  static const String ethiopian = 'Ethiopian';
  static const String common = 'Common';
  static const String custom = 'Custom';
  static const String searchFood = 'Search food...';
  static const String addCustomFood = 'Add Custom Food';
  static const String portionSize = 'Portion Size';
  
  // AI
  static const String aiAssistant = 'AI Assistant';
  static const String aiScanning = 'AI is analyzing...';
  static const String askNutrition = 'Ask me about nutrition...';
  static const String online = 'Online';
  static const String offline = 'Offline';
  
  // Settings
  static const String settings = 'Settings';
  static const String calorieGoalSetting = 'Daily Calorie Goal';
  static const String waterGoalSetting = 'Daily Water Goal';
  static const String mealReminders = 'Meal Reminders';
  static const String darkMode = 'Dark Mode';
  static const String premium = 'Premium';
  static const String about = 'About';
  
  // Notifications
  static const String breakfastReminderTitle = '🌅 Good Morning!';
  static const String lunchReminderTitle = '🍽️ Lunch Time!';
  static const String dinnerReminderTitle = '🌙 Dinner Time!';
}

class NotificationMessages {
  // Breakfast reminders - formal yet fun and appetite-building
  static const List<String> breakfastMessages = [
    "Rise and shine! Your body needs fuel — and we're not talking about coffee alone. Time for a nutritious breakfast! 🥐",
    "A king's breakfast awaits! Start your day with energy that lasts. Your stomach is calling! 👑",
    "Morning champion! Break that fast like you mean it. Ethiopian coffee pairs perfectly with a real meal! ☕",
    "Hey early bird! Your metabolism is awake and hungry. Don't let it down — grab that breakfast! 🌅",
    "Breakfast skippers miss 100% of the morning deliciousness. Be a winner, eat breakfast! 🏆",
    "Your body: 'I've been fasting all night!' You: 'Noted, breakfast incoming!' 🍳",
    "Fun fact: Breakfast literally means breaking the fast. So go ahead, break it beautifully! 🥘",
    "The Ethiopian way: Buna first, then a proper meal. Don't skip step two! ☕🥙",
    "Morning fuel = morning focus. Your brain runs on calories, not willpower alone! 🧠",
    "They say breakfast is the most important meal. We say it's the most DELICIOUS one! 😋",
  ];
  
  // Lunch reminders
  static const List<String> lunchMessages = [
    "Midday check-in! Your engine needs refueling. A proper lunch keeps the afternoon slump away! 🍛",
    "Lunch o'clock! Even the hardest workers need to recharge. Your next meal is waiting! ⚡",
    "Psst... it's lunch time! Your stomach has been patient, reward it generously! 🤫",
    "Halfway through the day, and your energy tank is showing. Time for a refill! ⛽",
    "A good lunch = a great afternoon. It's simple math, really! 📐",
    "Your body called. It said: 'Lunch. Now. Please.' You should listen! 📞",
    "Lunch break: not just for breaks, but for the BEST meal of the day! 🌟",
    "Injera and wot are calling your name. Don't leave them waiting! 🥘",
    "Recharge alert! Plug into some delicious lunch energy! 🔋",
    "The afternoon grind requires morning fuel's successor: LUNCH! 🚀",
  ];
  
  // Dinner reminders
  static const List<String> dinnerMessages = [
    "Evening feast time! A balanced dinner sets you up for a perfect tomorrow! 🌙",
    "After a long day, you've earned a proper dinner. Don't skip the reward! 🏅",
    "Dinner is served... well, it will be once you make it! Time to eat! 🍽️",
    "Night nutrition check! A light but satisfying dinner is the secret to good sleep! 😴",
    "They say don't eat heavy at night — they never said don't eat DELICIOUS! 😏",
    "Your daily nutrition mission isn't complete without dinner. Final stretch! 🎯",
    "Evening hunger is real hunger. Answer the call with a wholesome dinner! 📣",
    "A day without dinner is like a story without an ending. Write yours tonight! 📖",
    "The stars are out, and so is your appetite. Dinner time awaits! ✨",
    "Close the day the right way — with a meal that makes you smile! 😊",
  ];
  
  static String getBreakfastMessage(int dayOfYear) {
    return breakfastMessages[dayOfYear % breakfastMessages.length];
  }
  
  static String getLunchMessage(int dayOfYear) {
    return lunchMessages[dayOfYear % lunchMessages.length];
  }
  
  static String getDinnerMessage(int dayOfYear) {
    return dinnerMessages[dayOfYear % dinnerMessages.length];
  }
}
