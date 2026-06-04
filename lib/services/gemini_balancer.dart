import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../core/constants/api_keys.dart';

/// A lightweight client-side **load balancer** across multiple Gemini API keys.
///
/// Goal (per product request): when one key is busy / rate-limited, send the
/// next request through the key that currently has the *fewest* requests and is
/// not in cool-down — i.e. "use the key/model that doesn't have the highest
/// request load". This spreads usage and dramatically improves reliability on
/// the free tier.
///
/// It also rotates through a small chain of light models (high free-tier quota)
/// so a single model's quota never blocks the whole feature.
class GeminiBalancer {
  GeminiBalancer._();
  static final GeminiBalancer instance = GeminiBalancer._();

  /// The pool of keys we balance across. Order doesn't matter — we always pick
  /// the least-loaded, non-cooling key at call time.
  late final List<_KeyState> _keys = _buildPool();

  static List<_KeyState> _buildPool() {
    final raw = <String>[
      ApiKeys.geminiApiKey,
      ApiKeys.geminiBmiApiKey,
      ApiKeys.geminiLegacyApiKey,
    ];
    // De-duplicate while preserving order.
    final seen = <String>{};
    final pool = <_KeyState>[];
    for (final k in raw) {
      if (k.trim().isEmpty) continue;
      if (seen.add(k)) pool.add(_KeyState(k));
    }
    return pool;
  }

  /// Light, high-quota models tried in order (per key) on quota errors.
  static const List<String> _models = [
    'gemini-2.5-flash-lite',
    'gemini-flash-lite-latest',
    'gemini-2.0-flash-lite',
    'gemini-2.0-flash',
    'gemini-2.5-flash',
  ];

  /// Keys sorted so the least-loaded, ready key comes first.
  List<_KeyState> _orderedKeys() {
    final now = DateTime.now();
    final ready = _keys.where((k) => k.readyAt.isBefore(now)).toList();
    final cooling = _keys.where((k) => !k.readyAt.isBefore(now)).toList();
    // Least requests first (the load-balancing core).
    ready.sort((a, b) => a.requestCount.compareTo(b.requestCount));
    // If everything is cooling down, try the one that frees up soonest.
    cooling.sort((a, b) => a.readyAt.compareTo(b.readyAt));
    return [...ready, ...cooling];
  }

  /// Generate text from Gemini, balancing across keys + models.
  ///
  /// Returns the trimmed reply text, or null if every key/model failed.
  /// [jsonMode] requests a JSON response (used by the nutritionist analyzer).
  Future<String?> generateText({
    required String prompt,
    String? systemPrompt,
    double temperature = 0.7,
    int maxOutputTokens = 1024,
    bool jsonMode = false,
  }) async {
    if (_keys.isEmpty) return null;

    String? lastError;

    for (final key in _orderedKeys()) {
      for (final model in _models) {
        try {
          key.requestCount++;
          final url = Uri.parse(
            'https://generativelanguage.googleapis.com/v1beta/models/'
            '$model:generateContent?key=${key.key}',
          );

          final payload = <String, dynamic>{
            'contents': [
              {
                'role': 'user',
                'parts': [
                  {'text': prompt}
                ]
              }
            ],
            'generationConfig': {
              'temperature': temperature,
              'maxOutputTokens': maxOutputTokens,
              if (jsonMode) 'responseMimeType': 'application/json',
            },
          };
          if (systemPrompt != null && systemPrompt.isNotEmpty) {
            payload['systemInstruction'] = {
              'parts': [
                {'text': systemPrompt}
              ]
            };
          }

          final response = await http
              .post(url,
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode(payload))
              .timeout(const Duration(seconds: 35));

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body) as Map<String, dynamic>;
            final candidates = data['candidates'] as List?;
            if (candidates == null || candidates.isEmpty) {
              lastError = 'No candidates';
              continue;
            }
            final parts =
                (candidates[0]?['content']?['parts'] as List?) ?? const [];
            final text = parts
                .map((p) => (p is Map && p['text'] != null) ? p['text'] : '')
                .join('')
                .toString()
                .trim();
            if (text.isEmpty) {
              lastError = 'Empty reply';
              continue;
            }
            return text;
          }

          // Non-200: on quota/availability, cool this key down briefly and
          // move on so the next request prefers a less-loaded key.
          final body = response.body.toLowerCase();
          final isQuota = response.statusCode == 429 ||
              response.statusCode == 503 ||
              response.statusCode == 404 ||
              body.contains('quota') ||
              body.contains('rate') ||
              body.contains('unavailable') ||
              body.contains('overloaded');
          lastError = 'HTTP ${response.statusCode}';
          if (response.statusCode == 429) {
            // This key is over quota — rest it so other keys are preferred.
            key.readyAt = DateTime.now().add(const Duration(seconds: 45));
            break; // try next key
          }
          if (isQuota) {
            continue; // try next model on the same key
          }
          // Hard error (bad request etc.) — stop trying more models for key.
          break;
        } on SocketException {
          return null; // offline — let caller use its offline fallback
        } catch (e) {
          lastError = e.toString();
          continue;
        }
      }
    }

    // ignore: avoid_print
    print('[GeminiBalancer] all keys/models failed: $lastError');
    return null;
  }
}

class _KeyState {
  final String key;
  int requestCount = 0;
  DateTime readyAt = DateTime.fromMillisecondsSinceEpoch(0);
  _KeyState(this.key);
}
