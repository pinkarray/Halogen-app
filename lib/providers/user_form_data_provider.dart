import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import 'package:halogen/utils/string_utils.dart';
import '../shared/helpers/session_manager.dart';
import 'package:halogen/security_profile/providers/security_profile_provider.dart';


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

  String? get firstName => _firstName;
  String? get lastName => _lastName;
  String? get email => _email;
  String? get phoneNumber => _phoneNumber;
  String? get password => _password;
  String? get confirmationId => _confirmationId;

  int _currentSignUpStep = 1;
  int get currentSignUpStep => _currentSignUpStep;

  double stage1ProgressPercent = 0.0;

  bool isSectionComplete(String letter) {
    return _sections.containsKey(letter);
  }

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

  void _calculateStage1Progress() {
    int subSteps = 0;
    if (_firstName?.isNotEmpty == true) subSteps++;
    if (_lastName?.isNotEmpty == true) subSteps++;
    if (_email?.isNotEmpty == true) subSteps++;
    if (_password?.isNotEmpty == true) subSteps++;
    if (_phoneNumber?.isNotEmpty == true) subSteps++;
    if (isChecked) subSteps++;
    if (isOtpVerified) subSteps++;

    double rawProgress = (subSteps / 7) * 0.3;
    double roundedProgress = (rawProgress * 20).round() / 20; // rounds to nearest 0.05

    stage1ProgressPercent = roundedProgress;
  }

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

  void recheckAndUpdateSection(BuildContext context, String sectionCode) {
    final profile = context.read<SecurityProfileProvider>();
    Map<String, dynamic> sectionAnswers = {};

    switch (sectionCode) {
      case 'A':
        final fn = profile.answers['SP-PP-FN']?.toString().trim();
        final ln = profile.answers['SP-PP-LN']?.toString().trim();
        final ms = profile.answers['SP-PP-MS']?.toString().trim();
        final sfn = profile.answers['SP-SS-FN']?.toString().trim();
        final sln = profile.answers['SP-SS-LN']?.toString().trim();

        if (fn?.isNotEmpty == true && ln?.isNotEmpty == true && ms?.isNotEmpty == true) {
          final isSingle = ms!.toLowerCase() == 'single';
          if (isSingle || (sfn?.isNotEmpty == true || sln?.isNotEmpty == true)) {
            sectionAnswers = {
              'firstName': fn,
              'lastName': ln,
              'maritalStatus': ms,
              'spouseFirstName': sfn,
              'spouseLastName': sln,
            };
          }
        }
        break;

      case 'B':
        final hn = profile.answers['SP-HA-HN']?.toString().trim();
        final sn1 = profile.answers['SP-HA-SN1']?.toString().trim();
        final st = profile.answers['SP-HA-ST']?.toString().trim();
        final lga = profile.answers['SP-HA-LGA']?.toString().trim();

        if ([sn1, st].every((val) => val?.isNotEmpty == true)) {
          sectionAnswers = {
            if (hn?.isNotEmpty == true) 'houseNumber': hn,
            'streetName': sn1,
            'state': st,
            if (lga?.isNotEmpty == true) 'lga': lga,
          };
        }
        break;

      case 'C':
        final toh = profile.answers['SP-TOR-TOH']?.toString().trim();
        final geos = profile.answers['SP-TOR-GEOS']?.toString().trim();

        if (toh?.isNotEmpty == true) {
          sectionAnswers = {
            'typeOfHouse': toh,
            if (geos?.isNotEmpty == true) 'gatedEntry': geos,
          };
        }
        break;
        case 'D':
          final occ = profile.answers['SP-OCP-OCC']?.toString().trim();
          final motive = profile.answers['SP-OCP-OCC-MOT']?.toString().trim();
          final ol = profile.answers['SP-OCP-OCC-OL']?.toString().toLowerCase().trim();
          final state = profile.answers['SP-OCP-OCC-OL-ST']?.toString().trim();
          final lga = profile.answers['SP-OCP-OCC-OL-LGA']?.toString().trim();
          final area = profile.answers['SP-OCP-OCC-OL-AR']?.toString().trim();

          final isValid = occ?.isNotEmpty == true &&
            motive?.isNotEmpty == true &&
            (ol != 'work outside the home' ||
            (state?.isNotEmpty == true && lga?.isNotEmpty == true && area?.isNotEmpty == true));

          if (isValid) {
            sectionAnswers = {
              'occupation': occ,
              'motive': motive,
              'officeState': state,
              'officeLga': lga,
              'officeArea': area,
            };
          }
          break;

        case 'F':
          final sop = ['SP-SOP-CMN', 'SP-SOP-NLS', 'SP-SOP-ISTP'];
          final filled = sop.every((code) =>
            profile.answers[code]?.toString().trim().isNotEmpty == true
          );

          if (filled) {
            sectionAnswers = {
              for (var code in sop) code: profile.answers[code]
            };
          }
          break;

        case 'G':
          final pp = profile.answers['SP-OTH-PP']?.toString().trim();
          final pm = profile.answers['SP-OTH-PM']?.toString().trim();

          if (pp?.isNotEmpty == true && pm?.isNotEmpty == true) {
            sectionAnswers = {
              'fatherStatus': pp,
              'motherStatus': pm,
            };
          }
          break;
      }

      if (sectionAnswers.isNotEmpty) {
        updateSection(sectionCode, sectionAnswers);
      }
    }

  Map<String, dynamic> toJson() => _sections;

  void loadFromJson(Map<String, dynamic> json) {
    _sections = json;
    notifyListeners();
  }

  int _onboardingStage = 0;

  int get onboardingStage => _onboardingStage;

  void setOnboardingStage(int stage) {
    _onboardingStage = stage;
    notifyListeners();
  }

  double get stage2Progress {
    const total = 6; 
    final completed = allSections.keys.where((k) => k != "E").length;
    final percent = completed / total;
    return (0.3 + percent * 0.7).clamp(0.3, 1.0);
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

  Future<void> hydrateFromSession() async {
    final user = await SessionManager.getUserModel();
    final stage = await SessionManager.getStage();

    if (user != null) {
      final names = user.fullName.split(" ");
      _firstName = names.first;
      _lastName = names.length > 1 ? names.sublist(1).join(" ") : "";
      _email = user.email;
      _phoneNumber = user.phoneNumber;
    }

    _onboardingStage = stage;
    notifyListeners();
  }

}
