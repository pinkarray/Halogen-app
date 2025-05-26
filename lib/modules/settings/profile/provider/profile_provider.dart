import 'package:halogen/services/profile_api_service.dart';
import 'package:halogen/shared/helpers/session_manager.dart';
import 'package:flutter/material.dart';

class ProfileProvider extends ChangeNotifier {
  Map<String, dynamic>? _user;

  Map<String, dynamic>? get user => _user;

  bool get isLoaded => _user != null;

  Future<void> loadUser() async {
    final profile = await SessionManager.getUserProfile();
    _user = profile;
    notifyListeners();
  }

  void updateField(String key, dynamic value) {
    if (_user != null) {
      _user![key] = value;
      notifyListeners();
    }
  }

  void setUser(Map<String, dynamic> newUser) {
    _user = newUser;
    notifyListeners();
  }

  void clear() {
    _user = null;
    notifyListeners();
  }

  Future<bool> logout() async {
    final token = await SessionManager.getAuthToken();
    if (token == null) return false;

    final success = await ProfileApiService.logout(token);
    if (success) {
      await SessionManager.clearSession();
      clear();
    }
    return success;
  }
}