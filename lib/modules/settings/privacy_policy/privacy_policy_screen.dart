import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:halogen/shared/widgets/halogen_back_button.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
          'Privacy Policy',
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
            "This Privacy Policy outlines how Halogen collects, uses, and protects your personal information when you use our mobile application and services.",
      },
      {
        'title': "2. Information Collection",
        'body':
            "We collect personal information such as name, phone number, location data, and service preferences to provide and improve our security services.",
      },
      {
        'title': "3. Use of Information",
        'body':
            "Your information is used to deliver services, improve user experience, and notify you of updates. We do not sell or rent your data to third parties.",
      },
      {
        'title': "4. Data Security",
        'body':
            "We implement robust security measures to protect your information from unauthorized access, alteration, or disclosure.",
      },
      {
        'title': "5. Data Retention",
        'body':
            "Your personal data is retained only as long as necessary to fulfill the purposes outlined in this policy, or as required by law.",
      },
      {
        'title': "6. Third-Party Services",
        'body':
            "We may use third-party services (e.g., maps, payment processors) that have their own privacy practices. We advise reviewing their policies.",
      },
      {
        'title': "7. Your Rights",
        'body':
            "You have the right to access, update, or delete your data. You can also opt out of certain data uses by adjusting your settings.",
      },
      {
        'title': "8. Updates to Policy",
        'body':
            "This Privacy Policy may be updated periodically. Continued use of the app after changes indicates your acceptance of the new terms.",
      },
      {
        'title': "9. Contact Us",
        'body':
            "If you have any questions about this policy, contact us at support@halogen.com.",
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