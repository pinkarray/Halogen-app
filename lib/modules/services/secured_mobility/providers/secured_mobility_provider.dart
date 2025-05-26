import 'package:flutter/material.dart';

class SecuredMobilityProvider extends ChangeNotifier {
  int _currentStage = 1;
  int get currentStage => _currentStage;

  double get progressPercent {
    double percent = 0.0;

    // Stage 1: Desired Services
    if (isTripSectionComplete) percent += 0.2;

    // Stage 2: Service Configuration
    percent += serviceConfigurationProgress; // weighted max 0.2

    // Stage 3: Schedule Service
    final scheduleComplete = pickupLocation != null &&
        dropoffLocation != null &&
        pickupDate != null &&
        pickupTime != null;
    if (scheduleComplete) percent += 0.2;

    // Stage 4: Confirm Order (optional logic could be added later)

    // Stage 5: Payment
    if (totalCost > 0) percent += 0.2;

    return percent.clamp(0.0, 1.0);
  }

  double get serviceConfigurationProgress {
    double progress = 0.0;

    final vehicle = serviceConfiguration['vehicle_choice'];
    final pilot = serviceConfiguration['pilot_vehicle'];
    final protection = serviceConfiguration['in_car_protection'];

    if (vehicle?['enabled'] == true && (vehicle?['selection'] ?? '').toString().isNotEmpty) {
      progress += 0.10;
    }

    if (pilot?['enabled'] == true && (pilot?['selection'] ?? '').toString().isNotEmpty) {
      progress += 0.03;
    }

    if (protection?['enabled'] == true && (protection?['selection'] ?? '').toString().isNotEmpty) {
      progress += 0.07;
    }

    return progress;
  }

  bool get isServiceConfigurationComplete => serviceConfigurationProgress >= 0.2;

  void initSelectedTrip() {
    if (selectedTripType == null) {
      pickupAddress = '';
      dropoffAddress = '';
      returnDropoffAddress = '';
      numberOfDays = null;
      interstateTravel = null;
      notifyListeners();
    }
  }

  void markStageComplete(int stage) {
    if (stage > _currentStage) {
      _currentStage = stage;
      notifyListeners();
    }
  }

  String? selectedTripType;
  String pickupAddress = '';
  String dropoffAddress = '';
  String returnDropoffAddress = '';
  int? numberOfDays;
  String? interstateTravel;

  String? get tripType => selectedTripType;

  void selectTripType(String type) {
    updateTripType(type);
  }

  void updateTripType(String type) {
    if (selectedTripType != type) {
      selectedTripType = type;

      if (type == 'One Way') {
        returnDropoffAddress = '';
        numberOfDays = null;
        interstateTravel = null;
      } else if (type == 'Return') {
        numberOfDays = null;
        interstateTravel = null;
      } else if (type == 'Fixed Duration') {
        returnDropoffAddress = '';
      }

      notifyListeners();
    }
  }

  void updateOneWayTrip({
    required String pickup,
    required String dropoff,
  }) {
    pickupAddress = pickup;
    dropoffAddress = dropoff;
    notifyListeners();
  }

  void updateReturnTrip({
    required String pickup,
    required String dropoff,
    required String returnDropoff,
  }) {
    pickupAddress = pickup;
    dropoffAddress = dropoff;
    returnDropoffAddress = returnDropoff;
    notifyListeners();
  }

  void updateFixedDurationTrip({
    required String pickup,
    required String dropoff,
    required int days,
    required String interstate,
  }) {
    pickupAddress = pickup;
    dropoffAddress = dropoff;
    numberOfDays = days;
    interstateTravel = interstate;
    notifyListeners();
  }

  bool get isTripSectionComplete {
    if (selectedTripType == 'One Way') {
      return pickupAddress.isNotEmpty && dropoffAddress.isNotEmpty;
    } else if (selectedTripType == 'Return') {
      return pickupAddress.isNotEmpty && dropoffAddress.isNotEmpty && returnDropoffAddress.isNotEmpty;
    } else if (selectedTripType == 'Fixed Duration') {
      return pickupAddress.isNotEmpty &&
          dropoffAddress.isNotEmpty &&
          numberOfDays != null &&
          interstateTravel != null;
    }
    return false;
  }

  Map<String, dynamic> toMap() => {
        'trip_type': selectedTripType,
        'pickup_address': pickupAddress,
        'dropoff_address': dropoffAddress,
        'return_dropoff_address': returnDropoffAddress,
        'number_of_days': numberOfDays,
        'interstate_travel': interstateTravel,
        'current_stage': _currentStage,
      };

  void loadFromMap(Map<String, dynamic> data) {
    selectedTripType = data['trip_type'] as String?;
    pickupAddress = data['pickup_address'] ?? '';
    dropoffAddress = data['dropoff_address'] ?? '';
    returnDropoffAddress = data['return_dropoff_address'] ?? '';
    numberOfDays = data['number_of_days'] is int ? data['number_of_days'] : int.tryParse('${data['number_of_days']}');
    interstateTravel = data['interstate_travel'] as String?;
    _currentStage = data['current_stage'] ?? 1;
    notifyListeners();
  }

  Map<String, Map<String, dynamic>> serviceConfiguration = {
    'vehicle_choice': {'enabled': false, 'selection': null},
    'pilot_vehicle': {'enabled': false, 'selection': null},
    'in_car_protection': {'enabled': false, 'selection': null},
  };

  void updateServiceConfig(String section, {required bool enabled, String? selection}) {
    if (!serviceConfiguration.containsKey(section)) return;
    serviceConfiguration[section]!['enabled'] = enabled;
    serviceConfiguration[section]!['selection'] = selection;
    notifyListeners();
  }

  String? pickupLocation;
  String? dropoffLocation;
  DateTime? pickupDate;
  TimeOfDay? pickupTime;

  void updateScheduleService({
    required String pickup,
    required String dropoff,
    required DateTime? date,
    required TimeOfDay? time,
  }) {
    pickupLocation = pickup;
    dropoffLocation = dropoff;
    pickupDate = date;
    pickupTime = time;
    notifyListeners();
  }

  int totalCost = 0;

  void calculateTotalCost() {
    int cost = 0;

    if (selectedTripType != null) {
      final tripCost = pricingMap['desired_services']?[selectedTripType];
      if (tripCost is int) cost += tripCost;
    }

    for (final section in ['vehicle_choice', 'pilot_vehicle', 'in_car_protection']) {
      final sectionData = serviceConfiguration[section];
      if (sectionData != null && sectionData['enabled'] == true) {
        final selected = sectionData['selection'];
        final sectionCost = pricingMap[section]?[selected];
        if (sectionCost is int) cost += sectionCost;
      }
    }

    totalCost = cost;
    notifyListeners();
  }

  final Map<String, Map<String, dynamic>> pricingMap = {
    'desired_services': {
      'One Way': 100000,
      'Return': 180000,
      'Fixed Duration': 250000,
    },
    'vehicle_choice': {
      'SUV': 500000,
      'Sedan': 300000,
    },
    'pilot_vehicle': {
      'Yes': 150000,
      'No': 0,
    },
    'in_car_protection': {
      'Unarmed - Closed Protection Officer': 200000,
      'Armed - LEA (Law Enforcement Agent)': 300000,
    },
  };
}