import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './providers/outsourcing_talent_provider.dart';
import '../../../shared/widgets/halogen_back_button.dart';
import '../../../shared/widgets/outsourcing_progress_bar.dart';
import '../../../shared/widgets/bounce_tap.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_animate/flutter_animate.dart';

class OutsourcingTalentScreen extends StatelessWidget {
  const OutsourcingTalentScreen({super.key});

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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Animated Header
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: HalogenBackButton(),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          'Outsourcing & Talent Risk Management',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Objective',
                            color: Color(0xFF1C2B66),
                            height: 1.3,
                          ),
                        ),
                      )
                          .animate()
                          .fade(duration: 500.ms)
                          .slideY(begin: 0.2),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                OutsourcingProgressBar(
                  currentStep: provider.currentStage,
                  stage1Completed: provider.stage1Completed,
                  stage2Completed: provider.stage2Completed,
                  stage3Completed: provider.stage3Completed,
                ),

                const SizedBox(height: 24),

                _buildTile(
                  context,
                  'Desired Services',
                  '/outsourcing-talent/desired-services',
                  provider.isAnyDesiredServiceSelected,
                  true,
                ).animate().fade().slideY(begin: 0.1),

                _buildTile(
                  context,
                  'Description of Need',
                  '/outsourcing-talent/description',
                  provider.stage2Completed,
                  true,
                ).animate().fade().slideY(begin: 0.2),

                _buildTile(
                  context,
                  'Confirmation',
                  '/outsourcing-talent/confirmation',
                  provider.stage3Completed,
                  true,
                ).animate().fade().slideY(begin: 0.3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTile(
    BuildContext context,
    String label,
    String route,
    bool completed,
    bool enabled,
  ) {
    IconData icon;

    switch (label) {
      case 'Desired Services':
        icon = Icons.assignment_outlined;
        break;
      case 'Description of Need':
        icon = Icons.description_outlined;
        break;
      case 'Confirmation':
        icon = Icons.checklist_outlined;
        break;
      default:
        icon = Icons.precision_manufacturing_outlined;
    }

    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: BounceTap(
        onTap: () {
          if (enabled) {
            Navigator.pushNamed(context, route);
          } else {
            Fluttertoast.showToast(
              msg: "Please complete the previous step first.",
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.black87,
              textColor: Colors.white,
              fontSize: 14,
            );
          }
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, size: 24, color: Colors.black),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Objective',
                  ),
                ),
              ),
              if (completed)
                const Icon(Icons.check_circle, color: Colors.green, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}