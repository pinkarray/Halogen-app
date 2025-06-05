import 'package:flutter/material.dart';
import 'package:halogen/security_profile/models/option_model.dart';
import 'package:halogen/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/question_model.dart';
import '../../../shared/helpers/session_manager.dart';

class SecurityProfileProvider with ChangeNotifier {
  final Map<String, List<QuestionModel>> _sectionQuestions = {};
  final Map<String, dynamic> _answers = {};
  final Set<int> completedChildIndices = {};

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

  Future<void> createOrFetchSecurityProfile() async {
    final token = await SessionManager.getAuthToken();
    final url = Uri.parse(baseUrl); // GET by default

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print('[SecurityProfile] Profile already exists.');
        return; 
      }

      final createResponse = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (createResponse.statusCode == 201) {
        print('[SecurityProfile] Profile created successfully');
      } else {
        print('[SecurityProfile] Creation failed: ${createResponse.body}');
      }
    } catch (e) {
      print('[SecurityProfile] Error: $e');
    }
  }


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

          final Map<String, QuestionModel> uniqueQuestions = {};

          for (final q in questionsJson) {
            final question = QuestionModel.fromJson(q);
            final ref = question.refCode.trim();
            if (uniqueQuestions.containsKey(ref)) {
              print('[DUPLICATE] $ref already exists in section $sectionCode');
            } else {
              uniqueQuestions[ref] = question;
            }
          }

          final questions = uniqueQuestions.values.toList();

          if (sectionCode == 'SP-PP') {
            const List<String> questionOrder = [
              'SP-PP-TT',
              'SP-PP-FN',
              'SP-PP-LN',
              'SP-PP-GD',
              'SP-PP-MS',
              'SP-PP-AG',
              'SP-PP-CC',
              'SP-PP-CC-NN',
              'SP-PP-CC-NN-AR',
              'SP-PP-CC-NN-SI',
            ];

            questions.sort((a, b) {
              final indexA = questionOrder.indexOf(a.refCode);
              final indexB = questionOrder.indexOf(b.refCode);
              if (indexA == -1 && indexB == -1) return 0;
              if (indexA == -1) return 1;
              if (indexB == -1) return -1;
              return indexA.compareTo(indexB);
            });
          }

          _sectionQuestions[sectionCode] = questions;
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
  
    // Update spouse toggle
    if (questionId == 'SP-PP-MS') {
      _showSpouseProfile = answer == 'Married';
    }
    
    notifyListeners();
  }

  // Keep only this implementation
  Future<bool> submitAnswer({
    required String questionId,
    String? optionId,
    required String value,
    required String label,
    Map<String, dynamic>? info,
  }) async {
    final token = await SessionManager.getAuthToken();
    final url = Uri.parse('$baseUrl/answers');

    final body = {
      "answers": [
        {
          "question_id": questionId,
          "option_id": optionId,
          "value": value,
          "label": label,
          "info": info ?? {}
        }
      ]
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('[submitAnswer] Answer sent successfully');
        return true;
      } else {
        print('[submitAnswer] Failed: ${response.body}');
        return false;
      }
    } catch (e) {
      print('[submitAnswer] Error: $e');
      return false;
    }
  }

  void removeAnswer(String questionId) {
    if (_answers.containsKey(questionId)) {
      _answers.remove(questionId);
      notifyListeners();
    }
  }

  // Future<void> submitAnswer({
  //   required String questionId,
  //   String? optionId,
  //   required String value,
  //   required String label,
  //   Map<String, dynamic>? info,
  // }) async {
  //   final token = await SessionManager.getAuthToken();
  //   final url = Uri.parse('$baseUrl/answers');

  //   final body = {
  //     "answers": [
  //       {
  //         "question_id": questionId,
  //         "option_id": optionId,
  //         "value": value,
  //         "label": label,
  //         "info": info ?? {}
  //       }
  //     ]
  //   };

  //   try {
  //     final response = await http.post(
  //       url,
  //       headers: {
  //         'Authorization': 'Bearer $token',
  //         'Content-Type': 'application/json',
  //       },
  //       body: json.encode(body),
  //     );

  //     if (response.statusCode == 201 || response.statusCode == 200) {
  //       print('[submitAnswer] Answer sent successfully');
  //     } else {
  //       print('[submitAnswer] Failed: ${response.body}');
  //     }
  //   } catch (e) {
  //     print('[submitAnswer] Error: $e');
  //   }
  // }

  Future<List<Map<String, dynamic>>> fetchSubmittedAnswers() async {
    final token = await SessionManager.getAuthToken();
    final url = Uri.parse('$baseUrl/answers');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'] as List<dynamic>;
        print('[fetchSubmittedAnswers] Retrieved ${data.length} answers');
        return data.cast<Map<String, dynamic>>();
      } else {
        print('[fetchSubmittedAnswers] Failed: ${response.body}');
        return [];
      }
    } catch (e) {
      print('[fetchSubmittedAnswers] Error: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> fetchSecurityReport() async {
    final token = await SessionManager.getAuthToken();
    final url = Uri.parse('$baseUrl/report');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final report = json.decode(response.body)['data'];
        print('[fetchSecurityReport] Success');
        return report;
      } else {
        print('[fetchSecurityReport] Failed: ${response.statusCode} - ${response.body}');
        
        // If report not found, it might be because answers haven't been processed yet
        if (response.statusCode == 404) {
          // Wait a moment and try again
          await Future.delayed(const Duration(seconds: 2));
          return fetchSecurityReport(); // Recursive call with retry
        }
        
        return null;
      }
    } catch (e) {
      print('[fetchSecurityReport] Error: $e');
      return null;
    }
  }

  void clearChildAnswersAbove(int count, List<QuestionModel> childQuestions) {
    // Removes answers and marks after a reduced child count
    completedChildIndices.removeWhere((i) => i >= count);
    for (int i = count; i < 20; i++) {
      for (var q in childQuestions) {
        final key = '${q.id}-$i';
        _answers.remove(key);
      }
    }
    notifyListeners();
  }

  void markChildCompleted(int index) {
    completedChildIndices.add(index);
    notifyListeners();
  }

  bool isChildCompleted(int index, List<QuestionModel> childQuestions) {
    for (var q in childQuestions) {
      final key = '${q.id}-$index';
      if (!_answers.containsKey(key) || _answers[key]!.toString().trim().isEmpty) {
        return false;
      }
    }
    return true;
  }

  final Set<int> completedCookIndices = {};
  final Set<int> completedNannyIndices = {};
  final Set<int> completedDriverIndices = {};
  final Set<int> completedGateManIndices = {};

  List<QuestionModel> get allQuestions {
    return _sectionQuestions.values.expand((qList) => qList).toList();
  }

  get profileProvider => null;

  List<QuestionModel> getAllOrderedQuestions(String sectionCode) {
    return _sectionQuestions[sectionCode] ?? [];
  }

  List<QuestionModel> getChildQuestions(String baseCode) {
    return _sectionQuestions.values
        .expand((qList) => qList)
        .where((q) => q.baseCode == baseCode)
        .toList();
  }

  void resetAnswers() {
    _answers.clear();
    completedChildIndices.clear();
    _showSpouseProfile = false;
    notifyListeners();
  }

  void clearCompletedIndicesAbove(int count, Set<int> indices) {
    indices.removeWhere((i) => i >= count);
  }
}


Future<bool> submitAllAnswers(dynamic answers) async {
  final token = await SessionManager.getAuthToken();
  final url = Uri.parse('$baseUrl/answers');

  // Convert answers map to the format expected by the API
  final List<Map<String, dynamic>> answersList = [];
  
  answers.forEach((questionId, value, dynamic sectionQuestions) {
    // Find the question to get its label
    QuestionModel? question;
    for (final section in sectionQuestions.values) {
      final found = section.firstWhere(
        (q) => q.id == questionId,
        orElse: () => QuestionModel.empty(),
      );
      if (found.id.isNotEmpty) {
        question = found;
        break;
      }
    }
    
    if (question != null && value != null && value.toString().isNotEmpty) {
      // For dropdown questions, find the option ID
      String? optionId;
      if (question.type == 'dropdown') {
        final option = question.options.firstWhere(
          (o) => o.label == value.toString(),
          orElse: () => OptionModel(id: '', label: '', score: 0),
        );
        if (option.id.isNotEmpty) {
          optionId = option.id;
        }
      }
      
      answersList.add({
        "question_id": questionId,
        "option_id": optionId,
        "value": value.toString(),
        "label": question.question,
        "info": {}
      });
    }
  });
  
  if (answersList.isEmpty) return true; // Nothing to submit
  
  final body = {"answers": answersList};
  
  try {
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(body),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      print('[submitAllAnswers] ${answersList.length} answers sent successfully');
      return true;
    } else {
      print('[submitAllAnswers] Failed: ${response.body}');
      return false;
    }
  } catch (e) {
    print('[submitAllAnswers] Error: $e');
    return false;
  }
}