import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/outsourcing_talent_provider.dart';
import '../../../../shared/widgets/halogen_back_button.dart';
import '../../../../shared/widgets/outsourcing_progress_bar.dart';
import 'domestic_staff/domestic_staff_bottom_sheet.dart';
import 'business_staff/business_staff_bottom_sheet.dart';
import 'background_check/background_checks_bottom_sheet.dart';
import 'investigation/investigation_bottom_sheet.dart';
import 'lea_liaison_service/lea_liaison_services_bottom_sheet.dart';
import 'package:flutter_animate/flutter_animate.dart';

class OutsourcingDesiredServicesScreen extends StatelessWidget {
  const OutsourcingDesiredServicesScreen({super.key});

  final services = const [
    'Domestic Staff',
    'Business Staff',
    'Background Checks',
    'Investigation',
    'LEA Liaison Services',
  ];

  final sectionKeys = const [
    'domestic_staff',
    'business_staff',
    'background_checks',
    'investigation',
    'lea_liaison',
  ];

  Widget? _getBottomSheet(String key) {
    switch (key) {
      case 'domestic_staff':
        return const DomesticStaffBottomSheet();
      case 'business_staff':
        return const BusinessStaffBottomSheet();
      case 'background_checks':
        return const BackgroundChecksBottomSheet();
      case 'investigation':
        return const InvestigationBottomSheet();
      case 'lea_liaison':
        return const LeaLiaisonServicesBottomSheet();
      default:
        return null;
    }
  }

  Future<void> _openBottomSheet(BuildContext context, String key) async {
    final sheet = _getBottomSheet(key);
    if (sheet != null) {
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => sheet,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OutsourcingTalentProvider>();

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Color(0xFFFFFAEA)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: HalogenBackButton(),
                    ),
                    const Text(
                      'Desired Services',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Objective',
                        color: Color(0xFF1C2B66),
                      ),
                    ).animate().fade(duration: 500.ms).slideY(begin: 0.2),
                  ],
                ),

                const SizedBox(height: 24),

                OutsourcingProgressBar(
                  currentStep: provider.currentStage,
                  stage1Completed: provider.stage1Completed,
                  stage2Completed: provider.stage2Completed,
                  stage3Completed: provider.stage3Completed,
                ),

                const SizedBox(height: 24),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(235),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      )
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    children: List.generate(services.length, (index) {
                      final title = services[index];
                      final key = sectionKeys[index];
                      final isChecked = provider.isSectionComplete(key);

                      return Column(
                        children: [
                          ListTile(
                            onTap: () => _openBottomSheet(context, key),
                            leading: Checkbox(
                              value: isChecked,
                              onChanged: (_) => _openBottomSheet(context, key),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              activeColor: Colors.black,
                            ),
                            title: Text(
                              title,
                              style: const TextStyle(
                                fontSize: 14,
                                fontFamily: 'Objective',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: Colors.black,
                              ),
                              onPressed: () => _openBottomSheet(context, key),
                            ),
                          )
                              .animate()
                              .fade(duration: 300.ms)
                              .slideY(begin: 0.05 * index), // stagger animation
                          if (index != services.length - 1)
                            const Divider(height: 1, color: Color(0xFFE0E0E0)),
                        ],
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}