import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../models/login_result.dart';
import '../../models/user_model.dart';

class LoginProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<LoginResult> login({
    required String phoneNumber,
    required String password,
    required String deviceId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await loginUser(
        phoneNumber: phoneNumber,
        password: password,
        deviceId: deviceId,
      );

      debugPrint("✅ Login successful: $response");

      final data = response['data'];

      _isLoading = false;
      notifyListeners();

      return LoginResult(
        success: response['success'] == true,
        token: data['token'],
        user: UserModel.fromJson(data['user']),
        deviceId: deviceId, // Still optional, adjust if needed
      );
    } catch (e) {
      if (e.toString().contains("SocketException")) {
        _errorMessage = "Network connection failed. Please check your internet.";
      } else {
        _errorMessage = "Login failed. Please try again.";
      }
      _isLoading = false;
      notifyListeners();
      return LoginResult(success: false);
    }
  }
}
