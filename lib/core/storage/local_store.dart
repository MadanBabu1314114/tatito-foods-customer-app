import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Small wrapper around [SharedPreferences] so every feature persists local
/// mock data through one place. No network calls are made here.
///
/// Missing plugin/platform errors are treated as empty storage so widget tests
/// and unsupported platforms keep working without crashing.
class LocalStore {
  const LocalStore._();

  static Future<String?> readString(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(key);
    } catch (_) {
      return null;
    }
  }

  static Future<void> writeString(String key, String value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    } catch (_) {}
  }

  static Future<void> remove(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
    } catch (_) {}
  }

  static Future<void> writeJson(String key, Object value) async {
    await writeString(key, jsonEncode(value));
  }

  static Future<dynamic> readJson(String key) async {
    final raw = await readString(key);
    if (raw == null || raw.isEmpty) return null;
    try {
      return jsonDecode(raw);
    } catch (_) {
      return null;
    }
  }
}
