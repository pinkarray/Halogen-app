import 'package:flutter/material.dart';

class PhysicalSecurityProvider extends ChangeNotifier {
  // Site inspection data
  DateTime? preferredDate;
  TimeOfDay? preferredTime;
  String houseNumber = '';
  String streetName = '';
  String area = '';
  String state = '';
  bool addressConfirmed = false;
  String confirmedMapAddress = '';

  bool _requestSent = false;
  bool get requestSent => _requestSent;

  void markRequestSent() {
    _requestSent = true;
    notifyListeners();
  }

  double get progressPercent {
    double progress = 0.0;

    // 1. Site Inspection Progress (max 30%)
    int filled = 0;
    if (preferredDate != null) filled++;
    if (preferredTime != null) filled++;
    if (houseNumber.isNotEmpty) filled++;
    if (streetName.isNotEmpty) filled++;
    if (area.isNotEmpty) filled++;
    if (state.isNotEmpty) filled++;
    if (addressConfirmed) filled++;
    progress += (filled * 0.05).clamp(0.0, 0.35); // 5% per field = 30% max


    // 2. Desired Services Jump to 65% if any valid selection exists
    bool hasStructured = structuredSelections.values.any((groupMap) {
      return groupMap.values.any((catMap) => catMap.values.any((val) => val.isNotEmpty));
    });

    bool hasFlat = flatSelections.values.any((val) => val.isNotEmpty);

    if (hasStructured || hasFlat) {
      progress = progress < 0.65 ? 0.65 : progress;
    }

    // 3. Final Completion
    if (_requestSent) {
      progress = 1.0;
    }

    return progress;
  }

  // Desired services data
  final Set<String> selectedServices = {};
  final Map<String, Map<String, Map<String, String>>> structuredSelections = {};
  final Map<String, String> flatSelections = {};

  // Update site inspection form data
  void updateInspectionData({
    DateTime? date,
    TimeOfDay? time,
    String? houseNum,
    String? street,
    String? areaText,
    String? stateText,
    bool? confirmed,
    String? mapAddress,
  }) {
    preferredDate = date ?? preferredDate;
    preferredTime = time ?? preferredTime;
    houseNumber = houseNum ?? houseNumber;
    streetName = street ?? streetName;
    area = areaText ?? area;
    state = stateText ?? state;
    if (confirmed != null) addressConfirmed = confirmed;
    if (mapAddress != null) confirmedMapAddress = mapAddress;

    notifyListeners();
  }

  // Getter for step completion
  bool get isFormComplete {
    return preferredDate != null &&
        preferredTime != null &&
        houseNumber.isNotEmpty &&
        streetName.isNotEmpty &&
        area.isNotEmpty &&
        state.isNotEmpty &&
        addressConfirmed;
  }

  // Mark a service as selected
  void markServiceComplete(String serviceName) {
    if (!selectedServices.contains(serviceName)) {
      selectedServices.add(serviceName);
      notifyListeners();
    }
  }

  // Store structured selections like { group: { category: value } }
  void updateStructuredSelection(String service, String group, String category, String value) {
    structuredSelections[service] ??= {};
    structuredSelections[service]![group] ??= {};
    structuredSelections[service]![group]![category] = value;

    markServiceComplete(service);
    notifyListeners();
  }

  // Store flat selections like { "Alarm": "Selected Option" }
  void updateFlatSelection(String service, String value) {
    flatSelections[service] = value;
    markServiceComplete(service);
    notifyListeners();
  }

  bool get allServicesSelected => selectedServices.length == 5;

  Map<String, dynamic> toMap() => {
        'preferred_date': preferredDate?.toIso8601String(),
        'preferred_time': preferredTime != null
            ? '${preferredTime!.hour.toString().padLeft(2, '0')}:${preferredTime!.minute.toString().padLeft(2, '0')}'
            : null,
        'house_number': houseNumber,
        'street_name': streetName,
        'area': area,
        'state': state,
        'address_confirmed': addressConfirmed,
        'confirmed_map_address': confirmedMapAddress,
        'selected_services': selectedServices.toList(),
        'structured_selections': structuredSelections,
        'flat_selections': flatSelections,
      };
}