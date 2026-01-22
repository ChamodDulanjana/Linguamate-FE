import 'package:flutter/material.dart';

class ThemeManager with ChangeNotifier {
  // Singleton instance
  static final ThemeManager _instance = ThemeManager._internal();
  static ThemeManager get instance => _instance;

  ThemeManager._internal();

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  void setThemeMode(ThemeMode mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      notifyListeners();
    }
  }

  // Helper to get readable name
  String get themeName {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System (Default)';
    }
  }
}
