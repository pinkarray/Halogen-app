import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final _storage = const FlutterSecureStorage();

  Future<void> saveUserCredentials(String phoneNumber, String password) async {
    await _storage.write(key: 'user_phone', value: phoneNumber);
    await _storage.write(key: 'user_password', value: password);
  }

  Future<Map<String, String?>> getUserCredentials() async {
    final phone = await _storage.read(key: 'user_phone');
    final password = await _storage.read(key: 'user_password');
    return {'phone': phone, 'password': password};
  }

  Future<void> clearCredentials() async {
    await _storage.delete(key: 'user_phone');
    await _storage.delete(key: 'user_password');
  }
}
