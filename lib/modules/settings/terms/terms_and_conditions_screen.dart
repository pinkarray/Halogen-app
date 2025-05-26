import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:halogen/shared/widgets/halogen_back_button.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

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
          'Terms & Conditions',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Objective',
            color: Color(0xFF1C2B66),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _buildAnimatedSections(),
        ).animate().fade(duration: 400.ms).slideY(begin: 0.1),
      ),
    );
  }

  List<Widget> _buildAnimatedSections() {
    const sections = [
      {
        'title': "1. Introduction",
        'body':
            "By using the Halogen Security App, you agree to the terms outlined below. These terms govern your access to and use of the app’s features, services, and content.",
      },
      {
        'title': "2. User Obligations",
        'body':
            "Users must provide accurate and up-to-date information, maintain the confidentiality of login credentials, and avoid any misuse of the app or its services.",
      },
      {
        'title': "3. Service Access",
        'body':
            "Halogen may limit, suspend, or terminate services without notice due to misuse, technical issues, or violations of these terms.",
      },
      {
        'title': "4. Liability",
        'body':
            "Halogen is not liable for damages resulting from the use or inability to use the app, including loss of data or service disruptions.",
      },
      {
        'title': "5. Changes to Terms",
        'body':
            "We reserve the right to update these terms at any time. Continued use of the app signifies your acceptance of any revised terms.",
      },
      {
        'title': "6. Contact",
        'body':
            "If you have any questions or concerns, please contact support@halogen.com.",
      },
    ];

    return sections.asMap().entries.map((entry) {
      final index = entry.key;
      final section = entry.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section['title']!,
            style: const TextStyle(
              fontFamily: 'Objective',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1C2B66),
            ),
          )
              .animate(delay: (100 * index).ms)
              .fade(duration: 400.ms)
              .slideY(begin: 0.2),
          const SizedBox(height: 8),
          Text(
            section['body']!,
            style: const TextStyle(
              fontFamily: 'Objective',
              fontSize: 14,
              color: Colors.black87,
            ),
          )
              .animate(delay: (150 * index).ms)
              .fade(duration: 400.ms)
              .slideY(begin: 0.2),
          const SizedBox(height: 24),
        ],
      );
    }).toList();
  }
}