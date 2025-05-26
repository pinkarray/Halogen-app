import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/physical_security_progress_bar.dart';
import '../../../shared/widgets/halogen_back_button.dart';
import '../../../shared/widgets/glowing_arrows_button.dart';
import '../../../shared/widgets/underlined_glow_custom_date_picker.dart';
import '../../../shared/widgets/underlined_glow_custom_time_picker.dart';
import '../../../shared/widgets/underlined_glow_input_field.dart';
import '../../../shared/widgets/bounce_tap.dart';
import '../../../shared/helpers/session_manager.dart';
import 'location_confirmation_screen.dart';
import 'desired_services_screen.dart';
import 'providers/physical_security_provider.dart';

class PhysicalSecurityScreen extends StatefulWidget {
  const PhysicalSecurityScreen({super.key});

  @override
  State<PhysicalSecurityScreen> createState() => _PhysicalSecurityScreenState();
}

class _PhysicalSecurityScreenState extends State<PhysicalSecurityScreen> {
  final _formKey = GlobalKey<FormState>();
  final houseNumberController = TextEditingController();
  final streetNameController = TextEditingController();
  final areaController = TextEditingController();
  final stateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<PhysicalSecurityProvider>(context, listen: false);

    houseNumberController.text = provider.houseNumber;
    streetNameController.text = provider.streetName;
    areaController.text = provider.area;
    stateController.text = provider.state;

    Future.microtask(() async {
      final userProfile = await SessionManager.getUserProfile();
      if (userProfile != null) {
        if (provider.houseNumber.isEmpty && userProfile['houseNumber'] != null) {
          provider.updateInspectionData(houseNum: userProfile['houseNumber']);
          houseNumberController.text = userProfile['houseNumber'];
        }
        if (provider.streetName.isEmpty && userProfile['streetName'] != null) {
          provider.updateInspectionData(street: userProfile['streetName']);
          streetNameController.text = userProfile['streetName'];
        }
        if (provider.area.isEmpty && userProfile['area'] != null) {
          provider.updateInspectionData(areaText: userProfile['area']);
          areaController.text = userProfile['area'];
        }
        if (provider.state.isEmpty && userProfile['state'] != null) {
          provider.updateInspectionData(stateText: userProfile['state']);
          stateController.text = userProfile['state'];
        }
      }
    });
  }

  @override
  void dispose() {
    houseNumberController.dispose();
    streetNameController.dispose();
    areaController.dispose();
    stateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PhysicalSecurityProvider>(context);
    int currentStep = provider.addressConfirmed ? 2 : 1;
    if (currentStep > 6) currentStep = 6;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.white, Color(0xFFFFFAEA)],
              ),
            ),
          ),
          SafeArea(
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
                        effects: [FadeEffect(duration: 400.ms), SlideEffect(begin: const Offset(0, 0.3), end: Offset.zero)],
                        child: const Text(
                          "Physical Security",
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
                PhysicalSecurityProgressBar(
                  currentStep: 1,
                  percent: provider.progressPercent,
                ),
                const SizedBox(height: 24),
                const Text("Site Inspection", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Objective', color: Color(0xFF1C2B66),)),
                const SizedBox(height: 4),
                const Text("Pick a date and time convenient for you", style: TextStyle(fontSize: 13, color: Color(0xFF1C2B66))),
                const SizedBox(height: 16),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: UnderlinedGlowCustomDatePickerField(
                              label: 'Preferred Date',
                              selectedDate: provider.preferredDate,
                              onConfirm: (date) => provider.updateInspectionData(date: date),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: UnderlinedGlowCustomTimePickerField(
                              label: 'Preferred Time',
                              selectedTime: provider.preferredTime,
                              onConfirm: (time) => provider.updateInspectionData(time: time),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: UnderlinedGlowInputField(
                              label: 'House Number',
                              controller: houseNumberController,
                              icon: Icons.home,
                              onChanged: (val) => provider.updateInspectionData(houseNum: val.trim()),
                              textCapitalization: TextCapitalization.words,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: UnderlinedGlowInputField(
                              label: 'Street Name',
                              controller: streetNameController,
                              icon: Icons.map_outlined,
                              onChanged: (val) => provider.updateInspectionData(street: val.trim()),
                              textCapitalization: TextCapitalization.words,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: UnderlinedGlowInputField(
                              label: 'Area',
                              controller: areaController,
                              icon: Icons.location_city,
                              onChanged: (val) => provider.updateInspectionData(areaText: val.trim()),
                              textCapitalization: TextCapitalization.words,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: UnderlinedGlowInputField(
                              label: 'State',
                              controller: stateController,
                              icon: Icons.public,
                              onChanged: (val) => provider.updateInspectionData(stateText: val.trim()),
                              textCapitalization: TextCapitalization.words,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      BounceTap(
                        onTap: () async {
                          final confirmed = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const LocationConfirmationScreen()),
                          );
                          if (confirmed == true) {
                            provider.updateInspectionData(confirmed: true);
                          }
                        },
                        child: Row(
                          children: [
                            const Icon(Icons.location_pin, color: Colors.red),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                provider.addressConfirmed
                                    ? 'Address confirmed'
                                    : 'Input your address on the map for confirmation',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontFamily: 'Objective',
                                  color: provider.addressConfirmed ? Colors.black : Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      GlowingArrowsButton(
                        text: 'Send',
                        enabled: provider.isFormComplete,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const DesiredServicesScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}