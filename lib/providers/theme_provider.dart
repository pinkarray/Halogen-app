import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode { light, dark, system }

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  
  ThemeProvider() {
    loadSavedTheme();
  }

  ThemeMode get themeMode => _themeMode;

  Future<void> loadSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString('theme_mode') ?? 'system';
    
    switch (themeString) {
      case 'light':
        _themeMode = ThemeMode.light;
        break;
      case 'dark':
        _themeMode = ThemeMode.dark;
        break;
      default:
        _themeMode = ThemeMode.system;
    }
    notifyListeners();
  }

  Future<void> setTheme(AppThemeMode mode) async {
    switch (mode) {
      case AppThemeMode.light:
        _themeMode = ThemeMode.light;
        break;
      case AppThemeMode.dark:
        _themeMode = ThemeMode.dark;
        break;
      case AppThemeMode.system:
        _themeMode = ThemeMode.system;
        break;
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', _themeMode.toString().split('.').last);
    
    notifyListeners();
  }

  AppThemeMode get currentAppTheme {
    switch (_themeMode) {
      case ThemeMode.light:
        return AppThemeMode.light;
      case ThemeMode.dark:
        return AppThemeMode.dark;
      case ThemeMode.system:
        return AppThemeMode.system;
    }
  }
}