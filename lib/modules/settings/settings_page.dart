import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:halogen/shared/widgets/halogen_back_button.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFAEA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const HalogenBackButton(),
        centerTitle: true,
        title: const Text(
          'SOS',
          style: TextStyle(
            fontFamily: 'Objective',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1C2B66),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
        child: Column(
          children: [
            _buildSOSCard(context)
                .animate()
                .fade(duration: 400.ms)
                .slideY(begin: 0.2),
          ],
        ),
      ),
    );
  }

  Widget _buildSOSCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Emergency SOS',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Objective',
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF1C2B66),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Quickly call emergency services and notify your emergency contacts.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Objective',
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // TODO: Activate SOS
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
              ),
              child: const Text(
                'Activate SOS',
                style: TextStyle(
                  fontFamily: 'Objective',
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}