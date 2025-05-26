import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../shared/widgets/underlined_glow_input_field.dart';
import '../../providers/secured_mobility_provider.dart';

class FixedDurationForm extends StatefulWidget {
  const FixedDurationForm({super.key});

  @override
  State<FixedDurationForm> createState() => _FixedDurationFormState();
}

class _FixedDurationFormState extends State<FixedDurationForm> {
  final TextEditingController pickupController = TextEditingController();
  final TextEditingController dropoffController = TextEditingController();
  String? numberOfDays;
  String? interstate;

  final List<String> dayOptions = ['1 day', '2 days', '3 days', '4 days', '5 days'];
  final List<String> interstateOptions = ['Yes', 'No'];

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<SecuredMobilityProvider>(context, listen: false);

    pickupController.text = provider.pickupAddress;
    dropoffController.text = provider.dropoffAddress;
    numberOfDays = provider.numberOfDays != null
        ? '${provider.numberOfDays} day${provider.numberOfDays! > 1 ? 's' : ''}'
        : null;
    interstate = provider.interstateTravel;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (provider.tripType != 'Fixed Duration') {
        provider.selectTripType('Fixed Duration');
      }
    });
  }

  void _debouncedSave() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 300), () {
      final provider = Provider.of<SecuredMobilityProvider>(context, listen: false);
      provider.updateFixedDurationTrip(
        pickup: pickupController.text,
        dropoff: dropoffController.text,
        days: int.tryParse(numberOfDays?.split(' ').first ?? '') ?? 1,
        interstate: interstate ?? '',
      );
    });
  }

  void _immediateSave() {
    final provider = Provider.of<SecuredMobilityProvider>(context, listen: false);
    provider.updateFixedDurationTrip(
      pickup: pickupController.text,
      dropoff: dropoffController.text,
      days: int.tryParse(numberOfDays?.split(' ').first ?? '') ?? 1,
      interstate: interstate ?? '',
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _immediateSave();
    pickupController.dispose();
    dropoffController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        UnderlinedGlowInputField(
          controller: pickupController,
          label: 'Pick up address',
          icon: Icons.my_location_outlined,
          onChanged: (_) => _debouncedSave(),
        ),
        const SizedBox(height: 16),
        UnderlinedGlowInputField(
          controller: dropoffController,
          label: 'Drop off address',
          icon: Icons.location_on_outlined,
          onChanged: (_) => _debouncedSave(),
        ),
        const SizedBox(height: 16),
        UnderlinedGlowInputField(
          label: 'Number of Days',
          icon: Icons.calendar_today_outlined,
          controller: TextEditingController(text: numberOfDays),
          dropdownOptions: dayOptions,
          onChanged: (value) {
            setState(() => numberOfDays = value);
            _debouncedSave();
          },
        ),
        const SizedBox(height: 16),
        UnderlinedGlowInputField(
          label: 'Interstate Travel?',
          icon: Icons.map_outlined,
          controller: TextEditingController(text: interstate),
          dropdownOptions: interstateOptions,
          onChanged: (value) {
            setState(() => interstate = value);
            _debouncedSave();
          },
        ),
      ],
    );
  }
}