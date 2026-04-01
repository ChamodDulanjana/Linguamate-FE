import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    
    final themeIndex = prefs.getInt('theme_mode');
    if (themeIndex != null && themeIndex >= 0 && themeIndex < ThemeMode.values.length) {
      _themeMode = ThemeMode.values[themeIndex];
    }
    
    final accentIndex = prefs.getInt('accent_color');
    if (accentIndex != null && accentIndex >= 0 && accentIndex < AccentColorOption.values.length) {
      _accentColor = AccentColorOption.values[accentIndex];
    }
    
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode != mode) {
      _themeMode = mode;
      notifyListeners();
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('theme_mode', mode.index);
    }
  }

  Future<void> setAccentColor(AccentColorOption color) async {
    if (_accentColor != color) {
      _accentColor = color;
      notifyListeners();
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('accent_color', color.index);
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
