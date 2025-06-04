import 'package:flutter/material.dart';
import 'package:halogen/security_profile/providers/security_profile_provider.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../../shared/widgets/custom_progress_bar.dart';
import '../../../providers/user_form_data_provider.dart';
import '../../../shared/helpers/session_manager.dart';
import '../../../shared/widgets/home_wrapper.dart';


class SecurityReportScreen extends StatefulWidget {
  const SecurityReportScreen({super.key});

  @override
  State<SecurityReportScreen> createState() => _SecurityReportScreenState();
}

class _SecurityReportScreenState extends State<SecurityReportScreen> {
  bool _loading = true;
  Map<String, dynamic>? _report;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    final profileProvider = context.read<SecurityProfileProvider>();
    final userProvider = context.read<UserFormDataProvider>();

    // Submit all answers before fetching the report
    await profileProvider.profileProvider.submitAllAnswers();
    
    // Add a small delay to ensure server processes the answers
    await Future.delayed(const Duration(seconds: 1));
    
    final data = await profileProvider.fetchSecurityReport();

    // ✅ Mark user as fully registered
    userProvider.markFullyRegistered();
    userProvider.setOnboardingStage(3);
    await SessionManager.saveStage(3);

    // ✅ Save user model to session
    final userModel = userProvider.toUserModel();
    await SessionManager.saveUserModel(userModel);
    await SessionManager.saveUserProfile(userModel.toJson());

    setState(() {
      _report = data;
      _loading = false;
    });
  }


  Color getColorForLevel(String level) {
    switch (level.toLowerCase()) {
      case 'low':
        return Colors.green;
      case 'medium low':
        return Colors.lightGreen;
      case 'medium':
        return Colors.orange;
      case 'medium high':
        return Colors.deepOrange;
      case 'high':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final threatScore = _report?['threat_index'] ?? 0;
    final riskLevel = _report?['risk_level'] ?? 'N/A';

    final sectionScores = _report?['section_scores'] ?? {
      'Profile': 7,
      'Home Address': 7,
      'Type of Residence': 7,
      'Occupation': 7,
      'Domestic Support': 7,
      'Socials': 7,
      'Others': 7,
    };

    return Scaffold(
      backgroundColor: const Color(0xFFFFFAEA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const CustomProgressBar(currentStep: 3, percent: 1.0),
                  const SizedBox(height: 24),

                  // Risk Meter Card
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C2B66),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        CircularPercentIndicator(
                          radius: 60.0,
                          lineWidth: 10.0,
                          percent: (threatScore.clamp(0, 100) / 100),
                          center: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '$threatScore',
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                riskLevel,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          backgroundColor: Colors.white24,
                          progressColor: Colors.white,
                        ),
                        const SizedBox(height: 12),
                        const Align(
                          alignment: Alignment.centerRight,
                          child: Chip(
                            label: Text("Recommendation"),
                            labelStyle: TextStyle(color: Colors.white),
                            backgroundColor: Color(0xFF1C2B66),
                            side: BorderSide(color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Low: 0 - 20", style: TextStyle(color: Colors.white)),
                            Text("Medium low: 21 - 40", style: TextStyle(color: Colors.white)),
                            Text("Medium: 41 - 60", style: TextStyle(color: Colors.white)),
                            Text("Medium high: 61 - 80", style: TextStyle(color: Colors.white)),
                            Text("High: 81 - 100", style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Score Point',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1C2B66),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.separated(
                      itemCount: sectionScores.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final entry = sectionScores.entries.elementAt(index);
                        final section = entry.key;
                        final score = entry.value;
                        return ListTile(
                          leading: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(4),
                              color: const Color(0xFF1C2B66).withOpacity(0.8 - (index * 0.05)),
                            ),
                          ),
                          title: Text(
                            section,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Objective',
                            ),
                          ),
                          trailing: Text(
                            "$score%",
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              fontFamily: 'Objective',
                            ),
                          ),
                          onTap: () {}, // Optional: show details
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => const HomeWrapper(initialIndex: 0)),
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF1C2B66),
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "Continue to Dashboard",
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Objective',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                ],
              ),
            ),
    );
  }
}
