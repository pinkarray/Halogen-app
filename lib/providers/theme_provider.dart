import 'package:flutter/material.dart';

enum AppThemeMode { light, dark, system }

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  void setTheme(AppThemeMode mode) {
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
