import 'package:flutter/material.dart';

class SettingsProvider with ChangeNotifier {
  bool _allNotifications = true;
  bool _pushAlerts = true;
  bool _appTips = false;
  bool _emergencyWarnings = true;

  bool get allNotifications => _allNotifications;
  bool get pushAlerts => _pushAlerts;
  bool get appTips => _appTips;
  bool get emergencyWarnings => _emergencyWarnings;

  void setAllNotifications(bool value) {
    _allNotifications = value;
    if (!value) {
      _pushAlerts = false;
      _appTips = false;
      _emergencyWarnings = false;
    }
    notifyListeners();
  }

  void setPushAlerts(bool value) {
    _pushAlerts = value;
    notifyListeners();
  }

  void setAppTips(bool value) {
    _appTips = value;
    notifyListeners();
  }

  void setEmergencyWarnings(bool value) {
    _emergencyWarnings = value;
    notifyListeners();
  }
}
