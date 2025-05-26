import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/glowing_arrows_button.dart';
import './providers/physical_security_provider.dart';
import 'dart:async';

class LocationConfirmationScreen extends StatefulWidget {
  const LocationConfirmationScreen({super.key});

  @override
  State<LocationConfirmationScreen> createState() => _LocationConfirmationScreenState();
}

class _LocationConfirmationScreenState extends State<LocationConfirmationScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  LatLng? _userLocation;
  final TextEditingController _addressController = TextEditingController();
  bool _showConfirmationModal = false;
  bool isAddressValid = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();

    final provider = Provider.of<PhysicalSecurityProvider>(context, listen: false);
    if (provider.addressConfirmed && provider.state.isNotEmpty) {
      _addressController.text = provider.state;
      isAddressValid = true;
    }

    _addressController.addListener(() {
      setState(() {
        isAddressValid = _addressController.text.trim().isNotEmpty;
      });
    });
  }

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
      });
    }
  }

  void _confirmAddress() {
    if (_addressController.text.isNotEmpty) {
      setState(() {
        _showConfirmationModal = true;
      });
    }
  }

  void _completeConfirmation() {
    final provider = Provider.of<PhysicalSecurityProvider>(context, listen: false);
    provider.updateInspectionData(
      stateText: _addressController.text.trim(),
      confirmed: true,
    );

    Navigator.pop(context, true); // Return to previous screen with "confirmed"
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (_userLocation != null)
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _userLocation!,
                zoom: 14,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId('userPin'),
                  position: _userLocation!,
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                )
              },
              onMapCreated: (controller) => _controller.complete(controller),
            )
          else
            const Center(child: CircularProgressIndicator()),

          // Address Input
          Positioned(
            bottom: 100,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Enter your address details",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Objective',
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
                  ),
                  child: TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Input your address',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                GlowingArrowsButton(
                  text: 'Confirm',
                  onPressed: isAddressValid ? _confirmAddress : null,
                ),
              ],
            ),
          ),

          // Confirmation Modal
          if (_showConfirmationModal)
            Container(
              color: Colors.black.withValues(alpha: 128),
              child: Center(
                child: Container(
                  margin: const EdgeInsets.all(32),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset('assets/images/logocut.png', height: 48),
                      const SizedBox(height: 16),
                      const Text(
                        'Address Confirmed!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Objective',
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Your location address has been confirmed on the map. You will now deal with the details of the inspection.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: Colors.black54, fontFamily: 'Objective'),
                      ),
                      const SizedBox(height: 20),
                      GlowingArrowsButton(text: 'Okay', onPressed: _completeConfirmation),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
