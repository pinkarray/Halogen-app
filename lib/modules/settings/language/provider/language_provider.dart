import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider with ChangeNotifier {
  // Always return English locale
  Locale get currentLocale => const Locale('en');

  // Keep this method but make it do nothing
  Future<void> loadSavedLocale() async {
    // Do nothing
  }

  // Keep this method but make it do nothing
  Future<void> setLocale(Locale locale) async {
    // Do nothing
  }
}
