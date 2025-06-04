import 'package:halogen/services/profile_api_service.dart';
import 'package:halogen/shared/helpers/session_manager.dart';
import 'package:flutter/material.dart';

class ProfileProvider extends ChangeNotifier {
  Map<String, dynamic>? _user;

  Map<String, dynamic>? get user => _user;

  bool get isLoaded => _user != null;

  Future<void> loadUser() async {
    try {
      final profile = await ProfileApiService.getProfile();
      await SessionManager.saveUserProfile(profile); // optional
      _user = profile;
      notifyListeners();
    } catch (e) {
      print('❌ Failed to load profile: $e');
    }
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
    try {
      final token = await SessionManager.getAuthToken();

      // Attempt API logout only if token exists (from actual login)
      if (token != null) {
        await ProfileApiService.logout(token);
      }

      // Always clear local session and state
      await SessionManager.clearSession();
      clear();

      // Optional: also clear secure storage
      // await SecureStorageService().clearCredentials();

      return true;
    } catch (e) {
      print('❌ Logout error: $e');

      // Still clear session locally even if logout API fails
      await SessionManager.clearSession();
      clear();

      return true;
    }
  }
}