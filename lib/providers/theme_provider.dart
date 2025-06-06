import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode { light, dark, system }

class ThemeProvider with ChangeNotifier {
  // Always return light theme mode regardless of saved preferences
  ThemeMode get themeMode => ThemeMode.light;
  
  // Keep this method but make it do nothing
  Future<void> loadSavedTheme() async {
    // Do nothing
  }

  // Keep this method but make it do nothing
  Future<void> setTheme(AppThemeMode mode) async {
    // Do nothing
  }

  // Always return light theme
  AppThemeMode get currentAppTheme => AppThemeMode.light;
}