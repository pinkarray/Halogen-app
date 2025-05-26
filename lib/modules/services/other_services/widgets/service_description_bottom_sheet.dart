import 'package:flutter/material.dart';
import '../../../../shared/widgets/bounce_tap.dart';
import '../contact_options_screen.dart';

class ServiceDescriptionBottomSheet extends StatelessWidget {
  final String title;
  final String description;

  const ServiceDescriptionBottomSheet({
    super.key,
    required this.title,
    required this.description,
  });

  void _goToContactOptions(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ContactOptionsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Close Button + Centered Title
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close, size: 20),
              ),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Objective',
                  color: Color(0xFF1C2B66),
                ),
              ),
              const Spacer(flex: 2),
            ],
          ),
          const SizedBox(height: 16),

          // Description Text
          Text(
            description,
            style: const TextStyle(
              fontSize: 13,
              fontFamily: 'Objective',
              color: Colors.black87,
              height: 1.6,
            ),
          ),

          const SizedBox(height: 24),

          // Contact Button
          BounceTap(
            onTap: () => _goToContactOptions(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF0FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Row(
                    children: [
                      Icon(Icons.mail_outline, color: Color(0xFF1C2B66)),
                      SizedBox(width: 10),
                      Text(
                        'Contact us',
                        style: TextStyle(
                          fontFamily: 'Objective',
                          fontSize: 14,
                          color: Color(0xFF1C2B66),
                        ),
                      ),
                    ],
                  ),
                  Icon(Icons.double_arrow_rounded, color: Color(0xFF1C2B66)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
