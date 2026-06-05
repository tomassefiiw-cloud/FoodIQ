import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// A daily mental-wellness check-in (mood + stress + optional note).
/// Aligned to the Wellness Hackathon "Mental Wellness & Stress Management" and
/// "Personal Wellness & Lifestyle Intelligence" focus areas. Stored locally.
class WellnessCheckin {
  final String dateKey; // yyyy-mm-dd
  final int mood; // 1 (low) .. 5 (great)
  final int stress; // 1 (calm) .. 5 (very stressed)
  final int energy; // 1 (drained) .. 5 (energized)
  final String note;

  const WellnessCheckin({
    required this.dateKey,
    required this.mood,
    required this.stress,
    required this.energy,
    this.note = '',
  });

  Map<String, dynamic> toJson() => {
        'dateKey': dateKey,
        'mood': mood,
        'stress': stress,
        'energy': energy,
        'note': note,
      };

  factory WellnessCheckin.fromJson(Map<String, dynamic> j) => WellnessCheckin(
        dateKey: j['dateKey'] as String,
        mood: (j['mood'] as num?)?.toInt() ?? 3,
        stress: (j['stress'] as num?)?.toInt() ?? 3,
        energy: (j['energy'] as num?)?.toInt() ?? 3,
        note: (j['note'] as String?) ?? '',
      );
}

/// Local store for wellness check-ins (last 60 days kept).
class WellnessStore {
  static const _key = 'wellness_checkins_json';

  static String dateKeyFor(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static Future<List<WellnessCheckin>> _all() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = (jsonDecode(raw) as List)
          .map((e) => WellnessCheckin.fromJson(e as Map<String, dynamic>))
          .toList();
      return list;
    } catch (_) {
      return [];
    }
  }

  static Future<void> _saveAll(List<WellnessCheckin> list) async {
    final prefs = await SharedPreferences.getInstance();
    // Keep only the most recent 60 entries.
    list.sort((a, b) => b.dateKey.compareTo(a.dateKey));
    final trimmed = list.take(60).toList();
    await prefs.setString(
        _key, jsonEncode(trimmed.map((e) => e.toJson()).toList()));
  }

  /// Save (or replace) today's check-in.
  static Future<void> upsert(WellnessCheckin c) async {
    final all = await _all();
    all.removeWhere((e) => e.dateKey == c.dateKey);
    all.add(c);
    await _saveAll(all);
  }

  static Future<WellnessCheckin?> today() async {
    final all = await _all();
    final k = dateKeyFor(DateTime.now());
    for (final e in all) {
      if (e.dateKey == k) return e;
    }
    return null;
  }

  /// Most recent [days] check-ins (newest first).
  static Future<List<WellnessCheckin>> recent({int days = 7}) async {
    final all = await _all();
    all.sort((a, b) => b.dateKey.compareTo(a.dateKey));
    return all.take(days).toList();
  }
}
