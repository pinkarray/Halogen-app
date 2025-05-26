import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../shared/widgets/halogen_back_button.dart';

class ContactOptionsScreen extends StatelessWidget {
  const ContactOptionsScreen({super.key});

  void _launchCall() async {
    final Uri telUri = Uri(scheme: 'tel', path: '09056546768');
    if (await canLaunchUrl(telUri)) {
      await launchUrl(telUri);
    } else {
      debugPrint('❌ Could not launch phone dialer');
    }
  }

  void _launchEmail() async {
    final Uri emailUri = Uri.parse(
      'mailto:support@halogen.com?subject=Customer Support Request',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('❌ Could not launch email');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFAEA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const HalogenBackButton(), // or IconButton
                  const Spacer(),
                  const Text(
                    "Contact us",
                    style: TextStyle(
                      fontFamily: 'Objective',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  const Spacer(flex: 2), // balances back button spacing
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Select your preferred mode of contacting our customer service agents',
                style: TextStyle(
                  fontSize: 13,
                  fontFamily: 'Objective',
                  color: Colors.black87,
                ),
              ),
            ),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildOptionTile("Call agent", _launchCall),
                  const SizedBox(height: 12),
                  _buildOptionTile("Send a mail", _launchEmail),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          // subtle border instead of shadow
          border: Border.all(color: Colors.black12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Objective',
                fontSize: 14,
                color: Color(0xFF1C2B66),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
