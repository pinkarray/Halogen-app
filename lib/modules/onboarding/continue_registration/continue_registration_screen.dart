import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/user_form_data_provider.dart';
import '../../../security_profile/providers/security_profile_provider.dart';
import '../../../shared/widgets/custom_progress_bar.dart';
import '../../../security_profile/widgets/dynamic_question_widget.dart';

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SecurityProfileProvider>().fetchQuestions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final completedSections =
        context.watch<UserFormDataProvider>().allSections.keys.toSet();
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            CustomProgressBar(
              currentStep: 2,
              percent: completedSections.length / sectionTitles.length,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: sectionTitles.length,
                itemBuilder: (context, index) {
                  final sectionLetter = String.fromCharCode(65 + index);
                  final title = sectionTitles[index];
                  final isProfile = title == "Profile";

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
                        key: Key(index.toString()),
                        onExpansionChanged: (value) {
                          setState(() {
                            expandedIndex = value ? index : null;
                          });
                        },
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
                                    ...profileProvider
                                        .sectionQuestions['SP-PP']!
                                        .map(
                                          (q) => Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 6),
                                            child: DynamicQuestionWidget(
                                              question: q,
                                            ),
                                          ),
                                        ),

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
                                              child: DynamicQuestionWidget(question: matches.first),
                                            );
                                          } else {
                                            return const SizedBox.shrink(); // safe fallback
                                          }
                                        }),
                                      ],
                                    )
                                ],
                              ),
                            )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}