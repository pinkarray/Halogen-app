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
  bool _isLoading = true;
  bool _hasLocationPermission = false;
  bool _locationServicesEnabled = false;

  // Text input functionality commented out
  // final TextEditingController _addressController = TextEditingController();
  // final FocusNode _addressFocusNode = FocusNode();
  bool _showConfirmationModal = false;

  final String _apiKey = "AIzaSyAaiPtxv3rVnlsRXa-cUxtm5nuGFu5So5Y";

  @override
  void initState() {
    super.initState();
    _initializeLocation();

    // Provider initialization commented out since we're not using text input
    // final provider =
    // Provider.of<PhysicalSecurityProvider>(context, listen: false);
    // if (provider.addressConfirmed && provider.state.isNotEmpty) {
    //   _addressController.text = provider.state;
    // }
  }

  @override
  void dispose() {
    // Cleanup commented out since we're not using text input
    // _addressController.dispose();
    // _addressFocusNode.dispose();
    super.dispose();
  }

  Future<void> _initializeLocation() async {
    _locationServicesEnabled = await Geolocator.isLocationServiceEnabled();
    if (!_locationServicesEnabled) {
      setState(() => _isLoading = false);
      return;
    }

    await _checkLocationPermission();
    if (_hasLocationPermission) {
      await _getCurrentLocation();
    }
    setState(() => _isLoading = false);
  }

  Future<void> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location permissions are denied")),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location permissions are permanently denied. Please enable in settings")),
      );
      return;
    }

    setState(() => _hasLocationPermission = true);
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error getting location: ${e.toString()}")),
      );
    }
  }

  // Search functionality commented out
  // Future<void> _searchAndNavigate(String address) async {
  //   if (address.trim().isEmpty) return;
  //
  //   final url = Uri.parse(
  //     'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(address)}, Nigeria&key=$_apiKey',
  //   );
  //
  //   try {
  //     final response = await http.get(url);
  //     final json = jsonDecode(response.body);
  //
  //     if (json['status'] == 'OK') {
  //       final location = json['results'][0]['geometry']['location'];
  //       final latLng = LatLng(location['lat'], location['lng']);
  //
  //       final controller = await _controller.future;
  //       controller.animateCamera(CameraUpdate.newLatLngZoom(latLng, 15));
  //
  //       setState(() {
  //         _searchedMarker = Marker(
  //           markerId: const MarkerId('searchedLocation'),
  //           position: latLng,
  //           icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
  //         );
  //       });
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text(json['error_message'] ?? "Location not found")),
  //       );
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Error searching location: ${e.toString()}")),
  //     );
  //   }
  // }

  // Address confirmation commented out
  // void _confirmAddress() {
  //   if (_addressController.text.isNotEmpty) {
  //     _searchAndNavigate(_addressController.text);
  //     setState(() {
  //       _showConfirmationModal = true;
  //     });
  //   }
  // }

  void _completeConfirmation() {
    final provider =
    Provider.of<PhysicalSecurityProvider>(context, listen: false);
    provider.updateInspectionData(
      // Using empty string since we're not using text input
      stateText: '', // _addressController.text.trim(),
      confirmed: true,
    );

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (!_locationServicesEnabled)
            const Center(child: Text("Location services are disabled. Please enable them to continue"))
          else if (_userLocation == null)
              const Center(child: Text("Could not determine your location"))
            else
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
                onMapCreated: (controller) {
                  _controller.complete(controller);
                },
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
              ),

          // Search bar commented out
          // if (!_isLoading)
          //   Positioned(
          //     top: MediaQuery.of(context).padding.top + 10,
          //     left: 20,
          //     right: 20,
          //     child: Container(
          //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          //       decoration: BoxDecoration(
          //         color: Colors.white,
          //         borderRadius: BorderRadius.circular(12),
          //         boxShadow: [
          //           BoxShadow(
          //             color: Colors.black.withOpacity(0.1),
          //             blurRadius: 6,
          //             offset: const Offset(0, 2),
          //           ),
          //         ],
          //       ),
          //       child: Row(
          //         children: [
          //           const Icon(Icons.search, color: Color(0xFF1C2B66)),
          //           const SizedBox(width: 10),
          //           Expanded(
          //             child: TextField(
          //               controller: _addressController,
          //               focusNode: _addressFocusNode,
          //               onSubmitted: _searchAndNavigate,
          //               textCapitalization: TextCapitalization.words,
          //               style: const TextStyle(fontFamily: 'Objective'),
          //               decoration: InputDecoration(
          //                 hintText: 'Search for a location...',
          //                 hintStyle: const TextStyle(color: Colors.black54),
          //                 border: InputBorder.none,
          //                 focusedBorder: InputBorder.none,
          //                 enabledBorder: InputBorder.none,
          //                 contentPadding: EdgeInsets.zero,
          //                 isDense: true,
          //               ),
          //             ),
          //           ),
          //           if (_addressController.text.isNotEmpty)
          //             IconButton(
          //               icon: const Icon(Icons.clear, size: 20),
          //               onPressed: () {
          //                 _addressController.clear();
          //                 setState(() {});
          //               },
          //             ),
          //         ],
          //       ),
          //     ),
          //   ),

          // Confirm button modified to work without text input
          if (!_isLoading && _userLocation != null)
            Positioned(
              bottom: 100,
              left: 20,
              right: 20,
              child: GlowingArrowsButton(
                text: 'Confirm Location',
                onPressed: () {
                  // Directly show confirmation since we're not using text input
                  setState(() {
                    _showConfirmationModal = true;
                  });
                },
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
                        'Location Confirmed!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Objective',
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Your current location has been confirmed on the map.',
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