import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'providers/secured_mobility_provider.dart';
import '../../../shared/widgets/halogen_back_button.dart';
import '../../../shared/widgets/secured_mobility_progress_bar.dart';
import '../../../shared/widgets/underlined_glow_input_field.dart';
import '../../../shared/widgets/underlined_glow_custom_date_picker.dart';
import '../../../shared/widgets/underlined_glow_custom_time_picker.dart';

class ScheduleServiceScreen extends StatefulWidget {
  const ScheduleServiceScreen({super.key});

  @override
  State<ScheduleServiceScreen> createState() => _ScheduleServiceScreenState();
}

class _ScheduleServiceScreenState extends State<ScheduleServiceScreen> {
  final _pickupController = TextEditingController();
  final _dropoffController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    final provider = context.read<SecuredMobilityProvider>();
    _pickupController.text = provider.pickupLocation ?? '';
    _dropoffController.text = provider.dropoffLocation ?? '';
    _selectedDate = provider.pickupDate;
    _selectedTime = provider.pickupTime;

    _pickupController.addListener(_save);
    _dropoffController.addListener(_save);
  }

  void _save() {
    final provider = context.read<SecuredMobilityProvider>();
    provider.updateScheduleService(
      pickup: _pickupController.text,
      dropoff: _dropoffController.text,
      date: _selectedDate,
      time: _selectedTime,
    );

    final allSet = provider.pickupLocation?.isNotEmpty == true &&
        provider.dropoffLocation?.isNotEmpty == true &&
        provider.pickupDate != null &&
        provider.pickupTime != null;

    if (allSet && provider.currentStage < 3) {
      provider.markStageComplete(3);
      provider.calculateTotalCost();
    }
  }

  @override
  void dispose() {
    _pickupController.removeListener(_save);
    _dropoffController.removeListener(_save);
    _pickupController.dispose();
    _dropoffController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SecuredMobilityProvider>();

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
                // 🔹 Animated Header
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
                          'Schedule Service',
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

                // 🔹 Progress Bar
                SecuredMobilityProgressBar(
                  percent: provider.progressPercent,
                  currentStep: 3,
                ),

                const SizedBox(height: 24),

                const Text(
                  'Pick Up & Drop Off (One way)',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    fontFamily: 'Objective',
                    color: Color(0xFF1C2B66),
                  ),
                ),

                const SizedBox(height: 16),

                // 🔹 Input Fields
                UnderlinedGlowInputField(
                  label: 'Pick up location',
                  controller: _pickupController,
                  icon: Icons.my_location_outlined,
                  onChanged: (_) => _save(),
                ),
                const SizedBox(height: 16),

                UnderlinedGlowInputField(
                  label: 'Drop off location',
                  controller: _dropoffController,
                  icon: Icons.location_on_outlined,
                  onChanged: (_) => _save(),
                ),
                const SizedBox(height: 16),

                UnderlinedGlowCustomDatePickerField(
                  label: 'Pick up date',
                  selectedDate: _selectedDate,
                  onConfirm: (date) {
                    setState(() => _selectedDate = date);
                    _save();
                  },
                ),
                const SizedBox(height: 16),

                UnderlinedGlowCustomTimePickerField(
                  label: 'Pick up time',
                  selectedTime: _selectedTime,
                  onConfirm: (time) {
                    setState(() => _selectedTime = time);
                    _save();
                  },
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
