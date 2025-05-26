import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:halogen/shared/widgets/halogen_back_button.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  void _launchPhone() async {
    final uri = Uri(scheme: 'tel', path: '+2348000000000');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("Could not launch phone dialer");
    }
  }

  void _launchEmail() async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'support@halogen.com',
      query: 'subject=Halogen App Support',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("Could not launch email app");
    }
  }

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
          'Support',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Objective',
            color: Color(0xFF1C2B66),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildContactCard(
              icon: Icons.phone_in_talk,
              title: "Call Us",
              subtitle: "Get immediate assistance",
              onTap: _launchPhone,
              delayMs: 0,
            ),
            const SizedBox(height: 16),
            _buildContactCard(
              icon: Icons.email_outlined,
              title: "Email Us",
              subtitle: "Send a detailed message",
              onTap: _launchEmail,
              delayMs: 150,
            ),
            const Spacer(),
            Column(
              children: const [
                Text(
                  "Available 24/7",
                  style: TextStyle(
                    fontFamily: 'Objective',
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "Avg. response time: under 5 minutes",
                  style: TextStyle(
                    fontFamily: 'Objective',
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ],
            ).animate().fade(delay: 500.ms).slideY(begin: 0.2),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required int delayMs,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 28, color: Color(0xFF1C2B66)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Objective',
                      color: Color(0xFF1C2B66),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                      fontFamily: 'Objective',
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ).animate(delay: Duration(milliseconds: delayMs)).fade().slideY(begin: 0.1),
    );
  }
}