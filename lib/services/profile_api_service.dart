import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:halogen/shared/helpers/session_manager.dart';

class ProfileApiService {
  static const String _baseUrl = 'http://185.203.216.113:3004/api/v1';

  static Future<bool> logout(String token) async {
    final url = Uri.parse('$_baseUrl/auth/logout');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    return response.statusCode == 200;
  }

  static Future<Map<String, dynamic>> getProfile() async {
    final token = await SessionManager.getAuthToken();
    final url = Uri.parse('$_baseUrl/profile');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = json.decode(response.body);
      return body['data'] ?? {}; // Adjust based on your backend's response structure
    } else {
      throw Exception('Failed to load profile: ${response.statusCode}');
    }
  }
}