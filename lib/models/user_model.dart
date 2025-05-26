import '../providers/user_form_data_provider.dart';
import '../modules/onboarding/signup/signup_provider.dart';

class UserModel {
  final String fullName;
  final String email;
  final String phoneNumber;
  final String type;

  UserModel({
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.type,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      type: json['type'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'type': type,
    };
  }

  /// Extract first and last name assuming space split
  String get firstName => fullName.split(" ").first;
  String get lastName => fullName.split(" ").skip(1).join(" ");

  /// Autofill method for SignUpProvider
  void autofillSignUp(SignUpProvider provider) {
    provider.updateFirstName(firstName);
    provider.updateLastName(lastName);
    provider.updateEmail(email);
    provider.updateConfirmPassword(''); // reset
    provider.updatePassword('');        // reset
    provider.toggleCheckbox(true);      // assume consent
  }

  /// Autofill method for UserFormDataProvider
  void autofillUserForm(UserFormDataProvider provider) {
    provider.updateFirstName(firstName);
    provider.updateLastName(lastName);
    provider.updateEmail(email);
    provider.updatePhone(phoneNumber);
  }
}
