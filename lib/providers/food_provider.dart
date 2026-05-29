import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/food_database.dart';
import '../models/food_item.dart';

// Food search query
final foodSearchQueryProvider = StateProvider<String>((ref) => '');

// All foods
final allFoodsProvider = Provider<List<FoodItem>>((ref) {
  return FoodDatabase.allFoods;
});

// Ethiopian foods
final ethiopianFoodsProvider = Provider<List<FoodItem>>((ref) {
  return FoodDatabase.ethiopianFoods;
});

// Common foods
final commonFoodsProvider = Provider<List<FoodItem>>((ref) {
  return FoodDatabase.commonFoods;
});

// Filtered foods based on search
final filteredFoodsProvider = Provider<List<FoodItem>>((ref) {
  final query = ref.watch(foodSearchQueryProvider);
  if (query.isEmpty) return FoodDatabase.allFoods;
  return FoodDatabase.searchFoods(query);
});

// Selected food tab
final foodTabProvider = StateProvider<int>((ref) => 0);
