import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/secured_mobility_provider.dart';

class OneWayForm extends StatefulWidget {
  const OneWayForm({super.key});

  @override
  State<OneWayForm> createState() => _OneWayFormState();
}

class _OneWayFormState extends State<OneWayForm> {
  final TextEditingController pickupController = TextEditingController();
  final TextEditingController dropoffController = TextEditingController();
  final TextEditingController returnDropoffController = TextEditingController();
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
    returnDropoffController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const inputDecoration = InputDecoration(
      labelStyle: TextStyle(color: Colors.black),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black, width: 1.5),
      ),
      border: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: pickupController,
          decoration: inputDecoration.copyWith(labelText: 'Pick up address'),
          onChanged: (_) => _onFieldChanged(),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: dropoffController,
          decoration: inputDecoration.copyWith(labelText: 'Drop off address'),
          onChanged: (_) => _onFieldChanged(),
        ),
      ],
    );
  }
}
