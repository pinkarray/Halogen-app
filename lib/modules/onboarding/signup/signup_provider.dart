import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../models/user_model.dart';
class SignUpProvider with ChangeNotifier {
  // User input fields
  String firstName = '';
  String lastName = '';
  String email = '';
  String password = '';
  String confirmPassword = '';
  String phoneNumber = '';

  // State flags
  bool isChecked = false;
  bool isLoading = false;
  String? errorMessage;

  // Max sub-steps for this screen (used for calculating % of 20%)
  final int _maxSubSteps = 7;

  // Update input fields
  void updateFirstName(String value) {
    firstName = value;
    notifyListeners();
  }

  void updateLastName(String value) {
    lastName = value;
    notifyListeners();
  }

  void updateEmail(String value) {
    email = value;
    notifyListeners();
  }

  void updatePassword(String value) {
    password = value;
    notifyListeners();
  }

  void updateConfirmPassword(String value) {
    confirmPassword = value;
    notifyListeners();
  }

  void toggleCheckbox(bool? value) {
    isChecked = value ?? false;
    notifyListeners();
  }

  void updatePhoneNumber(String value) {
    phoneNumber = value;
    notifyListeners();
  }


  // Progress logic: return count of substeps completed (max 7)
  int get subStepCount {
    int step = 0;
    if (firstName.trim().isNotEmpty) step++;
    if (lastName.trim().isNotEmpty) step++;
    if (email.trim().isNotEmpty) step++;
    if (password.isNotEmpty) step++;
    if (confirmPassword.isNotEmpty) step++;
    if (password == confirmPassword && password.isNotEmpty) step++;
    if (isChecked) step++;
    return step;
  }

  // Return the actual percent of this screen (0–20)
  double get percentOfStage1 {
    return (subStepCount / _maxSubSteps) * 20; // screen contributes up to 20%
  }

  bool get isFormValid => subStepCount == _maxSubSteps;

  String? validateForm() {
    if (firstName.isEmpty ||
        lastName.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      return 'Please fill all fields';
    }

    if (password != confirmPassword) {
      return 'Passwords do not match';
    }

    if (!isChecked) {
      return 'Please accept the terms';
    }

    return null;
  }

  Future<bool> submitForm() async {
    final error = validateForm();
    if (error != null) {
      errorMessage = error;
      notifyListeners();
      return false;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final user = UserModel(
      fullName: "$firstName $lastName",
      email: email,
      password: password,
      type: 'client', 
      phoneNumber: phoneNumber,
    );

    final url = Uri.parse('http://185.203.216.113:3004/api/v1/auth/register'); 

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "full_name": user.fullName,
          "email": user.email,
          "phone_number": user.phoneNumber,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        final responseBody = jsonDecode(response.body);
        errorMessage = responseBody['message'] ?? 'Signup failed';
        return false;
      }
    } catch (e) {
      errorMessage = 'Network error: $e';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

}
