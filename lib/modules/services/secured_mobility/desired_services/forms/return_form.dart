import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../shared/widgets/glowing_arrows_button.dart';
import '../../providers/secured_mobility_provider.dart';

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
          onChanged: (_) => _debouncedSave(),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: dropoffController,
          decoration: inputDecoration.copyWith(labelText: 'Drop off address'),
          onChanged: (_) => _debouncedSave(),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Theme(
              data: Theme.of(context).copyWith(unselectedWidgetColor: Colors.black),
              child: Checkbox(
                value: returnSameAsPickup,
                activeColor: Colors.black,
                onChanged: (val) {
                  setState(() {
                    returnSameAsPickup = val ?? false;
                    if (returnSameAsPickup) {
                      returnDropoffController.text = pickupController.text;
                    } else {
                      returnDropoffController.clear();
                    }
                  });
                  _debouncedSave();
                },
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
        TextField(
          controller: returnDropoffController,
          enabled: !returnSameAsPickup,
          decoration: inputDecoration.copyWith(labelText: 'Return drop off address'),
          onTap: _handleReturnTap,
          onChanged: (_) => _debouncedSave(),
        ),
      ],
    );
  }
}