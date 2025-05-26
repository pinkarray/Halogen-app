import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './providers/outsourcing_talent_provider.dart';
import '../../../shared/widgets/halogen_back_button.dart';
import '../../../shared/widgets/glowing_arrows_button.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../shared/helpers/session_manager.dart';
import 'package:fluttertoast/fluttertoast.dart';


class ConfirmationScreen extends StatelessWidget {
  const ConfirmationScreen({super.key});

  void _handleSubmit(BuildContext context) async {
    final provider = context.read<OutsourcingTalentProvider>();
    final payload = provider.toRequestPayload(pin: '0000');
    final token = await SessionManager.getAuthToken(); // 🔐 Your stored auth token

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
        provider.markStage3Completed();

        // Success Modal
        await Future.delayed(const Duration(milliseconds: 300));
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Dialog(
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
                    'A customer advocate will contact you soon.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Objective',
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 24),
                  GlowingArrowsButton(
                    text: 'Okay',
                    onPressed: () {
                      Navigator.popUntil(context, ModalRoute.withName('/outsourcing-talent'));
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      } else {
        Fluttertoast.showToast(
          msg: "Submission failed. Please try again.",
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "An error occurred. Please check your connection.",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  Widget _buildSection(String title, List<String> items, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Objective',
            ),
          ),
          const SizedBox(height: 12),
          ...items.map((item) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item,
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'Objective',
                    ),
                  ),
                  const Divider(height: 20, color: Color(0xFFE0E0E0)),
                ],
              )),
        ],
      ),
    )
        .animate()
        .fade(duration: 400.ms)
        .slideY(begin: 0.05 * index); // stagger animation
  }

  List<String> _extractDomesticStaff(Map<String, dynamic> data) {
    final List<String> items = [];

    if (data['drivers'] != null) {
      items.add('Driver');
      items.add('${data['drivers']['type']} (${data['drivers']['quantity']})');
    }
    if (data['security_operatives'] != null) {
      items.add('Security Operatives');
      if (data['security_operatives']['armed'] != null) {
        items.add('Armed Security – ${data['security_operatives']['armed']}');
      }
      if (data['security_operatives']['unarmed'] != null) {
        data['security_operatives']['unarmed'].forEach((k, v) {
          items.add('$k ($v)');
        });
      }
    }
    if (data['cooks'] != null) {
      items.add('Cook');
      items.add('${data['cooks']['type']} (${data['cooks']['quantity']})');
    }
    if (data['housekeepers'] != null) {
      items.add('Housekeeper');
      items.add('${data['housekeepers']['type']} (${data['housekeepers']['quantity']})');
    }

    return items;
  }

  List<String> _extractBusinessStaff(Map<String, dynamic> data) {
    final List<String> items = [];

    for (var role in [
      'front_desk_officer',
      'direct_sales_agent',
      'office_administrator',
      'janitor'
    ]) {
      if (data[role] != null) {
        items.add(role.replaceAll('_', ' ').toTitleCase());
        data[role].forEach((k, v) {
          if (k != 'completed') items.add('$k ($v)');
        });
      }
    }

    return items;
  }

  List<String> _extractSimple(Map<String, dynamic> data) {
    final List<String> items = [];
    data.forEach((k, v) {
      if (k != 'completed') items.add('$k ($v)');
    });
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OutsourcingTalentProvider>();
    final data = provider.allSectionDetails;

    final bool hasAnyData = data.isNotEmpty;

    final sectionWidgets = <Widget>[];
    int animationIndex = 0;

    if (data['domestic_staff'] != null) {
      sectionWidgets.add(_buildSection('Domestic Staff', _extractDomesticStaff(data['domestic_staff']!), animationIndex++));
    }
    if (data['business_staff'] != null) {
      sectionWidgets.add(_buildSection('Business Staff', _extractBusinessStaff(data['business_staff']!), animationIndex++));
    }
    if (data['background_checks'] != null) {
      sectionWidgets.add(_buildSection('Background Checks', _extractSimple(data['background_checks']!), animationIndex++));
    }
    if (data['investigation'] != null) {
      sectionWidgets.add(_buildSection('Investigation', _extractSimple(data['investigation']!), animationIndex++));
    }
    if (data['lea_liaison'] != null) {
      sectionWidgets.add(_buildSection('LEA Liaison', _extractSimple(data['lea_liaison']!), animationIndex++));
    }
    if (data['description'] != null && data['description']!['text'].toString().isNotEmpty) {
      sectionWidgets.add(_buildSection('Description', [data['description']!['text']], animationIndex++));
    }

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Color(0xFFFFFAEA)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Animated Header
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: HalogenBackButton(),
                      ),
                      const Text(
                        'Confirmation',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Objective',
                          color: Color(0xFF1C2B66),
                        ),
                      ).animate().fade(duration: 400.ms).slideY(begin: 0.2),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Data Sections
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: sectionWidgets,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Submit Button
                Center(
                  child: GlowingArrowsButton(
                    text: 'Submit',
                    onPressed: hasAnyData ? () => _handleSubmit(context) : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

extension on String {
  String toTitleCase() {
    return split('_').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ');
  }
}