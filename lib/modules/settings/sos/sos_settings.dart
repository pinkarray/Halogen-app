import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:halogen/shared/widgets/halogen_back_button.dart';
import 'emergency_contacts_screen.dart'; // Add this import

class SosSettingsScreen extends StatefulWidget {
  const SosSettingsScreen({super.key});

  @override
  State<SosSettingsScreen> createState() => _SosSettingsScreenState();
}

class _SosSettingsScreenState extends State<SosSettingsScreen> {
  bool powerButtonTrigger = true;
  bool shareLocation = true;
  String sosMessage = "I need help. This is an emergency. Please track my location.";

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
          'SOS Settings',
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
          children: [
            _sectionTitle("Trigger Method"),
            _buildToggleTile(
              title: "Triple-press Power Button",
              value: powerButtonTrigger,
              onChanged: (val) => setState(() => powerButtonTrigger = val),
              icon: Icons.power_settings_new,
            ),
            const SizedBox(height: 20),

            _sectionTitle("Location Sharing"),
            _buildToggleTile(
              title: "Include Location in SOS Alert",
              value: shareLocation,
              onChanged: (val) => setState(() => shareLocation = val),
              icon: Icons.location_on_outlined,
            ),
            const SizedBox(height: 20),

            _sectionTitle("Emergency Contacts"),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.contact_phone, color: Color(0xFF1C2B66)),
              title: const Text(
                "Manage Emergency Contacts",
                style: TextStyle(fontFamily: 'Objective', fontSize: 14, color: Color(0xFF1C2B66)),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
              onTap: () => Navigator.pushNamed(context, '/emergency-contacts'),
            ),
            const SizedBox(height: 20),

            _sectionTitle("Custom SOS Message"),
            TextField(
              maxLines: 3,
              controller: TextEditingController(text: sosMessage),
              onChanged: (val) => sosMessage = val,
              decoration: InputDecoration(
                hintText: "Enter your SOS message...",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(fontFamily: 'Objective', fontSize: 14),
            ),
            const SizedBox(height: 30),

            Center(
              child: ElevatedButton.icon(
                onPressed: () => _showTestWarning(context),
                icon: const Icon(Icons.warning_amber_outlined),
                label: const Text("Test SOS Alert"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1C2B66),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(fontFamily: 'Objective', fontSize: 14),
                ),
              ).animate().fade().slideY(begin: 0.2),
            )
          ],
        ).animate().fade(duration: 500.ms).slideY(begin: 0.1),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'Objective',
        fontWeight: FontWeight.bold,
        fontSize: 14,
        color: Color(0xFF1C2B66),
      ),
    ).animate().fade(duration: 300.ms);
  }

  Widget _buildToggleTile({
    required String title,
    required bool value,
    required Function(bool) onChanged,
    required IconData icon,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: const Color(0xFF1C2B66)),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Objective',
                fontSize: 14,
                color: Color(0xFF1C2B66),
              ),
            ),
          ],
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.white,
          activeTrackColor: const Color(0xFF1C2B66), // Brand blue
          inactiveThumbColor: Colors.white,
          inactiveTrackColor: Colors.grey.shade300,
        ),
      ],
    ).animate().fade().slideY(begin: 0.1);
  }

  void _showTestWarning(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text("Test SOS Alert", style: TextStyle(fontFamily: 'Objective')),
        content: const Text(
          "This is only a test. No alert will be sent.",
          style: TextStyle(fontFamily: 'Objective'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(fontFamily: 'Objective')),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Test SOS executed successfully."),
                ),
              );
            },
            child: const Text("Proceed", style: TextStyle(color: Colors.red, fontFamily: 'Objective')),
          )
        ],
      ),
    );
  }
}