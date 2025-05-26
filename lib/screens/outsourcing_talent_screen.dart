import 'package:flutter/material.dart';

class OutsourcingTalentScreen extends StatelessWidget {
  const OutsourcingTalentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Outsourcing & Talent Risk'),
      ),
      body: const Center(
        child: Text(
          'This is the Outsourcing & Talent Risk screen.',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
