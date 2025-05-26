import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AccessControlScreen extends StatelessWidget {
  const AccessControlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1C2B66),
      appBar: AppBar(
        backgroundColor: Color(0xFF1C2B66),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Access Control",
          style: TextStyle(
            fontFamily: 'Objective',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(Icons.vpn_key, size: 60, color: Color(0xFFFFCC29))
                .animate()
                .fade(duration: 500.ms)
                .scale(duration: 400.ms),
            SizedBox(height: 20),
            Text(
              "Access Control Services",
              style: TextStyle(
                fontSize: 20,
                fontFamily: 'Objective',
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 15),
            Text(
              "Includes biometric entry, RFID, magnetic locks, and more. You can view service status, monitor connected devices, and manage subscriptions from this panel.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Objective',
                color: Colors.white70,
              ),
            ),
            SizedBox(height: 40),
            // Add buttons, cards or monitoring components here
            Text(
              "Coming soon...",
              style: TextStyle(
                fontFamily: 'Objective',
                color: Colors.white38,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
