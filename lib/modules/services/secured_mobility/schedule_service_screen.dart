import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/secured_mobility_provider.dart';
import '../../../shared/widgets/halogen_back_button.dart';

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

    // Auto-save when user types
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

    if (provider.pickupLocation?.isNotEmpty == true &&
        provider.dropoffLocation?.isNotEmpty == true &&
        provider.pickupDate != null &&
        provider.pickupTime != null &&
        provider.currentStage < 4) {
      provider.markStageComplete(4);
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
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            height: constraints.maxHeight,
            width: double.infinity,
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
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            HalogenBackButton(),
                            SizedBox(width: 12),
                            Text(
                              'Schedule Service',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Objective',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Pick Up & Drop Off (One way)',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            fontFamily: 'Objective',
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Pick up location', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 6),
                              TextField(
                                controller: _pickupController,
                                decoration: const InputDecoration(
                                  hintText: 'Enter location',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text('Drop off location', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 6),
                              TextField(
                                controller: _dropoffController,
                                decoration: const InputDecoration(
                                  hintText: 'Enter location',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text('Pick up date', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 6),
                              GestureDetector(
                                onTap: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: _selectedDate ?? DateTime.now(),
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime(2100),
                                  );
                                  if (date != null) {
                                    setState(() {
                                      _selectedDate = date;
                                    });
                                    _save();
                                  }
                                },
                                child: InputDecorator(
                                  decoration: const InputDecoration(
                                    hintText: 'Pick your preferred date',
                                    border: OutlineInputBorder(),
                                    suffixIcon: Icon(Icons.calendar_today, color: Colors.black),
                                  ),
                                  child: Text(
                                    _selectedDate != null
                                        ? '${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}'
                                        : '',
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text('Pick up time', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 6),
                              GestureDetector(
                                onTap: () async {
                                  final time = await showTimePicker(
                                    context: context,
                                    initialTime: _selectedTime ?? TimeOfDay.now(),
                                  );
                                  if (time != null) {
                                    setState(() {
                                      _selectedTime = time;
                                    });
                                    _save();
                                  }
                                },
                                child: InputDecorator(
                                  decoration: const InputDecoration(
                                    hintText: 'Pick your preferred time',
                                    border: OutlineInputBorder(),
                                    suffixIcon: Icon(Icons.access_time, color: Colors.black),
                                  ),
                                  child: Text(
                                    _selectedTime != null
                                        ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
                                        : '',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}