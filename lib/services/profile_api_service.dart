import 'package:http/http.dart' as http;

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

  // Future methods for emergency contacts, profile updates etc. will go here.
}