import 'package:hive/hive.dart';

class SettingsService {
  static const String _settingsBoxName = 'settings';

  // Settings keys
  static const String _categoryViewModeKey = 'category_view_mode';
  static const String _appStateKey = 'app_state';
  static const String _authModeKey = 'auth_mode'; // 'google' | 'guest'

  static const String _justLoggedOutKey = 'just_logged_out'; // transient flag
  static Box get _settingsBox => Hive.box(_settingsBoxName);

  // Category view mode (true = grid, false = list)
  static bool getCategoryViewMode() {
    return _settingsBox.get(_categoryViewModeKey, defaultValue: true);
  }

  static Future<void> setCategoryViewMode(bool isGridView) async {
    await _settingsBox.put(_categoryViewModeKey, isGridView);
  }

  // App authentication state (logged in or not)
  static bool getAppState() {
    return _settingsBox.get(_appStateKey, defaultValue: false);
  }

  static Future<void> setAppState(bool isLoggedIn) async {
    await _settingsBox.put(_appStateKey, isLoggedIn);
  }

  // Auth mode: 'google' enables sync, 'guest' disables sync
  static String getAuthMode() {
    return _settingsBox.get(_authModeKey, defaultValue: 'guest');
  }

  static Future<void> setAuthMode(String mode) async {
    // accepted values: 'google' | 'guest'
    await _settingsBox.put(_authModeKey, mode);
  }

  static bool isGoogleLogin() => getAuthMode() == 'google';
  static bool isGuestLogin() => getAuthMode() == 'guest';

  // Convenience: sync is enabled only for Google login
  static bool isSyncEnabled() => isGoogleLogin();

  // One-time snackbar helper for logout
  static bool getJustLoggedOut() {
    return _settingsBox.get(_justLoggedOutKey, defaultValue: false);
  }

  static Future<void> setJustLoggedOut(bool value) async {
    await _settingsBox.put(_justLoggedOutKey, value);
  }

  // Future expansion: other settings can be added here
  // static String getLanguage() {
  //   return _settingsBox.get('language', defaultValue: 'en');
  // }

  // static Future<void> setLanguage(String language) async {
  //   await _settingsBox.put('language', language);
  // }
}
