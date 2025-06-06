import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/glowing_arrows_button.dart';
import './providers/physical_security_provider.dart';
import 'dart:async';

class LocationConfirmationScreen extends StatefulWidget {
  const LocationConfirmationScreen({super.key});

  @override
  State<LocationConfirmationScreen> createState() =>
      _LocationConfirmationScreenState();
}

class _LocationConfirmationScreenState
    extends State<LocationConfirmationScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  LatLng? _userLocation;
  Marker? _searchedMarker;

  final TextEditingController _addressController = TextEditingController();
  bool _showConfirmationModal = false;
  bool isAddressValid = false;

  final String _apiKey = "AIzaSyAaiPtxv3rVnlsRXa-cUxtm5nuGFu5So5Y"; 

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();

    final provider =
        Provider.of<PhysicalSecurityProvider>(context, listen: false);
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
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
      });
    }
  }

  Future<void> _searchAndNavigate(String address) async {
    if (address.trim().isEmpty) return;

    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(address)}, Nigeria&key=$_apiKey',
    );

    final response = await http.get(url);
    final json = jsonDecode(response.body);

    if (json['status'] == 'OK') {
      final location = json['results'][0]['geometry']['location'];
      final latLng = LatLng(location['lat'], location['lng']);

      final controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newLatLngZoom(latLng, 15));

      setState(() {
        _searchedMarker = Marker(
          markerId: const MarkerId('searchedLocation'),
          position: latLng,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location not found")),
      );
    }
  }

  void _confirmAddress() {
    if (_addressController.text.isNotEmpty) {
      _searchAndNavigate(_addressController.text);
      setState(() {
        _showConfirmationModal = true;
      });
    }
  }

  void _completeConfirmation() {
    final provider =
        Provider.of<PhysicalSecurityProvider>(context, listen: false);
    provider.updateInspectionData(
      stateText: _addressController.text.trim(),
      confirmed: true,
    );

    Navigator.pop(context, true);
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
                ),
                if (_searchedMarker != null) _searchedMarker!,
              },
              onMapCreated: (controller) => _controller.complete(controller),
            )
          else
            const Center(child: CircularProgressIndicator()),
          Positioned(
            top: 40,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Color(0xFF1C2B66)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _addressController,
                      onSubmitted: _searchAndNavigate,
                      textCapitalization: TextCapitalization.words,
                      style: const TextStyle(fontFamily: 'Objective'),
                      decoration: InputDecoration(
                        hintText: 'Search for a location...',
                        hintStyle: const TextStyle(color: Colors.black54),
                        border: InputBorder.none, 
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero, 
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: 100,
            left: 20,
            right: 20,
            child: GlowingArrowsButton(
              text: 'Confirm',
              onPressed: isAddressValid ? _confirmAddress : null,
            ),
          ),

          if (_showConfirmationModal)
            Container(
              color: Colors.black.withOpacity(0.5),
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
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                          fontFamily: 'Objective',
                        ),
                      ),
                      const SizedBox(height: 20),
                      GlowingArrowsButton(
                        text: 'Okay',
                        onPressed: _completeConfirmation,
                      ),
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
