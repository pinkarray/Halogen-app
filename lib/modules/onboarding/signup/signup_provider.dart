import 'package:flutter/material.dart';
import '../../../models/user_model.dart';
class SignUpProvider with ChangeNotifier {
  // User input fields
  String firstName = '';
  String lastName = '';
  String email = '';
  String password = '';
  String confirmPassword = '';

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

    try {
      await Future.delayed(const Duration(milliseconds: 800));
      return true;
    } catch (e) {
      errorMessage = 'Something went wrong. Try again.';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  UserModel toUserModel() {
    return UserModel(
      fullName: "$firstName $lastName",
      email: email,
      phoneNumber: '', // Add this if you collect it later
      type: 'client',  // Or dynamic role logic
    );
  }
}
