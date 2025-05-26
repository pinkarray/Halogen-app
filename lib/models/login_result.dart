import 'user_model.dart';

class LoginResult {
  final bool success;
  final String? token;
  final UserModel? user;
  final String? deviceId;

  LoginResult({
    required this.success,
    this.token,
    this.user,
    this.deviceId,
  });
}
