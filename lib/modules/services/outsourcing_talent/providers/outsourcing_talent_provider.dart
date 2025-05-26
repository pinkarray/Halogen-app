import 'package:flutter/material.dart';

class OutsourcingTalentProvider extends ChangeNotifier {
  final Map<String, bool> _completedSections = {
    'domestic_staff': false,
    'business_staff': false,
    'background_checks': false,
    'investigation': false,
    'lea_liaison': false,
  };

  final Map<String, Map<String, dynamic>> _sectionDetails = {};

  bool _stage2Completed = false;
  bool _stage3Completed = false;

  // ✅ Section methods
  void markSectionComplete(String key) {
    _completedSections[key] = true;
    notifyListeners();
  }

  void unmarkSection(String key) {
    _completedSections[key] = false;
    _sectionDetails.remove(key);
    notifyListeners();
  }

  void updateSectionDetails(String key, Map<String, dynamic> data) {
    _sectionDetails[key] = data;
    _completedSections[key] = true;
    notifyListeners();
  }

  bool isSectionComplete(String key) => _completedSections[key] ?? false;

  Map<String, Map<String, dynamic>> get allSectionDetails => _sectionDetails;

  double get stage1ProgressPercent {
    int completed = _completedSections.values.where((v) => v).length;
    int total = _completedSections.length;
    return total > 0 ? completed / total : 0.0;
  }

  bool get stage1Completed => _completedSections.values.any((v) => v == true);

  int get currentStage {
    if (!_stage2Completed) return 1;
    if (!_stage3Completed) return 2;
    return 3;
  }

  bool get isAnyDesiredServiceSelected {
    const keys = [
      'domestic_staff',
      'business_staff',
      'background_checks',
      'investigation',
      'lea_liaison',
    ];
    return keys.any((key) => _completedSections[key] == true);
  }

  // ✅ Stage tracking
  bool get stage2Completed => _stage2Completed;
  bool get stage3Completed => _stage3Completed;

  void markStage2Completed() {
    _stage2Completed = true;
    notifyListeners();
  }

  void markStage3Completed() {
    _stage3Completed = true;
    notifyListeners();
  }

  void resetAllStages() {
    _completedSections.updateAll((_, __) => false);
    _sectionDetails.clear();
    _stage2Completed = false;
    _stage3Completed = false;
    notifyListeners();
  }

  Map<String, dynamic> toRequestPayload({required String pin}) {
    final List<Map<String, dynamic>> questions = [];

    _sectionDetails.forEach((sectionKey, details) {
      details.forEach((key, value) {
        if (key != 'completed') {
          final label = _humanizeKey(sectionKey, key);
          questions.add({
            'question': label,
            'answer': value,
          });
        }
      });
    });

    // Add optional description from stage 2
    if (_sectionDetails['description']?['text'] != null &&
        _sectionDetails['description']!['text'].toString().trim().isNotEmpty) {
      questions.add({
        'question': 'Description of need',
        'answer': _sectionDetails['description']!['text'],
      });
    }

    return {
      'pin': pin,
      'ref_code': 'SS-OM',
      'info': {
        'questions': questions,
      },
    };
  }

  String _humanizeKey(String section, String key) {
    final map = {
      'domestic_staff': 'Domestic Staff',
      'business_staff': 'Business Staff',
      'background_checks': 'Background Check',
      'investigation': 'Investigation',
      'lea_liaison': 'LEA Liaison',
    };

    final sectionName = map[section] ?? section;
    final fieldName = key.replaceAll('_', ' ').toLowerCase();
    return '$sectionName – ${fieldName[0].toUpperCase()}${fieldName.substring(1)}';
  }
}