import 'package:flutter/material.dart';
import 'package:halogen/security_profile/providers/security_profile_provider.dart';
import 'package:provider/provider.dart';
import '../../../providers/user_form_data_provider.dart';

import '../../../shared/widgets/custom_progress_bar.dart';
import '../../../shared/helpers/session_manager.dart';
import '../../../security_profile/widgets/dynamic_question_widget.dart';
import '../../../security_profile/models/question_model.dart';
import './security_report_screen.dart';

class ContinueRegistrationScreen extends StatefulWidget {
  const ContinueRegistrationScreen({super.key});

  @override
  State<ContinueRegistrationScreen> createState() =>
      _ContinueRegistrationScreenState();
}

class _ContinueRegistrationScreenState
    extends State<ContinueRegistrationScreen> {
  final List<String> sectionTitles = const [
    "Profile",
    "Home Address",
    "Type of Residence",
    "Occupation",
    "Domestic Support",
    "Socials",
    "Others",
  ];

  int? expandedIndex;
  bool _isInitializing = true;

  List<Widget> _buildProfileQuestions(BuildContext context) {
    final provider = context.watch<SecurityProfileProvider>();
    final formProvider = context.read<UserFormDataProvider>();
    final allQuestions = provider.getAllOrderedQuestions('SP-PP');

    final excludedRefCodes = [
      'sp-pp-cc-nn',
      'sp-pp-cc-nc',
      'sp-pp-cc-ns',
      'sp-11',
    ];

    final nonLooping =
        allQuestions.where((q) {
          final ref = q.refCode.trim().toLowerCase();
          final base = q.baseCode.trim().toLowerCase();
          return !excludedRefCodes.contains(ref) && base != 'sp-pp-cc-nn';
        }).toList();

    final numberOfChildrenQuestion = allQuestions.firstWhere(
      (q) => q.refCode == 'SP-PP-CC-NN',
      orElse: () => QuestionModel.empty(),
    );

    final looping =
        allQuestions
            .where(
              (q) =>
                  q.baseCode == 'SP-PP-CC-NN' ||
                  q.refCode.startsWith('SP-PP-CC-NN-'),
            )
            .toList();

    looping.sort((a, b) {
      final customOrder = [
        'SP-PP-CC-NN-SI',
        'SP-PP-CC-NN-AR',
        'SP-PP-CC-NN-SI-SS',
        'SP-PP-CC-NN-SI-LGA',
        'SP-PP-CC-NN-SI-AR',
      ];
      return customOrder
          .indexOf(a.refCode)
          .compareTo(customOrder.indexOf(b.refCode));
    });

    final childrenCountAnswer = provider.answers[numberOfChildrenQuestion.id];
    final childrenCount =
        int.tryParse(childrenCountAnswer?.toString() ?? '') ?? 0;
    final completedChildIndices = provider.completedChildIndices;
    final answers = provider.answers;

    List<Widget> widgets = [];

    for (var q in nonLooping) {
      final isFirstName = q.refCode == 'SP-PP-FN';
      final isLastName = q.refCode == 'SP-PP-LN';
      final qId = q.id;

      if (isFirstName &&
          (answers[qId] == null || answers[qId].toString().trim().isEmpty)) {
        provider.answers[qId] = formProvider.firstName ?? '';
      }

      if (isLastName &&
          (answers[qId] == null || answers[qId].toString().trim().isEmpty)) {
        provider.answers[qId] = formProvider.lastName ?? '';
      }

      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: DynamicQuestionWidget(
            question: q,
            sectionCode: 'A',
            onCompleted: () => setState(() {}),
          ),
        ),
      );
    }

    // Number of children question
    if (numberOfChildrenQuestion.id.isNotEmpty &&
        numberOfChildrenQuestion.question.trim().isNotEmpty) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: DynamicQuestionWidget(
            question: numberOfChildrenQuestion,
            sectionCode: 'A',
            onCompleted: () {
              final answer = provider.answers['SP-PP-CC-NN'];
              final count = int.tryParse(answer?.toString() ?? '') ?? 0;
              provider.clearChildAnswersAbove(count, looping);
            },
          ),
        ),
      );
    }

    // Render children
    if (childrenCount > 0 && looping.isNotEmpty) {
      for (int i = 0; i < childrenCount; i++) {
        final isVisible = i == 0 || completedChildIndices.contains(i - 1);
        if (!isVisible) break;

        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 4),
            child: Text(
              'Child ${i + 1}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Color(0xFF1C2B66),
              ),
            ),
          ),
        );

        for (var q in looping) {
          widgets.add(
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: DynamicQuestionWidget(
                question: q,
                instanceIndex: i,
                sectionCode: 'A',
                onCompleted: () => setState(() {}),
              ),
            ),
          );
        }
      }
    }

    // ✅ FIXED: Final validation after all answers have been collected
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final fnQ = allQuestions.firstWhere(
        (q) => q.refCode == 'SP-PP-FN',
        orElse: () => QuestionModel.empty(),
      );
      final lnQ = allQuestions.firstWhere(
        (q) => q.refCode == 'SP-PP-LN',
        orElse: () => QuestionModel.empty(),
      );
      final msQ = allQuestions.firstWhere(
        (q) => q.refCode == 'SP-PP-MS',
        orElse: () => QuestionModel.empty(),
      );

      final fn = provider.answers[fnQ.id]?.toString().trim() ?? '';
      final ln = provider.answers[lnQ.id]?.toString().trim() ?? '';
      final ms = provider.answers[msQ.id]?.toString().trim() ?? '';

      final isValid = fn.isNotEmpty && ln.isNotEmpty && ms.isNotEmpty;
      if (isValid) {
        formProvider.updateSection('A', {
          'firstName': fn,
          'lastName': ln,
          'maritalStatus': ms,
        });
      }
    });

    return widgets;
  }

  List<Widget> _buildHomeAddressQuestions(BuildContext context) {
    final provider = context.watch<SecurityProfileProvider>();
    final formProvider = context.read<UserFormDataProvider>();
    final allQuestions = provider.getAllOrderedQuestions('SP-HA');

    final refOrder = [
      'SP-HA-HN',
      'SP-HA-SN1',
      'SP-HA-SN2',
      'SP-HA-ST',
      'SP-HA-LGA',
      'SP-HA-AREA',
    ];

    allQuestions.sort((a, b) {
      final iA = refOrder.indexOf(a.refCode);
      final iB = refOrder.indexOf(b.refCode);
      if (iA == -1 && iB == -1) return 0;
      if (iA == -1) return 1;
      if (iB == -1) return -1;
      return iA.compareTo(iB);
    });

    final widgets = <Widget>[];

    for (var q in allQuestions) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: DynamicQuestionWidget(
            question: q,
            sectionCode: 'B',
            onCompleted: () => setState(() {}),
          ),
        ),
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sn1Question = allQuestions.firstWhere(
        (q) => q.refCode == 'SP-HA-SN1',
        orElse: () => QuestionModel.empty(),
      );
      final stQuestion = allQuestions.firstWhere(
        (q) => q.refCode == 'SP-HA-ST',
        orElse: () => QuestionModel.empty(),
      );

      final sn1 = provider.answers[sn1Question.id]?.toString().trim() ?? '';
      final st = provider.answers[stQuestion.id]?.toString().trim() ?? '';

      final isValid = sn1.isNotEmpty && st.isNotEmpty;

      if (isValid) {
        formProvider.updateSection('B', {'streetName': sn1, 'state': st});
      }
    });

    return widgets;
  }

  List<Widget> _buildTypeOfResidenceQuestions(BuildContext context) {
    final provider = context.watch<SecurityProfileProvider>();
    final formProvider = context.read<UserFormDataProvider>();
    final allQuestions = provider.getAllOrderedQuestions('SP-TOR');

    final refOrder = ['SP-TOR-TOH', 'SP-TOR-GEOS'];

    allQuestions.sort((a, b) {
      final iA = refOrder.indexOf(a.refCode);
      final iB = refOrder.indexOf(b.refCode);
      return iA.compareTo(iB);
    });

    final widgets = <Widget>[];

    for (final q in allQuestions) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: DynamicQuestionWidget(
            question: q,
            sectionCode: 'C',
            onCompleted: () => setState(() {}),
          ),
        ),
      );
    }

    // ✅ FIXED: Properly look up by question.refCode → then get .id → use in answers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tohQuestion = allQuestions.firstWhere(
        (q) => q.refCode == 'SP-TOR-TOH',
        orElse: () => QuestionModel.empty(),
      );

      final geosQuestion = allQuestions.firstWhere(
        (q) => q.refCode == 'SP-TOR-GEOS',
        orElse: () => QuestionModel.empty(),
      );

      final toh = provider.answers[tohQuestion.id]?.toString().trim() ?? '';
      final geos = provider.answers[geosQuestion.id]?.toString().trim() ?? '';

      if (toh.isNotEmpty) {
        formProvider.updateSection('C', {
          'typeOfHouse': toh,
          if (geos.isNotEmpty) 'gatedEntry': geos,
        });
      }
    });

    return widgets;
  }

  List<Widget> _buildOccupationQuestions(BuildContext context) {
    final provider = context.watch<SecurityProfileProvider>();
    final formProvider = context.read<UserFormDataProvider>();
    final allQuestions = provider.getAllOrderedQuestions('SP-OCP');

    final occupationQuestion = allQuestions.firstWhere(
      (q) => q.refCode == 'SP-OCP-OCC',
      orElse: () => QuestionModel.empty(),
    );

    final childQuestions =
        allQuestions.where((q) => q.baseCode == 'SP-OCP-OCC').toList();

    final sortOrder = [
      'SP-OCP-OCC-IN',
      'SP-OCP-OCC-OL',
      'SP-OCP-OCC-MOT',
      'SP-OCP-OCC-OL-ST',
      'SP-OCP-OCC-OL-LGA',
      'SP-OCP-OCC-OL-AR',
    ];

    childQuestions.sort((a, b) {
      final iA = sortOrder.indexOf(a.refCode);
      final iB = sortOrder.indexOf(b.refCode);
      return iA.compareTo(iB);
    });

    List<Widget> widgets = [];

    if (occupationQuestion.id.isNotEmpty) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: DynamicQuestionWidget(
            question: occupationQuestion,
            onCompleted: () => setState(() {}),
          ),
        ),
      );
    }

    final occupation = provider.answers[occupationQuestion.id]?.toString();

    String? motive;
    String? loc;
    String? state;
    String? lga;
    String? area;

    if (occupation != null && occupation.isNotEmpty) {
      for (var q in childQuestions) {
        final qRef = q.refCode;

        if ([
          'SP-OCP-OCC-OL-ST',
          'SP-OCP-OCC-OL-LGA',
          'SP-OCP-OCC-OL-AR',
        ].contains(qRef)) {
          final officeLocId =
              allQuestions
                  .firstWhere(
                    (x) => x.refCode == 'SP-OCP-OCC-OL',
                    orElse: () => QuestionModel.empty(),
                  )
                  .id;

          loc = provider.answers[officeLocId]?.toString().toLowerCase();
          if (loc != 'work outside the home') continue;
        }

        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: DynamicQuestionWidget(
              question: q,
              onCompleted: () => setState(() {}),
            ),
          ),
        );

        switch (qRef) {
          case 'SP-OCP-OCC-MOT':
            motive = provider.answers[q.id]?.toString();
            break;
          case 'SP-OCP-OCC-OL-ST':
            state = provider.answers[q.id]?.toString();
            break;
          case 'SP-OCP-OCC-OL-LGA':
            lga = provider.answers[q.id]?.toString();
            break;
          case 'SP-OCP-OCC-OL-AR':
            area = provider.answers[q.id]?.toString();
            break;
        }
      }
    }

    final isValid =
        occupation?.isNotEmpty == true &&
        motive?.isNotEmpty == true &&
        (loc != 'work outside the home' ||
            (state?.isNotEmpty == true &&
                lga?.isNotEmpty == true &&
                area?.isNotEmpty == true));

    if (isValid) {
      formProvider.updateSection('D', {
        'occupation': occupation,
        'motive': motive,
        'officeState': state,
        'officeLga': lga,
        'officeArea': area,
      });
    }

    return widgets;
  }

  List<Widget> _buildSpouseOccupationQuestions(BuildContext context) {
    final provider = context.watch<SecurityProfileProvider>();
    final formProvider = context.read<UserFormDataProvider>();
    final allQuestions = provider.getAllOrderedQuestions('SP-OCS');

    final maritalStatus =
        provider.answers['SP-PP-MS']?.toString().toLowerCase() ?? '';

    if (maritalStatus == 'single') return []; // Skip if single

    final mainQuestion = allQuestions.firstWhere(
      (q) => q.refCode == 'SP-OCS-OCC',
      orElse: () => QuestionModel.empty(),
    );

    final children =
        allQuestions.where((q) => q.baseCode == 'SP-OCS-OCC').toList();

    final sortOrder = [
      'SP-OCS-OCC-I',
      'SP-OCS-OCC-OL',
      'SP-OCS-OCC-MOT',
      'SP-OCS-OCC-ST',
      'SP-OCS-OCC-LGA',
      'SP-OCS-OCC-AR',
    ];

    children.sort((a, b) {
      final iA = sortOrder.indexOf(a.refCode);
      final iB = sortOrder.indexOf(b.refCode);
      return iA.compareTo(iB);
    });

    final widgets = <Widget>[];

    if (mainQuestion.id.isNotEmpty) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: DynamicQuestionWidget(
            question: mainQuestion,
            onCompleted: () => setState(() {}),
          ),
        ),
      );
    }

    final occAnswer = provider.answers[mainQuestion.id]?.toString();

    String? motive;
    String? state;
    String? lga;
    String? area;
    String? loc;

    if (occAnswer != null && occAnswer.isNotEmpty) {
      for (final q in children) {
        final qRef = q.refCode;

        if ([
          'SP-OCS-OCC-ST',
          'SP-OCS-OCC-LGA',
          'SP-OCS-OCC-AR',
        ].contains(qRef)) {
          final olQuestion = allQuestions.firstWhere(
            (x) => x.refCode == 'SP-OCS-OCC-OL',
            orElse: () => QuestionModel.empty(),
          );

          loc = provider.answers[olQuestion.id]?.toString().toLowerCase();
          if (loc != 'work outside the home') continue;
        }

        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: DynamicQuestionWidget(
              question: q,
              onCompleted: () => setState(() {}),
            ),
          ),
        );

        switch (qRef) {
          case 'SP-OCS-OCC-MOT':
            motive = provider.answers[q.id]?.toString();
            break;
          case 'SP-OCS-OCC-ST':
            state = provider.answers[q.id]?.toString();
            break;
          case 'SP-OCS-OCC-LGA':
            lga = provider.answers[q.id]?.toString();
            break;
          case 'SP-OCS-OCC-AR':
            area = provider.answers[q.id]?.toString();
            break;
        }
      }
    }

    final isValid =
        occAnswer?.isNotEmpty == true &&
        motive?.isNotEmpty == true &&
        (loc != 'work outside the home' ||
            (state?.isNotEmpty == true &&
                lga?.isNotEmpty == true &&
                area?.isNotEmpty == true));

    if (isValid) {
      formProvider.updateSection('D-spouse', {
        'spouseOccupation': occAnswer,
        'motive': motive,
        'state': state,
        'lga': lga,
        'area': area,
      });
    }

    return widgets;
  }

  List<Widget> buildDomesticStaffQuestions(
    BuildContext context, {
    required String roleTitle,
    required String countRefCode,
    required List<String> detailRefCodes,
    required Set<int> completedIndices,
    required void Function(int index) onMarkCompleted,
  }) {
    final provider = context.watch<SecurityProfileProvider>();
    final formProvider = context.read<UserFormDataProvider>();
    final allQuestions = provider.getAllOrderedQuestions('SP-DS');

    final countQuestion = allQuestions.firstWhere(
      (q) => q.refCode == countRefCode,
      orElse: () => QuestionModel.empty(),
    );

    final detailQuestions =
        allQuestions.where((q) => detailRefCodes.contains(q.refCode)).toList()
          ..sort((a, b) => a.refCode.compareTo(b.refCode));

    final countAnswer = provider.answers[countQuestion.id];
    final count = int.tryParse(countAnswer?.toString() ?? '') ?? 0;

    List<Widget> widgets = [];

    widgets.add(
      Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 4),
        child: Text(
          roleTitle,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1C2B66),
          ),
        ),
      ),
    );

    if (countQuestion.id.isNotEmpty) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: DynamicQuestionWidget(
            question: countQuestion,
            onCompleted: () {
              provider.clearChildAnswersAbove(count, detailQuestions);
              setState(() {});
            },
          ),
        ),
      );
    }

    bool isAnyCompleted = false;

    if (count > 0 && detailQuestions.isNotEmpty) {
      for (int i = 0; i < count; i++) {
        final isVisible = i == 0 || completedIndices.contains(i - 1);
        if (!isVisible) break;

        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 4),
            child: Text(
              '$roleTitle ${i + 1}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Color(0xFF1C2B66),
              ),
            ),
          ),
        );

        for (var q in detailQuestions) {
          widgets.add(
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: DynamicQuestionWidget(
                question: q,
                instanceIndex: i,
                onCompleted: () {
                  if (provider.isChildCompleted(i, detailQuestions)) {
                    onMarkCompleted(i);
                    setState(() {});
                  }
                },
              ),
            ),
          );
        }

        if (provider.isChildCompleted(i, detailQuestions)) {
          isAnyCompleted = true;
        }
      }
    }

    if (isAnyCompleted) {
      formProvider.updateSection('E', {countRefCode: count});
    }

    return widgets;
  }

  List<Widget> buildSocialsSection(
    BuildContext context, {
    required bool isSpouse,
  }) {
    final provider = context.watch<SecurityProfileProvider>();
    final formProvider = context.read<UserFormDataProvider>();
    final sectionId = isSpouse ? 'SP-SOS' : 'SP-SOP';
    final allQuestions = provider.getAllOrderedQuestions(sectionId);

    final orderedRefCodes = [
      isSpouse ? 'SP-SOS-CMN' : 'SP-SOP-CMN',
      isSpouse ? 'SP-SOS-NLS' : 'SP-SOP-NLP',
      isSpouse ? 'SP-SOS-ISTP' : 'SP-SOP-ISTP',
    ];

    final widgets = <Widget>[];

    bool allFilled = true;

    for (final refCode in orderedRefCodes) {
      final question = allQuestions.firstWhere(
        (q) => q.refCode == refCode,
        orElse: () => QuestionModel.empty(),
      );

      if (question.id.isEmpty) continue;

      final answer = provider.answers[question.id];
      if (answer == null || answer.toString().trim().isEmpty) {
        allFilled = false;
      }

      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: DynamicQuestionWidget(
            question: question,
            onCompleted: () {
              final newAnswer = provider.answers[question.id];
              if (newAnswer != null && newAnswer.toString().isNotEmpty) {
                setState(() {});
              }
            },
          ),
        ),
      );
    }

    if (!isSpouse && allFilled) {
      formProvider.updateSection('F', {
        'commonNetwork': provider.answers['SP-SOP-CMN'],
        'newsListening': provider.answers['SP-SOP-NLS'],
        'socialPlatform': provider.answers['SP-SOP-ISTP'],
      });
    }

    return widgets;
  }

  bool _fatherCompleted = false;
  bool _motherCompleted = false;

  List<Widget> buildParentBlock({
    required BuildContext context,
    required String title,
    required String mainRefCode,
    required List<String> detailRefCodes,
  }) {
    final provider = context.watch<SecurityProfileProvider>();
    final formProvider = context.read<UserFormDataProvider>();
    final allQuestions = provider.getAllOrderedQuestions('SP-OTH');

    final parentQ = allQuestions.firstWhere(
      (q) => q.refCode == mainRefCode,
      orElse: () => QuestionModel.empty(),
    );

    final children =
        allQuestions.where((q) => detailRefCodes.contains(q.refCode)).toList();

    final widgets = <Widget>[
      Padding(
        padding: const EdgeInsets.only(top: 24, bottom: 4),
        child: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF1C2B66),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: DynamicQuestionWidget(
          question: parentQ,
          onCompleted: () => setState(() {}),
        ),
      ),
    ];

    final answer = provider.answers[parentQ.id]?.toString().toLowerCase();
    bool allFilled = true;

    if (answer == 'alive') {
      for (final q in children) {
        final qAnswer = provider.answers[q.id];
        if (qAnswer == null || qAnswer.toString().trim().isEmpty) {
          allFilled = false;
        }

        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: DynamicQuestionWidget(
              question: q,
              onCompleted: () => setState(() {}),
            ),
          ),
        );
      }
    }

    if (answer != null && answer.isNotEmpty && allFilled) {
      // Save sub-section state
      if (mainRefCode == 'SP-OTH-PP') {
        _fatherCompleted = true;
      } else if (mainRefCode == 'SP-OTH-PM') {
        _motherCompleted = true;
      }

      // Only update section G once BOTH are done
      if (_fatherCompleted && _motherCompleted) {
        formProvider.updateSection('G', {
          'fatherStatus': provider.answers['SP-OTH-PP'] ?? '',
          'motherStatus': provider.answers['SP-OTH-PM'] ?? '',
          ...detailRefCodes.fold<Map<String, dynamic>>({}, (map, ref) {
            final q = allQuestions.firstWhere(
              (x) => x.refCode == ref,
              orElse: () => QuestionModel.empty(),
            );
            if (q.id.isNotEmpty) {
              map[ref] = provider.answers[q.id];
            }
            return map;
          }),
        });
      }
    }

    return widgets;
  }

  @override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback(
    (_) => _initializeRegistration(),
  );
}

 Future<void> _initializeRegistration() async {
  final provider = context.read<SecurityProfileProvider>();
  final userProvider = context.read<UserFormDataProvider>();

  try {
    await provider.createOrFetchSecurityProfile();
    await provider.fetchQuestions();
    await provider.fetchSubmittedAnswers();

    userProvider.setOnboardingStage(2);
    await SessionManager.saveStage(2);
  } catch (e) {
    print('[ContinueRegistration] Initialization error: $e');
  }

  setState(() {
    _isInitializing = false;
  });
}

  @override
  Widget build(BuildContext context) {
    final formProvider = context.watch<UserFormDataProvider>();

    final visualPercent = context.watch<UserFormDataProvider>().stage2Progress;

      
    final canViewReport =
        formProvider.isSectionComplete('A') &&
        formProvider.isSectionComplete('B') &&
        formProvider.isSectionComplete('C') &&
        formProvider.isSectionComplete('E') &&
        formProvider.isSectionComplete('F') &&
        formProvider.isSectionComplete('G');

    final profileProvider = context.watch<SecurityProfileProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFFFFAEA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body:
          _isInitializing
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    CustomProgressBar(
                      currentStep: 2,
                      percent: visualPercent.clamp(0.3, 1.0),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List.generate(sectionTitles.length, (
                            index,
                          ) {
                            final sectionLetter = String.fromCharCode(
                              65 + index,
                            );
                            final title = sectionTitles[index];
                            final isProfile = title == "Profile";
                            final isHomeAddress = title == "Home Address";
                            final isTypeOfResidence =
                                title == "Type of Residence";
                            final isOccupation = title == "Occupation";
                            final isDomesticSupport =
                                title == "Domestic Support";
                            final isSocials = title == "Socials";
                            final isOthers = title == "Others";

                            return Container(
                              margin: const EdgeInsets.only(bottom: 14),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: ExpansionTile(
                                  key: ValueKey(expandedIndex == index),
                                  onExpansionChanged: (value) {
                                    setState(() {
                                      if (value) {
                                        expandedIndex = index;
                                      } else if (expandedIndex == index) {
                                        expandedIndex = null;
                                      }
                                    });
                                  },
                                  initiallyExpanded: expandedIndex == index,
                                  tilePadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  iconColor: Colors.white,
                                  collapsedIconColor: Colors.white,
                                  collapsedBackgroundColor: const Color(
                                    0xFF1C2B66,
                                  ),
                                  backgroundColor: const Color(0xFF1C2B66),
                                  title: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Colors.white,
                                        radius: 14,
                                        child: Text(
                                          sectionLetter,
                                          style: const TextStyle(
                                            fontFamily: 'Objective',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Text(
                                          title,
                                          style: const TextStyle(
                                            fontFamily: 'Objective',
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      if (formProvider.isSectionComplete(
                                        sectionLetter,
                                      ))
                                        const Icon(
                                          Icons.check_circle,
                                          color: Colors.green,
                                        ),
                                    ],
                                  ),
                                  children: [
                                    if (isProfile)
                                      Container(
                                        color: Colors.white,
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            if (profileProvider.isLoading)
                                              const Padding(
                                                padding: EdgeInsets.all(16),
                                                child: Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                ),
                                              )
                                            else if ((profileProvider
                                                        .sectionQuestions['SP-PP'] ??
                                                    [])
                                                .isEmpty)
                                              const Padding(
                                                padding: EdgeInsets.all(16),
                                                child: Text(
                                                  "No profile questions found.",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.black54,
                                                  ),
                                                ),
                                              )
                                            else
                                              ..._buildProfileQuestions(
                                                context,
                                              ),

                                            if (profileProvider
                                                .showSpouseProfile)
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Padding(
                                                    padding: EdgeInsets.only(
                                                      top: 24,
                                                      bottom: 8,
                                                    ),
                                                    child: Text(
                                                      "Spouse Profile",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16,
                                                        color: Color(
                                                          0xFF1C2B66,
                                                        ), // Halogen blue
                                                      ),
                                                    ),
                                                  ),
                                                  ...[
                                                    'SP-SS-TT',
                                                    'SP-SS-FN',
                                                    'SP-SS-LN',
                                                    'SP-SS-GD',
                                                    'SP-SS-AR',
                                                  ].map((refCode) {
                                                    final matches =
                                                        profileProvider
                                                            .sectionQuestions['SP-SS']
                                                            ?.where(
                                                              (e) =>
                                                                  e.refCode ==
                                                                  refCode,
                                                            )
                                                            .toList();

                                                    if (matches != null &&
                                                        matches.isNotEmpty) {
                                                      return Padding(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              vertical: 6,
                                                            ),
                                                        child:
                                                            DynamicQuestionWidget(
                                                              question:
                                                                  matches.first,
                                                              onCompleted: () {
                                                                setState(() {});
                                                              },
                                                            ),
                                                      );
                                                    } else {
                                                      return const SizedBox.shrink();
                                                    }
                                                  }),
                                                ],
                                              ),
                                          ],
                                        ),
                                      ),
                                    if (isHomeAddress)
                                      Container(
                                        color: Colors.white,
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: _buildHomeAddressQuestions(
                                            context,
                                          ),
                                        ),
                                      ),
                                    if (isTypeOfResidence)
                                      Container(
                                        color: Colors.white,
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children:
                                              _buildTypeOfResidenceQuestions(
                                                context,
                                              ),
                                        ),
                                      ),
                                    if (isOccupation)
                                      Container(
                                        color: Colors.white,
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            ..._buildOccupationQuestions(
                                              context,
                                            ),
                                            if (profileProvider
                                                .showSpouseProfile) ...[
                                              const Padding(
                                                padding: EdgeInsets.only(
                                                  top: 24,
                                                  bottom: 8,
                                                ),
                                                child: Text(
                                                  "Spouse Occupation",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                    color: Color(0xFF1C2B66),
                                                  ),
                                                ),
                                              ),
                                              ..._buildSpouseOccupationQuestions(
                                                context,
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    if (isDomesticSupport)
                                      Container(
                                        color: Colors.white,
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            ...buildDomesticStaffQuestions(
                                              context,
                                              roleTitle: 'Driver',
                                              countRefCode: 'SP-DS-ND',
                                              detailRefCodes: ['SP-DS-ND-D'],
                                              completedIndices:
                                                  profileProvider
                                                      .completedDriverIndices,
                                              onMarkCompleted:
                                                  (i) => profileProvider
                                                      .completedDriverIndices
                                                      .add(i),
                                            ),

                                            ...buildDomesticStaffQuestions(
                                              context,
                                              roleTitle: 'Nanny / House Keeper',
                                              countRefCode: 'SP-DS-NN',
                                              detailRefCodes: ['SP-DS-NN-N'],
                                              completedIndices:
                                                  profileProvider
                                                      .completedNannyIndices,
                                              onMarkCompleted:
                                                  (i) => profileProvider
                                                      .completedNannyIndices
                                                      .add(i),
                                            ),

                                            ...buildDomesticStaffQuestions(
                                              context,
                                              roleTitle: 'Cook / Steward',
                                              countRefCode: 'SP-DS-CS',
                                              detailRefCodes: ['SP-DS-CS-NCS'],
                                              completedIndices:
                                                  profileProvider
                                                      .completedCookIndices,
                                              onMarkCompleted:
                                                  (i) => profileProvider
                                                      .completedCookIndices
                                                      .add(i),
                                            ),

                                            ...buildDomesticStaffQuestions(
                                              context,
                                              roleTitle: 'Gate Men',
                                              countRefCode: 'SP-DS-NG',
                                              detailRefCodes: [
                                                'SP-DS-NG-AM',
                                                'SP-DS-NG-LD',
                                                'SP-DS-NG-U',
                                              ],
                                              completedIndices:
                                                  profileProvider
                                                      .completedGateManIndices,
                                              onMarkCompleted:
                                                  (i) => profileProvider
                                                      .completedGateManIndices
                                                      .add(i),
                                            ),
                                          ],
                                        ),
                                      ),
                                    if (isSocials)
                                      Container(
                                        color: Colors.white,
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.only(
                                                bottom: 12,
                                              ),
                                              child: Text(
                                                "Principal",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF1C2B66),
                                                ),
                                              ),
                                            ),
                                            ...buildSocialsSection(
                                              context,
                                              isSpouse: false,
                                            ),
                                            if (profileProvider
                                                .showSpouseProfile) ...[
                                              const Padding(
                                                padding: EdgeInsets.only(
                                                  top: 24,
                                                  bottom: 12,
                                                ),
                                                child: Text(
                                                  "Spouse",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF1C2B66),
                                                  ),
                                                ),
                                              ),
                                              ...buildSocialsSection(
                                                context,
                                                isSpouse: true,
                                              ),
                                            ],
                                            const Padding(
                                              padding: EdgeInsets.only(
                                                bottom: 100,
                                              ),
                                              child: SizedBox(),
                                            ),
                                          ],
                                        ),
                                      ),

                                    if (isOthers)
                                      Container(
                                        color: Colors.white,
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ...buildParentBlock(
                                              context: context,
                                              title: "Father",
                                              mainRefCode: 'SP-OTH-PP',
                                              detailRefCodes: [
                                                'SP-OTH-PP-AG',
                                                'SP-OTH-PP-ST',
                                                'SP-OTH-PP-LGA',
                                                'SP-OTH-PP-AR',
                                              ],
                                            ),
                                            ...buildParentBlock(
                                              context: context,
                                              title: "Mother",
                                              mainRefCode: 'SP-OTH-PM',
                                              detailRefCodes: [
                                                'SP-OTH-PM-AR',
                                                'SP-OTH-PM-ST',
                                                'SP-OTH-PM-LGA',
                                                'SP-OTH-PM-AA',
                                              ],
                                            ),
                                            const SizedBox(height: 24),

                                            // ✅ Show spouse section only if married
                                            if (profileProvider
                                                .showSpouseProfile) ...[
                                              const Padding(
                                                padding: EdgeInsets.only(
                                                  top: 24,
                                                  bottom: 8,
                                                ),
                                                child: Text(
                                                  "Spouse's Parents",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                    color: Color(0xFF1C2B66),
                                                  ),
                                                ),
                                              ),
                                              ...buildParentBlock(
                                                context: context,
                                                title: "Spouse's Father",
                                                mainRefCode: 'SP-OTH-S-F',
                                                detailRefCodes: [
                                                  'SP-OTH-S-F-AG',
                                                  'SP-OTH-S-F-ST',
                                                  'SP-OTH-S-F-LGA',
                                                  'SP-OTH-S-F-AA',
                                                ],
                                              ),
                                              ...buildParentBlock(
                                                context: context,
                                                title: "Spouse's Mother",
                                                mainRefCode: 'SP-OTH-S-M',
                                                detailRefCodes: [
                                                  'SP-OTH-S-M-AG',
                                                  'SP-OTH-S-M-AA',
                                                  'SP-OTH-S-M-LGA',
                                                  'SP-OTH-S-M-ST',
                                                ],
                                              ),
                                            ],

                                            const SizedBox(height: 32),
                                        ] )   
                                      ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                    if (canViewReport) ...[  
  const SizedBox(height: 24),
  SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: () async {
        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );
        
        // Submit all answers to ensure everything is saved
        final success = await profileProvider.profileProvider.submitAllAnswers();
        
        // Close loading indicator
        Navigator.pop(context);
        
        if (success) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const SecurityReportScreen(),
            ),
          );
        } else {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to submit answers. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1C2B66),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: const Text(
        "View Report",
        style: TextStyle(
          color: Colors.white,
          fontFamily: 'Objective',
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  ),
  const SizedBox(height: 100),
],
                  ],
                ),
              ),
    );
  }
}
