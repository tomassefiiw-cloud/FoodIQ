enum SuggestionType { balanced, lowProtein, lowCalories, highCalories, highCarbs, goodProgress, hydration }

class AISuggestion {
  final String message;
  final SuggestionType type;
  final String? tip;

  AISuggestion({required this.message, required this.type, this.tip});
}

class AIFoodResult {
  final String foodName;
  final double confidence;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double servingSize;
  final bool isEthiopian;
  final List<String> alternativeMatches;

  AIFoodResult({
    required this.foodName,
    this.confidence = 0.0,
    this.calories = 0,
    this.protein = 0,
    this.carbs = 0,
    this.fat = 0,
    this.servingSize = 100,
    this.isEthiopian = false,
    this.alternativeMatches = const [],
  });

  bool get isConfident => confidence >= 0.6;
}
