import 'package:flutter/material.dart';

enum AccentColorOption { defaultColor, blue, green, yellow, pink, orange }

class ThemeManager with ChangeNotifier {
  // Singleton instance
  static final ThemeManager _instance = ThemeManager._internal();
  static ThemeManager get instance => _instance;

  ThemeManager._internal();

  ThemeMode _themeMode = ThemeMode.system;
  AccentColorOption _accentColor = AccentColorOption.defaultColor;

  ThemeMode get themeMode => _themeMode;
  AccentColorOption get accentColor => _accentColor;

  void setThemeMode(ThemeMode mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      notifyListeners();
    }
  }

  void setAccentColor(AccentColorOption color) {
    if (_accentColor != color) {
      _accentColor = color;
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

  String get accentColorName {
    switch (_accentColor) {
      case AccentColorOption.defaultColor: return 'Default';
      case AccentColorOption.blue: return 'Blue';
      case AccentColorOption.green: return 'Green';
      case AccentColorOption.yellow: return 'Yellow';
      case AccentColorOption.pink: return 'Pink';
      case AccentColorOption.orange: return 'Orange';
    }
  }

  Color getAccentColorValue(BuildContext context, {AccentColorOption? option}) {
    switch (option ?? _accentColor) {
      case AccentColorOption.defaultColor:
        //final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        return Colors.grey;
      case AccentColorOption.blue:
        return Colors.blueAccent;
      case AccentColorOption.green:
        return Colors.greenAccent;
      case AccentColorOption.yellow:
        return Colors.yellowAccent;
      case AccentColorOption.pink:
        return Colors.pinkAccent;
      case AccentColorOption.orange:
        return Colors.orangeAccent;
    }
  }
}
