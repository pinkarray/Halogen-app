import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import 'package:halogen/utils/string_utils.dart';

class UserFormDataProvider extends ChangeNotifier {
  Map<String, dynamic> _sections = {};

  // Stage flags
  bool stage2Completed = false;
  bool stage3Completed = false;
  bool isFullyRegistered = false;
  bool isOtpVerified = false;
  bool isChecked = false;

  // Core onboarding info
  String? _firstName;
  String? _lastName;
  String? _email;
  String? _phoneNumber;
  String? _password;
  String? _confirmationId;

  // Exposed getters
  String? get firstName => _firstName;
  String? get lastName => _lastName;
  String? get email => _email;
  String? get phoneNumber => _phoneNumber;
  String? get password => _password;
  String? get confirmationId => _confirmationId;

  // Current screen step for animation/page tracking
  int _currentSignUpStep = 1;
  int get currentSignUpStep => _currentSignUpStep;

  // % progress for stage 1 (signup flow)
  double stage1ProgressPercent = 0.0;

  // ─────────────────────────────
  // ✅ UPDATE METHODS
  // ─────────────────────────────

  void updateFirstName(String val) {
    _firstName = val.trim();
    _calculateStage1Progress();
    notifyListeners();
  }

  void updateLastName(String val) {
    _lastName = val.trim();
    _calculateStage1Progress();
    notifyListeners();
  }

  void updateEmail(String val) {
    _email = val.trim();
    _calculateStage1Progress();
    notifyListeners();
  }

  void updatePassword(String val) {
    _password = val;
    _calculateStage1Progress();
    notifyListeners();
  }

  void updatePhone(String val) {
    _phoneNumber = val.trim();
    _calculateStage1Progress();
    notifyListeners();
  }

  void toggleCheckbox(bool? value) {
    isChecked = value ?? false;
    _calculateStage1Progress();
    notifyListeners();
  }

  void markOtpVerified() {
    isOtpVerified = true;
    _calculateStage1Progress();
    notifyListeners();
  }

  void updateSignUpStep(int step) {
    _currentSignUpStep = step;
    notifyListeners();
  }

  void saveConfirmationId(String id) {
    _confirmationId = id;
    notifyListeners();
  }

  void markFullyRegistered() {
    isFullyRegistered = true;
    notifyListeners();
  }

  // ─────────────────────────────
  // ✅ STAGE 1 LOGIC
  // ─────────────────────────────

  void _calculateStage1Progress() {
    int subSteps = 0;
    if (_firstName?.isNotEmpty == true) subSteps++;
    if (_lastName?.isNotEmpty == true) subSteps++;
    if (_email?.isNotEmpty == true) subSteps++;
    if (_password?.isNotEmpty == true) subSteps++;
    if (_phoneNumber?.isNotEmpty == true) subSteps++;
    if (isChecked) subSteps++;
    if (isOtpVerified) subSteps++;

    // Round to nearest 5% of 0.3 (e.g., 0.20, 0.25, 0.30)
    double rawProgress = (subSteps / 7) * 0.3;
    double roundedProgress = (rawProgress * 20).round() / 20; // rounds to nearest 0.05

    stage1ProgressPercent = roundedProgress;
  }

  // ─────────────────────────────
  // OTHER SHARED STRUCTURE
  // ─────────────────────────────

  Map<String, dynamic> get allSections => _sections;

  void updateSection(String key, Map<String, dynamic> values) {
    _sections[key] = values;
    notifyListeners();
  }

  void resetOnboardingInfo() {
    _firstName = null;
    _lastName = null;
    _email = null;
    _password = null;
    _phoneNumber = null;
    _confirmationId = null;
    isOtpVerified = false;
    isChecked = false;
    stage1ProgressPercent = 0.0;
    notifyListeners();
  }

  void reset() {
    _sections.clear();
    resetOnboardingInfo();
  }

  Map<String, dynamic> toJson() => _sections;

  void loadFromJson(Map<String, dynamic> json) {
    _sections = json;
    notifyListeners();
  }

  UserModel toUserModel() {
    final rawFullName = "${_firstName?.trim() ?? ''} ${_lastName?.trim() ?? ''}";
    final formattedName = capitalizeEachWord(rawFullName);

    return UserModel(
      fullName: formattedName,
      email: _email?.trim() ?? '',
      phoneNumber: _phoneNumber?.trim() ?? '',
      type: 'client',
    );
  }
}
