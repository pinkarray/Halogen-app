import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/glowing_arrows_button.dart';
import '../../../shared/widgets/halogen_back_button.dart';
import '../../../shared/widgets/physical_security_progress_bar.dart';
import '../../../shared/widgets/home_wrapper.dart';
import './providers/physical_security_provider.dart';
import '../../../shared/helpers/session_manager.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class PhysicalSecurityResultScreen extends StatelessWidget {
  const PhysicalSecurityResultScreen({super.key});

  Future<void> _sendRequest(BuildContext context) async {
    final provider = Provider.of<PhysicalSecurityProvider>(context, listen: false);
    final token = await SessionManager.getAuthToken();

    final questions = [
      {
        'question': 'Preferred Date',
        'answer': provider.preferredDate?.toIso8601String() ?? ''
      },
      {
        'question': 'Preferred Time',
        'answer': provider.preferredTime?.format(context) ?? ''
      },
      {'question': 'House Number', 'answer': provider.houseNumber},
      {'question': 'Street Name', 'answer': provider.streetName},
      {'question': 'Area', 'answer': provider.area},
      {'question': 'State', 'answer': provider.state},
      {
        'question': 'Selected Services',
        'answer': provider.selectedServices.map((service) {
          final structured = provider.structuredSelections[service];
          if (structured != null) {
            return {
              'service': service,
              'configurations': structured,
            };
          } else {
            final flat = provider.flatSelections[service];
            return {
              'service': service,
              'selection': flat,
            };
          }
        }).toList(),
      },
    ];

    final payload = {
      'pin': '0000',
      'ref_code': 'SS-PS',
      'info': {'questions': questions},
    };

    final response = await http.post(
      Uri.parse('http://185.203.216.113:3004/api/v1/services/requests'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      provider.markRequestSent();
      showModalBottomSheet(
        context: context,
        isDismissible: false,
        enableDrag: false,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/images/logocut.png', height: 70),
                  const SizedBox(height: 20),
                  const Text(
                    "Details Submitted!",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Objective'),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Customer service will reach out within 24 hours.",
                    style: TextStyle(fontSize: 13, color: Colors.black54, fontFamily: 'Objective'),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  GlowingArrowsButton(
                    text: 'Okay',
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const HomeWrapper(initialIndex: 1)),
                        (route) => false,
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send request. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PhysicalSecurityProvider>(context);
    final dateFormat = DateFormat('yyyy-MM-dd');

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFFFFAEA)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const HalogenBackButton(),
                    Expanded(
                      child: Text(
                        "Physical Security",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Objective',
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 20),
                PhysicalSecurityProgressBar(
                  currentStep: 3,
                  percent: provider.progressPercent,
                ),
                const SizedBox(height: 24),
                const Text(
                  "Summary",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    fontFamily: 'Objective',
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Review your selections before submitting.",
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView(
                    children: [
                      _buildCard([
                        _rowText("Preferred Date", provider.preferredDate != null ? dateFormat.format(provider.preferredDate!) : ''),
                        _rowText("Preferred Time", provider.preferredTime?.format(context) ?? ''),
                      ]),
                      const SizedBox(height: 16),
                      _buildCard([
                        _rowText("House Number", provider.houseNumber),
                        _rowText("Street Name", provider.streetName),
                        _rowText("Area", provider.area),
                        _rowText("State", provider.state),
                        _rowText("Confirmed Address", provider.confirmedMapAddress),
                      ]),
                      const SizedBox(height: 16),
                      _buildCard([
                        const Padding(
                          padding: EdgeInsets.only(bottom: 6),
                          child: Text(
                            "Selected Services",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Objective',
                            ),
                          ),
                        ),
                        ...provider.selectedServices.map((service) {
                          final structured = provider.structuredSelections[service];
                          final flat = provider.flatSelections[service];

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  service,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    fontFamily: 'Objective',
                                    color: Color(0xFF1C2B66),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                if (structured != null)
                                  ...structured.entries.map((group) => Padding(
                                        padding: const EdgeInsets.only(left: 12.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: group.value.entries
                                              .map((entry) => _rowText(entry.key, entry.value))
                                              .toList(),
                                        ),
                                      )),
                                if (flat != null)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 12.0),
                                    child: _rowText("Selection", flat),
                                  ),
                              ],
                            ),
                          );
                        }),
                      ]),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: GlowingArrowsButton(
                    text: 'Send Request',
                    onPressed: () => _sendRequest(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _rowText(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontFamily: 'Objective',
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                fontFamily: 'Objective',
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }
}