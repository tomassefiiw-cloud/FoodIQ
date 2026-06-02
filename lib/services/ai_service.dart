import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/app_config.dart';
import '../models/ai_models.dart';
import '../core/constants/food_database.dart';
import '../models/food_item.dart';

class AIService {
  // ===== GROQ - AI Nutrition Assistant =====
  static Future<String> chatWithAssistant({
    required String userMessage,
    required double currentCalories,
    required double currentWaterMl,
    required int calorieGoal,
  }) async {
    try {
      final systemPrompt = '''You are FoodIQ AI, a knowledgeable and friendly nutrition assistant specializing in Ethiopian cuisine. 
You help users track their calories, understand nutritional values of Ethiopian and common foods, and provide practical dietary advice.

Current user context:
- Calories consumed today: ${currentCalories.toStringAsFixed(0)} / $calorieGoal kcal
- Water intake: ${(currentWaterMl / 250).toStringAsFixed(0)} glasses (${currentWaterMl.toStringAsFixed(0)} ml)
- Time: ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}

Guidelines:
- Be friendly, encouraging, and culturally respectful
- Provide specific nutritional advice about Ethiopian dishes
- Suggest practical meal plans incorporating traditional foods
- Keep responses concise (under 200 words)
- If user asks about specific foods, mention calorie and macro info
- Support both English and Amharic food names''';

      final response = await http.post(
        Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppConfig.groqApiKey}',
        },
        body: jsonEncode({
          'model': AppConfig.groqChatModel,
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': userMessage},
          ],
          'max_tokens': 1024,
          'temperature': 0.7,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'] ?? 'I couldn\'t generate a response. Please try again.';
      } else {
        return _getOfflineResponse(userMessage);
      }
    } catch (e) {
      return _getOfflineResponse(userMessage);
    }
  }

  // ===== OFFLINE KEYWORD FALLBACK =====
  static String _getOfflineResponse(String query) {
    final q = query.toLowerCase();
    
    if (q.contains('hello') || q.contains('hi') || q.contains('hey')) {
      return 'Hello! 👋 I\'m FoodIQ AI, your nutrition assistant. Ask me about Ethiopian foods, calories, or meal planning!';
    }
    if (q.contains('injera')) {
      return 'Injera (እንጀራ) has 110 kcal per 100g serving. It\'s rich in fiber (3.2g) and low in fat (0.7g). Made from teff flour, it\'s naturally gluten-free and a great source of iron and calcium!';
    }
    if (q.contains('doro wot') || q.contains('chicken stew')) {
      return 'Doro Wot (ዶሮ ወጥ) has 250 kcal per serving with 22g protein. It\'s the crown jewel of Ethiopian cuisine - a spicy chicken stew perfect for special occasions!';
    }
    if (q.contains('kitfo')) {
      return 'Kitfo (ክትፎ) has 320 kcal per serving with 28g protein and 23g fat. It\'s minced raw beef seasoned with mitmita spice. High in protein but also high in fat!';
    }
    if (q.contains('shiro')) {
      return 'Shiro (ሽሮ) has 195 kcal per serving with 10g protein and 6g fiber. This chickpea flour stew is a fasting favorite and great source of plant-based protein!';
    }
    if (q.contains('water') || q.contains('hydration')) {
      return 'Staying hydrated is crucial! 💧 Aim for 8 glasses (2000ml) daily. Water boosts metabolism, aids digestion, and helps control appetite. Try drinking a glass before each meal!';
    }
    if (q.contains('protein')) {
      return 'For protein in Ethiopian cuisine: Doro Wot (22g), Kitfo (28g), Siga Tibs (22g). For plant-based: Misir Wot (12g), Shiro (10g), Lentils (9g). Aim for 0.8g per kg body weight!';
    }
    if (q.contains('low calorie') || q.contains('weight loss')) {
      return 'Low-calorie Ethiopian options: Gomen (85 kcal), Tikil Gomen (75 kcal), Atkilt Wot (105 kcal), Buna (5 kcal). Focus on vegetable wot dishes and control portion sizes!';
    }
    if (q.contains('breakfast')) {
      return 'Ethiopian breakfast ideas: Kinche (170 kcal) - cracked wheat porridge, Ful (220 kcal) - fava bean stew, Chechebsa (320 kcal) - shredded flatbread. Start your day right! ☀️';
    }
    if (q.contains('fasting') || q.contains('vegan')) {
      return 'During fasting: Misir Wot, Shiro, Gomen, Fasolia, Kik Alicha are all vegan! The Yetsom Beyaynetu platter gives you 350 kcal with 14g protein and 10g fiber! 🌱';
    }
    return 'I\'m currently in offline mode. For the best experience, connect to the internet. In the meantime, I can help with basic questions about Ethiopian foods, water intake, protein, and meal planning!';
  }

  // ===== GEMINI - Food Image Recognition =====
  static Future<AIFoodResult?> recognizeFood(String base64Image) async {
    try {
      final response = await http.post(
        Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/${AppConfig.geminiVisionModel}:generateContent?key=${AppConfig.geminiApiKey}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [{
            'parts': [
              {'text': '''Analyze this food image and identify what food(s) are shown. Respond in this exact JSON format:
{
  "food_name": "name of the main food",
  "confidence": 0.85,
  "calories": 250,
  "protein": 15,
  "carbs": 30,
  "fat": 8,
  "serving_size_g": 200,
  "is_ethiopian": false,
  "alternative_matches": ["other possible food name"]
}
Be specific with food names. If it looks like an Ethiopian dish, set is_ethiopian to true.'''},
              {'inline_data': {'mime_type': 'image/jpeg', 'data': base64Image}},
            ],
          }],
          'generationConfig': {
            'temperature': 0.4,
            'maxOutputTokens': 512,
          },
        }),
      ).timeout(const Duration(seconds: 45));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates'][0]['content']['parts'][0]['text'] as String;
        
        // Extract JSON from response
        String jsonStr = text;
        final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(text);
        if (jsonMatch != null) {
          jsonStr = jsonMatch.group(0)!;
        }
        
        final foodData = jsonDecode(jsonStr);
        final result = AIFoodResult(
          foodName: foodData['food_name'] ?? 'Unknown',
          confidence: (foodData['confidence'] ?? 0.5).toDouble(),
          calories: (foodData['calories'] ?? 0).toDouble(),
          protein: (foodData['protein'] ?? 0).toDouble(),
          carbs: (foodData['carbs'] ?? 0).toDouble(),
          fat: (foodData['fat'] ?? 0).toDouble(),
          servingSize: (foodData['serving_size_g'] ?? 100).toDouble(),
          isEthiopian: foodData['is_ethiopian'] ?? false,
          alternativeMatches: List<String>.from(foodData['alternative_matches'] ?? []),
        );
        
        // Try to match against local database for accurate nutrition
        return _matchWithLocalDB(result);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static AIFoodResult _matchWithLocalDB(AIFoodResult result) {
    final matches = FoodDatabase.searchFoods(result.foodName);
    if (matches.isNotEmpty) {
      final matched = matches.first;
      return AIFoodResult(
        foodName: matched.name,
        confidence: result.confidence,
        calories: matched.calories,
        protein: matched.protein,
        carbs: matched.carbs,
        fat: matched.fat,
        servingSize: matched.servingSize,
        isEthiopian: matched.category == FoodCategory.ethiopian,
        alternativeMatches: result.alternativeMatches,
      );
    }
    return result;
  }
}
