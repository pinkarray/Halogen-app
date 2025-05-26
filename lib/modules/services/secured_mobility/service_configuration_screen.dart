import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/halogen_back_button.dart';
import '../../../shared/widgets/service_option_group.dart';
import '../../../shared/widgets/secured_mobility_progress_bar.dart';
import './providers/secured_mobility_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SecuredMobilityServiceConfigurationScreen extends StatelessWidget {
  const SecuredMobilityServiceConfigurationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SecuredMobilityProvider>(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (provider.isServiceConfigurationComplete && provider.currentStage < 2) {
        provider.markStageComplete(2);
      }
    });

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFFFFAEA)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 Animated Centered Header
                Row(
                  children: [
                    const HalogenBackButton(),
                    Expanded(
                      child: Animate(
                        effects: [
                          FadeEffect(duration: 400.ms),
                          SlideEffect(begin: const Offset(0, 0.3), end: Offset.zero),
                        ],
                        child: const Text(
                          'Service Configuration',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Objective',
                            color: Color(0xFF1C2B66),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),

                const SizedBox(height: 20),

                SecuredMobilityProgressBar(
                  percent: provider.progressPercent,
                  currentStep: 2,
                ),

                const SizedBox(height: 24),

                
                const ServiceOptionGroup(
                  title: 'Vehicle Choice',
                  sectionKey: 'vehicle_choice',
                  options: ['SUV', 'Sedan'],
                ),
                const SizedBox(height: 20),

                const ServiceOptionGroup(
                  title: 'Pilot Vehicle (Hilux)',
                  sectionKey: 'pilot_vehicle',
                  options: ['Yes', 'No'],
                ),
                const SizedBox(height: 20),

                const ServiceOptionGroup(
                  title: 'In Car Protection',
                  sectionKey: 'in_car_protection',
                  options: [
                    'Unarmed - Closed Protection Officer',
                    'Armed - LEA (Law Enforcement Agent)',
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
