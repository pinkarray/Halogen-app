import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/user_form_data_provider.dart';
import '../../../security_profile/providers/security_profile_provider.dart';
import '../../../shared/widgets/custom_progress_bar.dart';
import '../../../security_profile/widgets/dynamic_question_widget.dart';
import '../../../security_profile/models/question_model.dart';
import './security_report_screen.dart';

class ContinueRegistrationScreen extends StatefulWidget {
  const ContinueRegistrationScreen({super.key});

  @override
  State<ContinueRegistrationScreen> createState() =>
      _ContinueRegistrationScreenState();
}

class _ContinueRegistrationScreenState extends State<ContinueRegistrationScreen> {
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
    final allQuestions = provider.getAllOrderedQuestions('SP-PP');

    final excludedRefCodes = [
      'sp-pp-cc-nn', 
      'sp-pp-cc-nc', 
      'sp-pp-cc-ns', 
      'sp-11',       
    ];

    final nonLooping = allQuestions.where((q) {
      final ref = q.refCode.trim().toLowerCase();
      final base = q.baseCode.trim().toLowerCase();
      return !excludedRefCodes.contains(ref) && base != 'sp-pp-cc-nn';
    }).toList();

    final numberOfChildrenQuestion = allQuestions.firstWhere(
      (q) => q.refCode == 'SP-PP-CC-NN',
      orElse: () => QuestionModel.empty(),
    );

    final looping = allQuestions
        .where((q) =>
            q.baseCode == 'SP-PP-CC-NN' ||
            q.refCode.startsWith('SP-PP-CC-NN-'))
        .toList();
        print('[LOOPING] Child-related questions:');
        for (var q in looping) {
          print('- ${q.refCode}: ${q.question}');
        }
    looping.sort((a, b) {
      final customOrder = [
        'SP-PP-CC-NN-SI',   
        'SP-PP-CC-NN-AR',   
        'SP-PP-CC-NN-SI-SS',
        'SP-PP-CC-NN-SI-LGA',
        'SP-PP-CC-NN-SI-AR', 
      ];

      final indexA = customOrder.indexOf(a.refCode);
      final indexB = customOrder.indexOf(b.refCode);

      if (indexA == -1 && indexB == -1) return 0;
      if (indexA == -1) return 1;
      if (indexB == -1) return -1;
      return indexA.compareTo(indexB);
    });

    final childrenCountAnswer = provider.answers[numberOfChildrenQuestion.id];
    final childrenCount = int.tryParse(childrenCountAnswer?.toString() ?? '') ?? 0;

    print('[LIVE BUILD] childrenCount = $childrenCount');

    final completedChildIndices = provider.completedChildIndices;

    List<Widget> widgets = [];

    for (var q in nonLooping) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: DynamicQuestionWidget(question: q),
        ),
      );
    }

    if (numberOfChildrenQuestion.id.isNotEmpty &&
        numberOfChildrenQuestion.question.trim().isNotEmpty) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: DynamicQuestionWidget(
            question: numberOfChildrenQuestion,
            onCompleted: () {
              final answer = provider.answers['SP-PP-CC-NN'];
              final count = int.tryParse(answer?.toString() ?? '') ?? 0;
              print('[ONCOMPLETE] SP-PP-CC-NN = $answer → count = $count');

              provider.clearChildAnswersAbove(count, looping);
            },
          ),
        ),
      );
    }

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
                onCompleted: () {
                  if (provider.isChildCompleted(i, looping)) {
                    provider.markChildCompleted(i);
                  }
                },
              ),
            ),
          );
        }
      }
    }

    return widgets;
  }

  List<Widget> _buildHomeAddressQuestions(BuildContext context) {
    final provider = context.watch<SecurityProfileProvider>();
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

    return allQuestions.map((q) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: DynamicQuestionWidget(
          question: q,
          onCompleted: () => setState(() {}),
        ),
      );
    }).toList();
  }

  List<Widget> _buildTypeOfResidenceQuestions(BuildContext context) {
    final provider = context.watch<SecurityProfileProvider>();
    final allQuestions = provider.getAllOrderedQuestions('SP-TOR');

    final refOrder = [
      'SP-TOR-TOH',  
      'SP-TOR-GEOS',
    ];

    allQuestions.sort((a, b) {
      final iA = refOrder.indexOf(a.refCode);
      final iB = refOrder.indexOf(b.refCode);
      if (iA == -1 && iB == -1) return 0;
      if (iA == -1) return 1;
      if (iB == -1) return -1;
      return iA.compareTo(iB);
    });

    return allQuestions.map((q) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: DynamicQuestionWidget(
          question: q,
          onCompleted: () => setState(() {}),
        ),
      );
    }).toList();
  }

  List<Widget> _buildOccupationQuestions(BuildContext context) {
    final provider = context.watch<SecurityProfileProvider>();
    final allQuestions = provider.getAllOrderedQuestions('SP-OCP');

    // Filter questions
    final occupationQuestion = allQuestions.firstWhere(
      (q) => q.refCode == 'SP-OCP-OCC',
      orElse: () => QuestionModel.empty(),
    );

    final childQuestions = allQuestions.where(
      (q) => q.baseCode == 'SP-OCP-OCC',
    ).toList();

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

    final selectedOccupation = provider.answers[occupationQuestion.id]?.toString();

    if (selectedOccupation != null && selectedOccupation.isNotEmpty) {
      for (var q in childQuestions) {
        if (['SP-OCP-OCC-OL-ST', 'SP-OCP-OCC-OL-LGA', 'SP-OCP-OCC-OL-AR'].contains(q.refCode)) {
          final officeLocId = allQuestions.firstWhere(
            (x) => x.refCode == 'SP-OCP-OCC-OL',
            orElse: () => QuestionModel.empty(),
          ).id;

          final locAnswer = provider.answers[officeLocId]?.toString().toLowerCase();
          if (locAnswer != 'work outside the home') continue;
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

    return widgets;
  }

  List<Widget> _buildSpouseOccupationQuestions(BuildContext context) {
    final provider = context.watch<SecurityProfileProvider>();
    final allQuestions = provider.getAllOrderedQuestions('SP-OCS');

    final mainQuestion = allQuestions.firstWhere(
      (q) => q.refCode == 'SP-OCS-OCC',
      orElse: () => QuestionModel.empty(),
    );

    final children = allQuestions.where((q) => q.baseCode == 'SP-OCS-OCC').toList();

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
    if (occAnswer != null && occAnswer.isNotEmpty) {
      for (final q in children) {
        if (['SP-OCS-OCC-ST', 'SP-OCS-OCC-LGA', 'SP-OCS-OCC-AR'].contains(q.refCode)) {
          final olQuestion = allQuestions.firstWhere(
            (x) => x.refCode == 'SP-OCS-OCC-OL',
            orElse: () => QuestionModel.empty(),
          );

          final olAnswer = provider.answers[olQuestion.id]?.toString().toLowerCase();
          if (olAnswer != 'work outside the home') continue;
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
    final allQuestions = provider.getAllOrderedQuestions('SP-DS');

    final countQuestion = allQuestions.firstWhere(
      (q) => q.refCode == countRefCode,
      orElse: () => QuestionModel.empty(),
    );

    final detailQuestions = allQuestions
        .where((q) => detailRefCodes.contains(q.refCode))
        .toList();

    detailQuestions.sort((a, b) => a.refCode.compareTo(b.refCode));

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
                instanceIndex: roleTitle.toLowerCase().contains("gate") ? null : i,
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
      }
    }

    return widgets;
  }

  List<Widget> buildSocialsSection(BuildContext context, {required bool isSpouse}) {
    final provider = context.watch<SecurityProfileProvider>();
    final sectionId = isSpouse ? 'SP-SOS' : 'SP-SOP';
    final allQuestions = provider.getAllOrderedQuestions(sectionId);

    final orderedRefCodes = [
      isSpouse ? 'SP-SOS-CMN' : 'SP-SOP-CMN',
      isSpouse ? 'SP-SOS-NLS' : 'SP-SOP-NLP',
      isSpouse ? 'SP-SOS-ISTP' : 'SP-SOP-ISTP',
    ];

    return orderedRefCodes
        .map((refCode) {
          final question = allQuestions.firstWhere((q) => q.refCode == refCode, orElse: () => QuestionModel.empty());
          if (question.id.isEmpty) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: DynamicQuestionWidget(question: question),
          );
        })
        .toList();
  }

  List<Widget> buildParentBlock({
    required BuildContext context,
    required String title,
    required String mainRefCode,
    required List<String> detailRefCodes,
  }) {
    final provider = context.watch<SecurityProfileProvider>();
    final allQuestions = provider.getAllOrderedQuestions('SP-OTH');

    // 🔍 DEBUG: Print all questions loaded for SP-OTH
    print('[DEBUG] All SP-OTH questions:');
    for (final q in allQuestions) {
      print('→ ${q.refCode} : ${q.question}');
    }

    final parentQ = allQuestions.firstWhere(
      (q) => q.refCode == mainRefCode,
      orElse: () {
        print('[ERROR] Parent question NOT FOUND: $mainRefCode');
        return QuestionModel.empty();
      },
    );

    final children = allQuestions
        .where((q) => detailRefCodes.contains(q.refCode))
        .toList();

    // 🔍 DEBUG: Print resolved child questions
    print('\n[DEBUG] $title Children for $mainRefCode:');
    for (final q in children) {
      print('→ ${q.refCode} : ${q.question}');
    }

    final widgets = <Widget>[];

    // Title
    widgets.add(
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
    );

    // Main Dropdown: Alive or Deceased
    widgets.add(
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: DynamicQuestionWidget(
          question: parentQ,
          onCompleted: () => setState(() {}),
          
        ),
      ),
    );
    print('[RENDER CHECK] ${parentQ.refCode} rendered, ID: ${parentQ.id}');

    final answer = provider.answers[parentQ.id]?.toString().toLowerCase();
    print('[DEBUG] Answer for $mainRefCode (${parentQ.question}): $answer');

    if (answer == 'alive') {
      for (final q in children) {
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

    return widgets;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeRegistration());
  }

  Future<void> _initializeRegistration() async {
    final provider = context.read<SecurityProfileProvider>();

    try {
      await provider.createOrFetchSecurityProfile();
      await provider.fetchQuestions();
      
      await provider.fetchSubmittedAnswers();
    } catch (e) {
      print('[ContinueRegistration] Initialization error: $e');
    }

    setState(() {
      _isInitializing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final completedSections =
        context.watch<UserFormDataProvider>().allSections.keys.toSet();
    final requiredSections = {
      "A", "B", "C", "D", "E", "F", "G"
    }; // A-G match your tiles

    final canViewReport = requiredSections.every(completedSections.contains);

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
      body: _isInitializing
    ? const Center(child: CircularProgressIndicator())
    : Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            CustomProgressBar(
              currentStep: 2,
              percent: completedSections.length / sectionTitles.length,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(sectionTitles.length, (index) {
                    final sectionLetter = String.fromCharCode(65 + index);
                    final title = sectionTitles[index];
                    final isProfile = title == "Profile";
                    final isHomeAddress = title == "Home Address";
                    final isTypeOfResidence = title == "Type of Residence";
                    final isOccupation = title == "Occupation";
                    final isDomesticSupport = title == "Domestic Support";
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
                          tilePadding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          iconColor: Colors.white,
                          collapsedIconColor: Colors.white,
                          collapsedBackgroundColor: const Color(0xFF1C2B66),
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
                              if (completedSections.contains(sectionLetter))
                                const Icon(Icons.check_circle,
                                    color: Colors.green),
                            ],
                          ),
                          children: [
                            if (isProfile)
                              Container(
                                color: Colors.white,
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (profileProvider.isLoading)
                                      const Padding(
                                        padding: EdgeInsets.all(16),
                                        child: Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      )
                                    else if ((profileProvider.sectionQuestions['SP-PP'] ?? []).isEmpty)
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
                                      ..._buildProfileQuestions(context),

                                    if (profileProvider.showSpouseProfile)
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Padding(
                                            padding: EdgeInsets.only(
                                                top: 24, bottom: 8),
                                            child: Text(
                                              "Spouse Profile",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: Color(0xFF1C2B66), // Halogen blue
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
                                            final matches = profileProvider.sectionQuestions['SP-SS']
                                                ?.where((e) => e.refCode == refCode)
                                                .toList();

                                            if (matches != null && matches.isNotEmpty) {
                                              return Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 6),
                                                child: DynamicQuestionWidget(
                                                  question: matches.first,
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
                                      )
                                  ],
                                ),
                              ),
                            if (isHomeAddress)
                              Container(
                                color: Colors.white,
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: _buildHomeAddressQuestions(context),
                                ),
                              ),
                            if (isTypeOfResidence)
                              Container(
                                color: Colors.white,
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: _buildTypeOfResidenceQuestions(context),
                                ),
                              ),
                            if (isOccupation)
                              Container(
                                color: Colors.white,
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ..._buildOccupationQuestions(context),
                                    if (profileProvider.showSpouseProfile) ...[
                                      const Padding(
                                        padding: EdgeInsets.only(top: 24, bottom: 8),
                                        child: Text(
                                          "Spouse Occupation",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Color(0xFF1C2B66),
                                          ),
                                        ),
                                      ),
                                      ..._buildSpouseOccupationQuestions(context),
                                    ],
                                  ],
                                ),
                              ),
                            if (isDomesticSupport)
                              Container(
                                color: Colors.white,
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ...buildDomesticStaffQuestions(
                                      context,
                                      roleTitle: 'Driver',
                                      countRefCode: 'SP-DS-ND',
                                      detailRefCodes: ['SP-DS-ND-D'],
                                      completedIndices: profileProvider.completedDriverIndices,
                                      onMarkCompleted: (i) => profileProvider.completedDriverIndices.add(i),
                                    ),

                                    ...buildDomesticStaffQuestions(
                                      context,
                                      roleTitle: 'Nanny / House Keeper',
                                      countRefCode: 'SP-DS-NN',
                                      detailRefCodes: ['SP-DS-NN-N'],
                                      completedIndices: profileProvider.completedNannyIndices,
                                      onMarkCompleted: (i) => profileProvider.completedNannyIndices.add(i),
                                    ),

                                    ...buildDomesticStaffQuestions(
                                      context,
                                      roleTitle: 'Cook / Steward',
                                      countRefCode: 'SP-DS-CS',
                                      detailRefCodes: ['SP-DS-CS-NCS'],
                                      completedIndices: profileProvider.completedCookIndices,
                                      onMarkCompleted: (i) => profileProvider.completedCookIndices.add(i),
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
                                      completedIndices: profileProvider.completedGateManIndices,
                                      onMarkCompleted: (i) => profileProvider.completedGateManIndices.add(i),
                                    ),
                                  ],
                                ),
                              ),
                            if (isSocials)
                              Container(
                                color: Colors.white,
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(bottom: 12),
                                      child: Text(
                                        "Principal",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1C2B66),
                                        ),
                                      ),
                                    ),
                                    ...buildSocialsSection(context, isSpouse: false),

                                    if (profileProvider.showSpouseProfile) ...[
                                      const Padding(
                                        padding: EdgeInsets.only(top: 24, bottom: 12),
                                        child: Text(
                                          "Spouse",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1C2B66),
                                          ),
                                        ),
                                      ),
                                      ...buildSocialsSection(context, isSpouse: true),
                                    ],
                                  ],
                                ),
                              ),
                              if (isOthers)
                                Container(
                                  color: Colors.white,
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
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
                                      if (profileProvider.showSpouseProfile) ...[
                                        const Padding(
                                          padding: EdgeInsets.only(top: 24, bottom: 8),
                                          child: Text(
                                            "Spouse’s Parents",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Color(0xFF1C2B66),
                                            ),
                                          ),
                                        ),
                                        ...buildParentBlock(
                                          context: context,
                                          title: "Spouse’s Father",
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
                                            title: "Spouse’s Mother",
                                            mainRefCode: 'SP-OTH-S-M',
                                            detailRefCodes: [
                                                'SP-OTH-S-M-AG',
                                                'SP-OTH-S-M-AA', 
                                                'SP-OTH-S-M-LGA',
                                                'SP-OTH-S-M-ST',
                                          ],
                                        ),
                                        if (canViewReport)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 16.0),
                                            child: SizedBox(
                                              width: double.infinity,
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(builder: (_) => const SecurityReportScreen()),
                                                  );
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: const Color(0xFF1C2B66), // Halogen Blue
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
                                          ),

                                        const Padding(
                                          padding: EdgeInsets.only(bottom: 80),
                                          child: SizedBox(),
                                        ),
                                      ]
                                    ],
                                  ),
                                ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            )
          )
          
          ],
        ),
      ),
    );
  }
}