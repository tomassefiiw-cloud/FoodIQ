import 'dart:math';
import '../core/constants/food_database.dart';
import '../models/food_item.dart';

enum MealTime { breakfast, lunch, dinner, reminder }

class NotificationMessageGenerator {
  /// Generates a funny, appetizing message based on the meal time and user's BMI category.
  static String generateMealReminder({
    required MealTime time,
    required String bmiCategory,
    required int dayOfYear,
  }) {
    final funnyIntros = {
      MealTime.breakfast: [
        "Wakey wakey! Your stomach is calling... 🌅",
        "Time to fuel your brain! Don't let the morning win. 🍳",
        "Good morning! Your body is craving something delicious... 🥐",
        "Rise and shine! Let's start the day with a feast! ☀️",
        "Breakfast is the most important meal, and you're the most important person! 🥞",
      ],
      MealTime.lunch: [
        "Lunch break alert! Time to escape the work and eat! ☀️",
        "Your stomach just sent me a message: 'I'm hungry!' 🍲",
        "Midday fuel-up time! Your energy is dipping... 🍱",
        "Stop everything! It's time for some deliciousness! 🥗",
        "Lunch is calling your name! Don't keep it waiting! 🍕",
      ],
      MealTime.dinner: [
        "Dinner time! The best part of the day is here... 🌙",
        "You survived the day! You deserve a grand feast! 🍗",
        "Evening vibes and tasty bites. Time to eat! 🍛",
        "Wrap up your day with something scrumptious! 🍝",
        "Time to wind down with a delicious dinner! 🥘",
      ],
    };

    final intro = (funnyIntros[time] ?? ["Time to eat!"]) [Random().nextInt(5)];
    final suggestion = _getBMISuggestion(bmiCategory, time);
    
    return "$intro\n\nSince you're in the $bmiCategory range, how about $suggestion?";
  }

  /// Generates a funny reminder if the user hasn't logged food.
  static String generateLogReminder({
    required MealTime time,
    required String bmiCategory,
  }) {
    final funnyUrges = [
      "Your food log is looking a bit lonely... 🥺",
      "Did you eat something delicious and forget to tell me? I'm jealous! 🥘",
      "Your calories are missing! Let's get that log updated! 📈",
      "Ghosting your food log? Don't do that to me! 👻",
      "Is your stomach full but your app empty? Fix it now! 🍽️",
    ];

    final urge = funnyUrges[Random().nextInt(funnyUrges.length)];
    final suggestion = _getBMISuggestion(bmiCategory, time);

    return "$urge\n\nMaybe try $suggestion? It's perfect for your $bmiCategory profile!";
  }

  /// Returns a BMI-based meal suggestion based on the meal time.
  static String _getBMISuggestion(String bmiCategory, MealTime time) {
    final allFoods = FoodDatabase.allFoods;
    List<FoodItem> suggested;

    // Logic mirrored from BMIScreen but adapted for notification suggestions
    if (bmiCategory.contains('Underweight')) {
      suggested = allFoods.where((f) => f.calories >= 250 && f.protein >= 15).toList();
    } else if (bmiCategory.contains('Normal')) {
      suggested = allFoods.where((f) => f.calories >= 150 && f.calories <= 350 && f.protein >= 8).toList();
    } else if (bmiCategory.contains('Overweight')) {
      suggested = allFoods.where((f) => f.calories <= 250 && f.protein >= 10 && f.fiber >= 4).toList();
    } else {
      // Obese
      suggested = allFoods.where((f) => f.calories <= 200 && f.fiber >= 5).toList();
    }

    if (suggested.isEmpty) {
      return "something healthy and balanced";
    }

    final food = suggested[Random().nextInt(suggested.length)];
    return "${food.name} (${food.calories.toStringAsFixed(0)} kcal)";
  }
}
