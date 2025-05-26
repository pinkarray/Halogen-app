import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/question_model.dart';
import '../../../shared/helpers/session_manager.dart';

class SecurityProfileProvider with ChangeNotifier {
  final Map<String, List<QuestionModel>> _sectionQuestions = {};
  final Map<String, dynamic> _answers = {};

  bool _showSpouseProfile = false;
  bool _isLoading = false;

  Map<String, List<QuestionModel>> get sectionQuestions => _sectionQuestions;
  Map<String, dynamic> get answers => _answers;
  bool get showSpouseProfile => _showSpouseProfile;
  bool get isLoading => _isLoading;

  set showSpouseProfile(bool value) {
    _showSpouseProfile = value;
    notifyListeners();
  }

  final String baseUrl = 'http://185.203.216.113:3004/api/v1/security-profile';

  Future<void> fetchQuestions() async {
    _isLoading = true;
    notifyListeners();

    final url = Uri.parse('$baseUrl/questions');
    final token = await SessionManager.getAuthToken();

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('[fetchQuestions] Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'];
        print('[fetchQuestions] Sections returned: ${data.length}');

        _sectionQuestions.clear();

        for (final section in data) {
          final sectionCode = section['ref_code'];
          final questionsJson = section['questions'] as List;

          final questions = questionsJson
              .map((q) => QuestionModel.fromJson(q))
              .toList();

          print('[Section: $sectionCode] Loaded ${questions.length} questions');

          _sectionQuestions[sectionCode] = questions;

          if (sectionCode == 'SP-PP') {
            const List<String> questionOrder = [
              'SP-PP-TT',
              'SP-PP-FN',
              'SP-PP-LN',
              'SP-PP-GD',
              'SP-PP-MS',
              'SP-PP-AG',
            ];

            _sectionQuestions[sectionCode]!.sort((a, b) {
              final indexA = questionOrder.indexOf(a.refCode);
              final indexB = questionOrder.indexOf(b.refCode);

              if (indexA == -1 && indexB == -1) return 0;
              if (indexA == -1) return 1;
              if (indexB == -1) return -1;
              return indexA.compareTo(indexB);
            });
          }
        }
      } else {
        print('[fetchQuestions] Failed with body: ${response.body}');
        throw Exception('Failed to load questions');
      }
    } catch (e) {
      print('[fetchQuestions] Error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void saveAnswer(String questionId, dynamic answer) {
    _answers[questionId] = answer;

    if (questionId == 'SP-PP-MS') {
      _showSpouseProfile = answer == 'Married';
    }

    notifyListeners();
  }
}