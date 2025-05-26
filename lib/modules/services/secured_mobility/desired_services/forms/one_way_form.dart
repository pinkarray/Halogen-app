import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/secured_mobility_provider.dart';
import '../../../../../shared/widgets/underlined_glow_input_field.dart';
import 'package:flutter_animate/flutter_animate.dart';

class OneWayForm extends StatefulWidget {
  const OneWayForm({super.key});

  @override
  State<OneWayForm> createState() => _OneWayFormState();
}

class _OneWayFormState extends State<OneWayForm> {
  final TextEditingController pickupController = TextEditingController();
  final TextEditingController dropoffController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<SecuredMobilityProvider>(context, listen: false);

    pickupController.text = provider.pickupAddress;
    dropoffController.text = provider.dropoffAddress;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (provider.tripType != 'One Way') {
        provider.selectTripType('One Way');
      }
    });
  }

  void _onFieldChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 300), () {
      final provider = Provider.of<SecuredMobilityProvider>(context, listen: false);
      provider.updateOneWayTrip(
        pickup: pickupController.text,
        dropoff: dropoffController.text,
      );
    });
  }

  void _immediateSave() {
    final provider = Provider.of<SecuredMobilityProvider>(context, listen: false);
    provider.updateOneWayTrip(
      pickup: pickupController.text,
      dropoff: dropoffController.text,
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
          label: 'Pick Up Address',
          controller: pickupController,
          icon: Icons.location_on,
          onChanged: (_) => _onFieldChanged(),
        ),
        const SizedBox(height: 16),
        UnderlinedGlowInputField(
          label: 'Drop Off Address',
          controller: dropoffController,
          icon: Icons.flag,
          onChanged: (_) => _onFieldChanged(),
        ),
      ],
    ).animate().fade(duration: 400.ms).slideY(begin: 0.3, end: 0);
  }
}