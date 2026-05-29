enum FoodCategory { ethiopian, common, custom }

enum MealType { breakfast, lunch, dinner, snack }

class FoodItem {
  final String id;
  final String name;
  final String nameAmharic;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final double servingSize;
  final String servingUnit;
  final FoodCategory category;
  final String? description;

  const FoodItem({
    required this.id,
    required this.name,
    this.nameAmharic = '',
    required this.calories,
    this.protein = 0,
    this.carbs = 0,
    this.fat = 0,
    this.fiber = 0,
    this.servingSize = 100,
    this.servingUnit = 'g',
    this.category = FoodCategory.common,
    this.description,
  });

  FoodItem scaledTo(double portion) => FoodItem(
    id: id,
    name: name,
    nameAmharic: nameAmharic,
    calories: (calories * portion).roundToDouble(),
    protein: (protein * portion).roundToDouble(),
    carbs: (carbs * portion).roundToDouble(),
    fat: (fat * portion).roundToDouble(),
    fiber: (fiber * portion).roundToDouble(),
    servingSize: servingSize * portion,
    servingUnit: servingUnit,
    category: category,
    description: description,
  );

  double get caloriesPerGram => servingSize > 0 ? calories / servingSize : 0;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'name_amharic': nameAmharic,
    'calories': calories,
    'protein': protein,
    'carbs': carbs,
    'fat': fat,
    'fiber': fiber,
    'serving_size': servingSize,
    'serving_unit': servingUnit,
    'category': category.name,
    'description': description,
  };

  factory FoodItem.fromJson(Map<String, dynamic> json) => FoodItem(
    id: json['id'] as String,
    name: json['name'] as String,
    nameAmharic: (json['name_amharic'] as String?) ?? '',
    calories: (json['calories'] as num).toDouble(),
    protein: (json['protein'] as num?)?.toDouble() ?? 0,
    carbs: (json['carbs'] as num?)?.toDouble() ?? 0,
    fat: (json['fat'] as num?)?.toDouble() ?? 0,
    fiber: (json['fiber'] as num?)?.toDouble() ?? 0,
    servingSize: (json['serving_size'] as num?)?.toDouble() ?? 100,
    servingUnit: (json['serving_unit'] as String?) ?? 'g',
    category: FoodCategory.values.firstWhere(
      (c) => c.name == json['category'],
      orElse: () => FoodCategory.common,
    ),
    description: json['description'] as String?,
  );
}
