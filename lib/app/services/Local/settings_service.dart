import 'package:hive/hive.dart';

class SettingsService {
  static const String _settingsBoxName = 'settings';
  
  // Settings keys
  static const String _categoryViewModeKey = 'category_view_mode';
  static const String _appStateKey = 'app_state';
  
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
  
  // Future expansion: other settings can be added here
  // static String getLanguage() {
  //   return _settingsBox.get('language', defaultValue: 'en');
  // }
  
  // static Future<void> setLanguage(String language) async {
  //   await _settingsBox.put('language', language);
  // }
}
