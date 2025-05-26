import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ConciergeServicesScreen extends StatelessWidget {
  const ConciergeServicesScreen({super.key});

  void _launchPhone() async {
    final uri = Uri(scheme: 'tel', path: '+2348000000000');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _launchEmail() async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'support@halogen.com',
      query: 'subject=Concierge Service Inquiry',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFFFFAEA)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: const [
                    BackButton(color: Color(0xFF1C2B66)),
                    SizedBox(width: 8),
                    Text(
                      'Concierge Services',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Objective',
                        color: Color(0xFF1C2B66),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Description scrollable
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      '''
Halogen’s Concierge Services are tailored for individuals and organizations that value time, excellence, and privacy. We manage the details so you don’t have to — from personalized lifestyle services to VIP logistics, high-priority task handling, and executive support.

Our professionals are discreet, efficient, and committed to delivering world-class experiences. Whether you're booking a last-minute flight, organizing executive travel, sourcing rare luxury items, or requiring 24/7 assistance — we deliver with precision and care.

Halogen understands that peace of mind is the real luxury. Our team is trained to anticipate your needs and exceed your expectations, ensuring seamless service delivery while maintaining utmost confidentiality and integrity.

Your convenience and satisfaction are our priorities.
                      ''',
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.6,
                        fontFamily: 'Objective',
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Contact buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _launchPhone,
                      icon: const Icon(Icons.phone, color: Colors.white),
                      label: const Text(
                        'Call Support',
                        style: TextStyle(
                          fontFamily: 'Objective',
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1C2B66),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _launchEmail,
                      icon: const Icon(Icons.email_outlined, color: Colors.white),
                      label: const Text(
                        'Email Us',
                        style: TextStyle(
                          fontFamily: 'Objective',
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1C2B66),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}