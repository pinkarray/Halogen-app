import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_animate/flutter_animate.dart';
import './provider/digital_security_provider.dart';
import '../../../shared/helpers/session_manager.dart';
import '../../../shared/widgets/halogen_back_button.dart';
import 'surveillance_bottom_sheet.dart';
import 'anti_surveillance_bottom_sheet.dart';
import 'digital_protection_bottom_sheet.dart';

class DigitalSecurityScreen extends StatelessWidget {
  const DigitalSecurityScreen({super.key});

  void _openBottomSheet(BuildContext context, String key) {
    Widget? sheet;
    switch (key) {
      case 'surveillance':
        sheet = const SurveillanceBottomSheet();
        break;
      case 'anti_surveillance':
        sheet = const AntiSurveillanceBottomSheet();
        break;
      case 'digital_protection':
        sheet = const DigitalProtectionBottomSheet();
        break;
    }

    if (sheet != null) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => sheet!,
      );
    }
  }

  Future<void> _submitRequest(BuildContext context) async {
    final provider = context.read<DigitalSecurityProvider>();
    final token = await SessionManager.getAuthToken();
    final payload = provider.toRequestPayload(pin: '0000');
    final url = Uri.parse('http://185.203.216.113:3004/api/v1/services/requests');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/images/logocut.png', height: 80),
                  const SizedBox(height: 24),
                  const Text(
                    'Submitted!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Objective',
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Your request has been received.\nA specialist will contact you shortly.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Objective',
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // close modal
                      Navigator.pop(context); // return to previous screen
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1C2B66),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                    child: const Text(
                      'Okay',
                      style: TextStyle(
                        fontFamily: 'Objective',
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      } else {
        Fluttertoast.showToast(
          msg: "Submission failed. Try again.",
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } catch (_) {
      Fluttertoast.showToast(
        msg: "Network error. Please check your connection.",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DigitalSecurityProvider>();

    final items = [
      {'label': 'Surveillance', 'key': 'surveillance'},
      {'label': 'Anti-surveillance', 'key': 'anti_surveillance'},
      {'label': 'Digital protection', 'key': 'digital_protection'},
    ];

    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Color(0xFFFFFAEA)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: HalogenBackButton(),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      'Digital Security & Privacy Protection',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Objective',
                        color: Color(0xFF1C2B66),
                      ),
                    ),
                  ).animate().fade(duration: 500.ms).slideY(begin: 0.2),
                ],
              ),

              const SizedBox(height: 20),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1C2B66), Color(0xFF0F1D46)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/sparkle_overlay.jpg'),
                    fit: BoxFit.cover,
                    alignment: Alignment.topRight,
                    opacity: 0.08,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF3A4B93),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset('assets/images/secured.png'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Secure, Reliable, and Always Protected',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Objective',
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'We Keep You Safe, So You Can Focus on What Matters',
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'Objective',
                              color: Colors.white,
                            ),
                            softWrap: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              const Text(
                'Services',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Objective',
                ),
              ),
              const SizedBox(height: 12),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  children: items.map((item) {
                    final key = item['key']!;
                    final label = item['label']!;
                    final completed = provider.isSectionComplete(key);

                    return Column(
                      children: [
                        ListTile(
                          onTap: () => _openBottomSheet(context, key),
                          leading: Checkbox(
                            value: completed,
                            onChanged: (_) => _openBottomSheet(context, key),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            activeColor: Colors.black,
                          ),
                          title: Text(
                            label,
                            style: const TextStyle(
                              fontSize: 14,
                              fontFamily: 'Objective',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          trailing: const Icon(Icons.keyboard_arrow_down_rounded),
                        ),
                        if (key != items.last['key'])
                          const Divider(height: 1, color: Color(0xFFE0E0E0)),
                      ],
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 24),

              if (provider.isAnyServiceSelected)
                Center(
                  child: ElevatedButton(
                    onPressed: () => _submitRequest(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1C2B66),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                    child: const Text(
                      'Submit',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Objective',
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}