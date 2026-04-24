import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalDatabase {
  static const String _medicinesKey = 'db_medicines';
  static const String _historyKey = 'db_history';
  static const String _userKey = 'db_user';
  static const String _settingsKey = 'db_settings';
  static const String _onboardingKey = 'db_onboarding_done';
  static const String _loggedInKey = 'db_logged_in';

  static LocalDatabase? _instance;
  SharedPreferences? _prefs;

  LocalDatabase._();

  static LocalDatabase get instance {
    _instance ??= LocalDatabase._();
    return _instance!;
  }

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  SharedPreferences get _p {
    if (_prefs == null) throw StateError('LocalDatabase not initialized');
    return _prefs!;
  }

  // ─── Generic CRUD ───────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getAll(String key) async {
    final raw = _p.getString(key);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list.cast<Map<String, dynamic>>();
  }

  Future<void> saveAll(String key, List<Map<String, dynamic>> data) async {
    await _p.setString(key, jsonEncode(data));
  }

  Future<Map<String, dynamic>?> getById(String key, String id) async {
    final all = await getAll(key);
    try {
      return all.firstWhere((e) => e['id'] == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> upsert(String key, Map<String, dynamic> item) async {
    final all = await getAll(key);
    final idx = all.indexWhere((e) => e['id'] == item['id']);
    if (idx >= 0) {
      all[idx] = item;
    } else {
      all.add(item);
    }
    await saveAll(key, all);
  }

  Future<void> delete(String key, String id) async {
    final all = await getAll(key);
    all.removeWhere((e) => e['id'] == id);
    await saveAll(key, all);
  }

  Future<void> clear(String key) async {
    await _p.remove(key);
  }

  // ─── Typed accessors ────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getMedicines() => getAll(_medicinesKey);
  Future<void> saveMedicine(Map<String, dynamic> m) => upsert(_medicinesKey, m);
  Future<void> deleteMedicine(String id) => delete(_medicinesKey, id);
  Future<void> saveMedicines(List<Map<String, dynamic>> list) =>
      saveAll(_medicinesKey, list);

  Future<List<Map<String, dynamic>>> getHistory() => getAll(_historyKey);
  Future<void> saveHistoryEntry(Map<String, dynamic> h) =>
      upsert(_historyKey, h);
  Future<void> saveHistory(List<Map<String, dynamic>> list) =>
      saveAll(_historyKey, list);

  Future<Map<String, dynamic>?> getUser() async {
    final raw = _p.getString(_userKey);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> saveUser(Map<String, dynamic> user) async {
    await _p.setString(_userKey, jsonEncode(user));
  }

  Future<Map<String, dynamic>> getSettings() async {
    final raw = _p.getString(_settingsKey);
    if (raw == null) return {};
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> saveSettings(Map<String, dynamic> settings) async {
    await _p.setString(_settingsKey, jsonEncode(settings));
  }

  Future<bool> isOnboardingDone() async => _p.getBool(_onboardingKey) ?? false;
  Future<void> setOnboardingDone() async =>
      _p.setBool(_onboardingKey, true);

  Future<bool> isLoggedIn() async => _p.getBool(_loggedInKey) ?? false;
  Future<void> setLoggedIn(bool value) async =>
      _p.setBool(_loggedInKey, value);

  Future<void> clearAll() async {
    await _p.remove(_medicinesKey);
    await _p.remove(_historyKey);
  }
}
