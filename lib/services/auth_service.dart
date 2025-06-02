import 'dart:convert';
import 'package:http/http.dart' as http;

const String baseUrl = "http://185.203.216.113:3004/api/v1";

// 1️⃣ Register – Just triggers OTP
Future<Map<String, dynamic>> registerUser({
  required String fullName,
  required String phoneNumber,
  required String email,
}) async {
  final url = Uri.parse('$baseUrl/auth/register');

  final body = {
    "full_name": fullName,
    "phone_number": phoneNumber,
    "email": email,
  };

  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(body),
  );

  return _handleResponse(response);
}

// 2️⃣ Confirm OTP – Returns confirmation_id (IMPORTANT!)
Future<Map<String, dynamic>> confirmOtp({
  required String phoneNumber,
  required String otp,
}) async {
  final url = Uri.parse('$baseUrl/auth/confirm-otp');

  final body = {
    "otp": otp,
    "phone_number": phoneNumber,
  };

  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(body),
  );

  return _handleResponse(response);
}

// 3️⃣ Create Password – Completes registration
Future<Map<String, dynamic>> createPassword({
  required String confirmationId,
  required String password,
}) async {
  final url = Uri.parse('$baseUrl/auth/create-password');

  final body = {
    "confirmation_id": confirmationId,
    "password": password,
  };

  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(body),
  );

  return _handleResponse(response);
}

// ➕ Optional: Resend OTP
Future<Map<String, dynamic>> sendOtp({
  required String phoneNumber,
}) async {
  final url = Uri.parse('$baseUrl/auth/send-otp');

  final body = {"phone_number": phoneNumber};

  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(body),
  );

  return _handleResponse(response);
}

// 🔐 Login
Future<Map<String, dynamic>> loginUser({
  required String phoneNumber,
  required String password,
  required String deviceId,
}) async {
  final url = Uri.parse('$baseUrl/auth/login');

  final body = {
    "phone_number": phoneNumber,
    "password": password,
    "device_id": deviceId,
  };

  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(body),
  );

  return _handleResponse(response);
}

// 📲 Register Device
Future<Map<String, dynamic>> registerDevice({
  required String deviceToken,
  required String deviceType,
  required Map<String, dynamic> deviceData,
  required Map<String, dynamic> appData,
}) async {
  final url = Uri.parse('$baseUrl/device');

  final body = {
    "device_token": deviceToken,
    "device_type": deviceType,
    "device_data": deviceData,
    "app_data": appData,
  };

  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(body),
  );

  return _handleResponse(response);
}

Map<String, dynamic> _handleResponse(http.Response response) {
  final decoded = jsonDecode(response.body);

  if (response.statusCode >= 200 && response.statusCode < 300) {
    return decoded;
  } else {
    final message = decoded['message']?.toLowerCase() ?? '';

    if (response.request != null &&
        response.request!.url.path.contains('/login') &&
        (message.contains('incorrect') || message.contains('invalid'))) {
      throw Exception('Incorrect username or password.');
    }

    // Use backend message for all other failures
    throw Exception(decoded['message'] ?? 'An unexpected error occurred.');
  }
}
