import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../shared/widgets/halogen_back_button.dart';
import '../../../../shared/widgets/secured_mobility_progress_bar.dart';
import '../../../../shared/widgets/trip_option_tile.dart';
import './../providers/secured_mobility_provider.dart';
import 'forms/one_way_form.dart';
import 'forms/return_form.dart';
import 'forms/fixed_duration_form.dart';

class SecuredMobilityDesiredServicesScreen extends StatefulWidget {
  const SecuredMobilityDesiredServicesScreen({super.key});

  @override
  State<SecuredMobilityDesiredServicesScreen> createState() => _SecuredMobilityDesiredServicesScreenState();
}

class _SecuredMobilityDesiredServicesScreenState extends State<SecuredMobilityDesiredServicesScreen> {
  @override
  void initState() {
    super.initState();
    final provider = Provider.of<SecuredMobilityProvider>(context, listen: false);
    provider.initSelectedTrip();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SecuredMobilityProvider>(
      builder: (context, provider, _) {
        final selectedTrip = provider.selectedTripType;

        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                            'Desired Services',
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
                    currentStep: provider.currentStage,
                  ),
                  const SizedBox(height: 24),
                  TripOptionTile(
                    isSelected: selectedTrip == 'One Way',
                    title: 'Pick Up & Drop Off (One way)',
                    description: 'Move from your starting point to your destination without a return trip.',
                    onTap: () => provider.updateTripType('One Way'),
                    child: selectedTrip == 'One Way' ? const OneWayForm() : null,
                  ),
                  TripOptionTile(
                    isSelected: selectedTrip == 'Return',
                    title: 'Pick Up & Drop Off (Return)',
                    description: 'Get picked up, dropped off, and returned to your destination.',
                    onTap: () => provider.updateTripType('Return'),
                    child: selectedTrip == 'Return' ? const ReturnForm() : null,
                  ),
                  TripOptionTile(
                    isSelected: selectedTrip == 'Fixed Duration',
                    title: 'Fixed Duration',
                    description: 'Use the service for a fixed time before returning to your original location.',
                    onTap: () => provider.updateTripType('Fixed Duration'),
                    child: selectedTrip == 'Fixed Duration' ? const FixedDurationForm() : null,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}