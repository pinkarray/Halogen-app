import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ResponseServicesScreen extends StatelessWidget {
  const ResponseServicesScreen({super.key});

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
          "Response Services",
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
            Icon(Icons.support_agent, size: 60, color: Color(0xFFFFCC29))
                .animate()
                .fade(duration: 500.ms)
                .scale(duration: 400.ms),
            SizedBox(height: 20),
            Text(
              "Emergency Response Services",
              style: TextStyle(
                fontSize: 20,
                fontFamily: 'Objective',
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 15),
            Text(
              "Includes 24/7 emergency dispatch, patrol backup, panic alert handling, and site incident response for rapid risk mitigation.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Objective',
                color: Colors.white70,
              ),
            ),
            SizedBox(height: 40),
            Text(
              "Response coordination features coming soon...",
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
