import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../core/constants/app_config.dart';
import '../core/constants/food_database.dart';
import '../models/ai_models.dart';
import '../models/food_item.dart';
import 'gemini_balancer.dart';

/// Result wrapper for chat replies so the UI can show online/offline state.
class ChatResult {
  final String reply;
  final bool wasOffline;
  final String? error;
  ChatResult({required this.reply, this.wasOffline = false, this.error});
}

class AIService {
  // ==========================================================================
  // GEMINI — AI Nutrition Assistant (text)
  // ==========================================================================
  // The text assistant runs on Gemini so it works reliably and speaks fluent
  // Amharic. It auto-detects Amharic input and replies in Amharic, and falls
  // back through a chain of models on quota (429) errors.
  static Future<String> chatWithAssistant({
    required String userMessage,
    required double currentCalories,
    required double currentWaterMl,
    required int calorieGoal,
  }) async {
    final r = await chatWithAssistantFull(
      userMessage: userMessage,
      currentCalories: currentCalories,
      currentWaterMl: currentWaterMl,
      calorieGoal: calorieGoal,
    );
    return r.reply;
  }

  /// True if the text contains Ethiopic (Amharic) script characters.
  static bool _containsAmharic(String text) {
    // Ethiopic Unicode block: U+1200–U+137F (plus supplements U+1380–U+139F).
    return RegExp(r'[\u1200-\u139F]').hasMatch(text);
  }

  static Future<ChatResult> chatWithAssistantFull({
    required String userMessage,
    required double currentCalories,
    required double currentWaterMl,
    required int calorieGoal,
  }) async {
    final isAmharic = _containsAmharic(userMessage);

    final languageRule = isAmharic
        ? '- The user wrote in Amharic (አማርኛ). You MUST reply ENTIRELY in clear, '
            'natural Amharic.'
        : '- Reply in the same language the user used. If they write in Amharic '
            '(አማርኛ), reply fully in Amharic; otherwise reply in English. You are '
            'fully fluent in Amharic.';

    final systemPrompt =
        '''You are FoodIQ AI, a knowledgeable and friendly nutrition assistant specializing in Ethiopian cuisine. You are fully bilingual in English and Amharic (አማርኛ).

Current user context:
- Calories consumed today: ${currentCalories.toStringAsFixed(0)} / $calorieGoal kcal
- Water intake: ${(currentWaterMl / 250).toStringAsFixed(0)} glasses (${currentWaterMl.toStringAsFixed(0)} ml)
- Time: ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}

Guidelines:
- Be friendly, encouraging, culturally respectful.
- Provide specific nutritional advice about Ethiopian dishes.
- Suggest practical meal plans incorporating traditional foods.
- Keep responses concise (under 200 words).
- If user asks about specific foods, mention calorie and macro info.
$languageRule
- Use both English and Amharic food names when helpful.''';

    // Route through the multi-key load balancer so requests spread across all
    // available Gemini keys + light models (the key/model with the lowest load
    // is preferred), maximizing reliability on the free tier.
    final reply = await GeminiBalancer.instance.generateText(
      prompt: userMessage,
      systemPrompt: systemPrompt,
      temperature: 0.7,
      maxOutputTokens: 1024,
    );

    if (reply != null && reply.trim().isNotEmpty) {
      return ChatResult(reply: reply.trim(), wasOffline: false);
    }

    return ChatResult(
      reply: _getOfflineResponse(userMessage),
      wasOffline: true,
      error: 'AI unavailable',
    );
  }

  // ==========================================================================
  // OFFLINE FALLBACK
  // ==========================================================================
  static String _getOfflineResponse(String query) {
    // If the user wrote in Amharic, reply offline in Amharic too.
    if (_containsAmharic(query)) {
      return 'ይቅርታ፣ አሁን ከበይነ መረብ ጋር መገናኘት አልቻልኩም። እባክዎ ትንሽ ቆይተው እንደገና ይሞክሩ። '
          'ስለ ኢትዮጵያ ምግቦች፣ ካሎሪ፣ ውሃ ወይም የምግብ እቅድ መጠየቅ ይችላሉ። 🇪🇹';
    }
    final q = query.toLowerCase();
    if (q.contains('hello') || q.contains('hi') || q.contains('hey') ||
        q.contains('selam')) {
      return "Selam! 👋 I'm FoodIQ AI — your nutrition assistant. "
          "I'm in offline mode right now, but I can still help with common "
          "questions about Ethiopian foods, water, protein, and meal planning!";
    }
    if (q.contains('injera')) {
      return 'Injera (እንጀራ) has ~110 kcal per 100g serving. Rich in fiber '
          '(~3g) and very low in fat. Made from teff flour — naturally '
          'gluten-free and a great source of iron and calcium!';
    }
    if (q.contains('doro wot') || q.contains('chicken stew')) {
      return 'Doro Wot (ዶሮ ወጥ) — ~250 kcal per serving with 22g protein. '
          'The crown jewel of Ethiopian cuisine: spicy chicken stew with '
          'berbere, perfect for special occasions!';
    }
    if (q.contains('kitfo')) {
      return 'Kitfo (ክትፎ) — ~320 kcal per serving with 28g protein and 23g '
          'fat. Minced raw beef seasoned with mitmita and niter kibbeh. '
          'High protein but also high fat — enjoy in moderation.';
    }
    if (q.contains('shiro')) {
      return 'Shiro (ሽሮ) — ~195 kcal per serving with 10g protein and 6g fiber. '
          'This chickpea-flour stew is a fasting favourite and a great '
          'source of plant-based protein!';
    }
    if (q.contains('tibs')) {
      return 'Tibs (ጥብስ) — sautéed cubes of beef or lamb with onions, '
          'rosemary, and berbere. About 280 kcal per 200g serving with '
          '22g protein. Perfect with injera!';
    }
    if (q.contains('water') || q.contains('hydrat')) {
      return 'Stay hydrated! 💧 Aim for 8 glasses (~2,000 ml) daily. '
          'Try a glass with each meal and one between meals — bonus glass '
          'for spicy Ethiopian food!';
    }
    if (q.contains('protein')) {
      return 'Protein heroes in Ethiopian cuisine: Doro Wot (22g), Kitfo '
          '(28g), Siga Tibs (22g). Plant-based: Misir Wot (12g), Shiro (10g), '
          'Lentils (9g). Target ~0.8g per kg of body weight per day.';
    }
    if (q.contains('low calorie') || q.contains('weight loss')) {
      return 'Light Ethiopian options: Gomen (~85 kcal), Tikil Gomen '
          '(~75 kcal), Atkilt Wot (~105 kcal), Buna (~5 kcal). Focus on '
          'vegetable wots and watch portion sizes.';
    }
    if (q.contains('breakfast')) {
      return 'Ethiopian breakfast ideas: Kinche (cracked wheat porridge, '
          '~170 kcal), Ful (fava bean stew, ~220 kcal), Chechebsa '
          '(shredded flatbread, ~320 kcal). Start your day right! ☀️';
    }
    if (q.contains('fast') || q.contains('tsom') || q.contains('vegan')) {
      return 'During fasting (tsom): Misir Wot, Shiro, Gomen, Fasolia, Kik '
          'Alicha — all naturally vegan. The Yetsom Beyaynetu platter gives '
          '~350 kcal with 14g protein and 10g fiber! 🌱';
    }
    if (q.contains('meal plan')) {
      return 'Balanced day: Breakfast — Ful + Buna (~250 kcal). Lunch — '
          'Beyaynetu platter + injera (~600 kcal). Snack — fruit + nuts '
          '(~150 kcal). Dinner — Tibs + injera + side veg (~500 kcal).';
    }
    return "I'm in offline mode. Try again when you have internet for "
        "personalised AI replies. Meanwhile, ask me about specific Ethiopian "
        "foods, protein, water, fasting, or meal planning!";
  }

  // ==========================================================================
  // GEMINI — Food Image Recognition (with model fallback chain)
  // ==========================================================================
  static Future<AIFoodResult?> recognizeFood(String base64Image) async {
    final detailed = await recognizeFoodDetailed(base64Image);
    return detailed.result;
  }

  /// Vision recognition with **automatic model fallback** on 429 quota errors.
  /// Returns the first successful result, or the last error if all models fail.
  static Future<({AIFoodResult? result, String? error})>
      recognizeFoodDetailed(String base64Image, {String? mimeType}) async {
    String? lastError;

    for (final model in AppConfig.geminiVisionFallbacks) {
      final attempt =
          await _tryGeminiModel(base64Image, model, mimeType: mimeType);
      if (attempt.result != null) {
        // Success!
        return attempt;
      }

      lastError = attempt.error;

      // Only continue to next model if it was a quota / availability error.
      final err = (attempt.error ?? '').toLowerCase();
      final isQuota = err.contains('429') ||
          err.contains('quota') ||
          err.contains('rate') ||
          err.contains('exceed') ||
          err.contains('unavailable') ||
          err.contains('not found') ||
          err.contains('404') ||
          err.contains('503');

      if (!isQuota) {
        // Hard error (parsing, no food, no internet) — don't try fallback.
        return attempt;
      }
      // ignore: avoid_print
      print('[Gemini] $model hit quota, trying next model...');
    }

    return (
      result: null,
      error: 'All AI vision models reached quota. Please try again in a '
          'few minutes.\n\nDetail: $lastError',
    );
  }

  static Future<({AIFoodResult? result, String? error})> _tryGeminiModel(
    String base64Image,
    String model, {
    String? mimeType,
  }) async {
    try {
      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/'
        '$model:generateContent'
        '?key=${AppConfig.geminiApiKey}',
      );

      final body = jsonEncode({
        'contents': [
          {
            'parts': [
              {
                'text':
                    '''You are a precise nutrition vision model. Analyze this food image and identify the primary food shown.

IMPORTANT — portion & calories:
- Carefully ESTIMATE the actual portion size visible in grams (serving_size_g),
  using visual cues like the plate size, utensils, and how full the plate is.
- The calories, protein, carbs, fat and fiber values MUST correspond to that
  estimated portion (the whole serving shown), NOT per 100g.
- Be as accurate and realistic as possible for the amount of food visible.

Return ONLY a JSON object (no markdown, no commentary) with this exact schema:

{
  "food_name": "common English name of the main food",
  "confidence": 0.85,
  "calories": 250,
  "protein": 15,
  "carbs": 30,
  "fat": 8,
  "fiber": 2,
  "serving_size_g": 200,
  "is_ethiopian": false,
  "alternative_matches": ["other possible food name"]
}

If it appears to be an Ethiopian dish (injera, doro wot, kitfo, shiro, tibs,
beyaynetu, misir wot, gomen, etc.), set is_ethiopian to true.

If the image does NOT clearly show food, return:
{"food_name": "unknown", "confidence": 0.0, "calories": 0, "protein": 0, "carbs": 0, "fat": 0, "fiber": 0, "serving_size_g": 0, "is_ethiopian": false, "alternative_matches": []}'''
              },
              {
                'inline_data': {
                  'mime_type': mimeType ?? 'image/jpeg',
                  'data': base64Image,
                }
              },
            ],
          },
        ],
        'generationConfig': {
          'temperature': 0.3,
          'maxOutputTokens': 1024,
          'responseMimeType': 'application/json',
        },
      });

      final response = await http
          .post(url,
              headers: {'Content-Type': 'application/json'}, body: body)
          .timeout(const Duration(seconds: 45));

      if (response.statusCode != 200) {
        // ignore: avoid_print
        print('[Gemini/$model] HTTP ${response.statusCode}: ${response.body}');

        final brief = _briefError(response.body);
        // Friendlier messages for common cases
        if (response.statusCode == 429) {
          return (result: null, error: '429: Quota reached — $brief');
        }
        if (response.statusCode == 404) {
          return (result: null, error: '404: Model not available — $brief');
        }
        return (
          result: null,
          error: 'HTTP ${response.statusCode}: $brief',
        );
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      final candidates = data['candidates'] as List?;
      if (candidates == null || candidates.isEmpty) {
        // ignore: avoid_print
        print('[Gemini/$model] empty candidates: ${response.body}');
        return (result: null, error: 'AI returned no candidates');
      }

      final content = candidates[0]?['content'] as Map<String, dynamic>?;
      final parts = content?['parts'] as List?;
      if (parts == null || parts.isEmpty) {
        // Possibly safety-blocked or MAX_TOKENS
        final finish = candidates[0]?['finishReason']?.toString() ?? '';
        return (
          result: null,
          error: 'AI returned empty content${finish.isNotEmpty ? ' ($finish)' : ''}'
        );
      }

      final text = (parts[0]?['text'] as String?)?.trim() ?? '';
      final jsonStr = _extractJson(text);

      Map<String, dynamic> foodData;
      try {
        foodData = jsonDecode(jsonStr) as Map<String, dynamic>;
      } catch (e) {
        // ignore: avoid_print
        print('[Gemini/$model] JSON parse error: $e | raw: $text');
        return (
          result: null,
          error: 'Could not parse AI reply: ${text.substring(0, text.length.clamp(0, 100))}',
        );
      }

      final foodName = (foodData['food_name'] ?? '').toString().trim();
      final confidence = ((foodData['confidence'] ?? 0) as num).toDouble();

      if (foodName.isEmpty ||
          foodName.toLowerCase() == 'unknown' ||
          foodName.toLowerCase() == 'none' ||
          confidence < 0.05) {
        return (
          result: null,
          error: 'No food detected in the image. Try a clearer photo with '
              'the food filling more of the frame.',
        );
      }

      final raw = AIFoodResult(
        foodName: foodName,
        confidence: confidence,
        calories: ((foodData['calories'] ?? 0) as num).toDouble(),
        protein: ((foodData['protein'] ?? 0) as num).toDouble(),
        carbs: ((foodData['carbs'] ?? 0) as num).toDouble(),
        fat: ((foodData['fat'] ?? 0) as num).toDouble(),
        servingSize: ((foodData['serving_size_g'] ?? 100) as num).toDouble(),
        isEthiopian: (foodData['is_ethiopian'] ?? false) as bool,
        alternativeMatches: ((foodData['alternative_matches'] ?? []) as List)
            .map((e) => e.toString())
            .toList(),
      );

      return (result: _matchWithLocalDB(raw), error: null);
    } on SocketException catch (e) {
      return (result: null, error: 'No internet: ${e.message}');
    } on HttpException catch (e) {
      return (result: null, error: 'Network error: ${e.message}');
    } catch (e) {
      // ignore: avoid_print
      print('[Gemini/$model] exception: $e');
      return (result: null, error: 'Unexpected error: $e');
    }
  }

  static String _extractJson(String s) {
    var t = s.trim();
    if (t.startsWith('```')) {
      t = t.replaceAll(RegExp(r'```(?:json)?'), '').trim();
    }
    final firstBrace = t.indexOf('{');
    final lastBrace = t.lastIndexOf('}');
    if (firstBrace >= 0 && lastBrace > firstBrace) {
      return t.substring(firstBrace, lastBrace + 1);
    }
    return t;
  }

  static String _briefError(String body) {
    try {
      final d = jsonDecode(body);
      if (d is Map && d['error'] is Map) {
        return d['error']['message']?.toString() ?? body;
      }
    } catch (_) {}
    return body.length > 150 ? '${body.substring(0, 150)}...' : body;
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
