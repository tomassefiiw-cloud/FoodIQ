import 'package:uuid/uuid.dart';
import '../models/food_item.dart';
import 'supabase_service.dart';

class FoodService {
  static const _uuid = Uuid();

  static Future<List<FoodItem>> getCustomFoods(String userId) async {
    try {
      final response = await SupabaseService.customFoods
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return response.map<FoodItem>((json) => FoodItem.fromJson({...json, 'category': 'custom'})).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<bool> addCustomFood({
    required String userId,
    required String name,
    required double calories,
    double protein = 0,
    double carbs = 0,
    double fat = 0,
    double fiber = 0,
    double servingSize = 100,
    String servingUnit = 'g',
    String? description,
  }) async {
    try {
      await SupabaseService.customFoods.insert({
        'id': 'custom_${_uuid.v4()}',
        'user_id': userId,
        'name': name,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
        'fiber': fiber,
        'serving_size': servingSize,
        'serving_unit': servingUnit,
        'description': description,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deleteCustomFood(String foodId) async {
    try {
      await SupabaseService.customFoods.delete().eq('id', foodId);
      return true;
    } catch (e) {
      return false;
    }
  }
}
