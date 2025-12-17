import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static const String _keyLoggedInUserId = 'logged_in_user_id';
  static const String _keyRememberMe = 'remember_me';
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyLastSyncTime = 'last_sync_time';

  final SharedPreferences _prefs;

  SharedPreferencesHelper(this._prefs);

  static Future<SharedPreferencesHelper> getInstance() async {
    final prefs = await SharedPreferences.getInstance();
    return SharedPreferencesHelper(prefs);
  }

  // Authentication
  Future<void> setLoggedInUserId(String userId) async {
    await _prefs.setString(_keyLoggedInUserId, userId);
  }

  String? getLoggedInUserId() {
    return _prefs.getString(_keyLoggedInUserId);
  }

  Future<void> setRememberMe(bool value) async {
    await _prefs.setBool(_keyRememberMe, value);
  }

  bool getRememberMe() {
    return _prefs.getBool(_keyRememberMe) ?? false;
  }

  Future<void> clearAuth() async {
    await _prefs.remove(_keyLoggedInUserId);
    await _prefs.remove(_keyRememberMe);
  }

  // Theme
  Future<void> setThemeMode(String mode) async {
    await _prefs.setString(_keyThemeMode, mode);
  }

  String getThemeMode() {
    return _prefs.getString(_keyThemeMode) ?? 'light';
  }

  // Sync
  Future<void> setLastSyncTime(DateTime time) async {
    await _prefs.setString(_keyLastSyncTime, time.toIso8601String());
  }

  DateTime? getLastSyncTime() {
    final timeStr = _prefs.getString(_keyLastSyncTime);
    return timeStr != null ? DateTime.parse(timeStr) : null;
  }

  Future<void> clearAll() async {
    await _prefs.clear();
  }
}