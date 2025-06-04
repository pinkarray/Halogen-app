import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true, // ✅ Center the header
        title: FadeTransition( // ✅ Animate the title
          opacity: _fadeAnimation,
          child: const Text(
            'Notifications',
            style: TextStyle(
              fontFamily: 'Objective',
              color: Color(0xFF1C2B66),
              fontWeight: FontWeight.bold,
            ),
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
