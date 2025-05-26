import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontFamily: 'Objective',
            color: Color(0xFF1C2B66),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFF1C2B66)),
        elevation: 0,
      ),
      body: const Center(
        child: Text(
          'No notifications yet.',
          style: TextStyle(fontFamily: 'Objective', fontSize: 16),
        ),
      ),
    );
  }
}