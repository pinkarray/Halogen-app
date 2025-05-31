import 'package:flutter/material.dart';
import '../../../shared/widgets/halogen_back_button.dart';

class ActiveServicesScreen extends StatelessWidget {
  const ActiveServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFAEA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const HalogenBackButton(),
        title: const Text(
          'Active Services',
          style: TextStyle(
            fontFamily: 'Objective',
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Color(0xFF1C2B66),
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.shield_outlined, size: 64, color: Colors.grey),
              const SizedBox(height: 20),
              const Text(
                'You do not have any active services.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Objective',
                  fontSize: 16,
                  color: Color(0xFF1C2B66),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1C2B66),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/services');
                },
                child: const Text(
                  'Subscribe Now',
                  style: TextStyle(
                    fontFamily: 'Objective',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
