import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../shared/widgets/glowing_arrows_button.dart';
import '../../providers/secured_mobility_provider.dart';
import '../../../../../shared/widgets/underlined_glow_input_field.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ReturnForm extends StatefulWidget {
  const ReturnForm({super.key});

  @override
  State<ReturnForm> createState() => _ReturnFormState();
}

class _ReturnFormState extends State<ReturnForm> {
  final TextEditingController pickupController = TextEditingController();
  final TextEditingController dropoffController = TextEditingController();
  final TextEditingController returnDropoffController = TextEditingController();
  bool returnSameAsPickup = false;
  bool _tappedReturn = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<SecuredMobilityProvider>(context, listen: false);

    pickupController.text = provider.pickupAddress;
    dropoffController.text = provider.dropoffAddress;
    returnDropoffController.text = provider.returnDropoffAddress;
    returnSameAsPickup = pickupController.text == returnDropoffController.text;

    if (returnSameAsPickup) {
      returnDropoffController.text = pickupController.text;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (provider.tripType != 'Return') {
        provider.selectTripType('Return');
      }
    });
  }
  
  void _debouncedSave() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 300), () {
      final provider = Provider.of<SecuredMobilityProvider>(context, listen: false);
      provider.updateReturnTrip(
        pickup: pickupController.text,
        dropoff: dropoffController.text,
        returnDropoff: returnDropoffController.text,
      );
    });
  }

  void _handleReturnTap() {
    if (!_tappedReturn && !returnSameAsPickup) {
      setState(() => _tappedReturn = true);

      Future.delayed(const Duration(milliseconds: 200), () {
        if (!mounted) return; 
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: SizedBox(
              height: 200,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Extra Cost Alert',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Objective',
                    ),
                  ),
                  const Text(
                    'Your return address is different from pick-up, which attracts extra charges.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, fontFamily: 'Objective'),
                  ),
                  GlowingArrowsButton(
                    text: 'Okay',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          ),
        );
      });
    }
  }

  void _immediateSave() {
    final provider = Provider.of<SecuredMobilityProvider>(context, listen: false);
    provider.updateReturnTrip(
      pickup: pickupController.text,
      dropoff: dropoffController.text,
      returnDropoff: returnDropoffController.text,
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        UnderlinedGlowInputField(
          controller: pickupController,
          label: 'Pick up address',
          icon: Icons.my_location_outlined,
          onChanged: (_) => _debouncedSave(),
        ).animate().fade(duration: 300.ms).slideY(begin: 0.05),
        const SizedBox(height: 16),
        UnderlinedGlowInputField(
          controller: dropoffController,
          label: 'Drop off address',
          icon: Icons.location_on_outlined,
          onChanged: (_) => _debouncedSave(),
        ).animate().fade(duration: 300.ms).slideY(begin: 0.1),
        const SizedBox(height: 16),
        Row(
          children: [
            Theme(
              data: Theme.of(context).copyWith(unselectedWidgetColor: Colors.black),
              child: Checkbox(
                value: returnSameAsPickup,
                activeColor: const Color(0xFF1C2B66),
                onChanged: (val) {
                  setState(() {
                    returnSameAsPickup = val ?? false;
                    if (returnSameAsPickup) {
                      returnDropoffController.text = pickupController.text;
                    } else {
                      returnDropoffController.clear();

                      // Show modal when user unchecks and pickup is not empty
                      if (!_tappedReturn && pickupController.text.trim().isNotEmpty) {
                        _handleReturnTap();
                      }
                    }
                  });
                  _debouncedSave();
                }
              ),
            ),
            const Expanded(
              child: Text(
                'Drop off address is the same with first trip pick up address',
                style: TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            if (!returnSameAsPickup) _handleReturnTap();
          },
          child: IgnorePointer(
            ignoring: returnSameAsPickup,
            child: UnderlinedGlowInputField(
              controller: returnDropoffController,
              label: 'Return drop off address',
              icon: Icons.undo_outlined,
              onChanged: (_) => _debouncedSave(),
            ),
          ),
        ).animate().fade(duration: 300.ms).slideY(begin: 0.2),
      ],
    );
  }
}