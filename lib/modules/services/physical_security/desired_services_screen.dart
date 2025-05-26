import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../shared/widgets/physical_security_progress_bar.dart';
import '../../../shared/widgets/halogen_back_button.dart';
import '../../../shared/widgets/bounce_tap.dart';
import '../../../shared/widgets/selectable_option_tile.dart';
import '../../../shared/widgets/service_detail_options.dart';
import '../../../shared/widgets/glowing_arrows_button.dart';
import 'package:provider/provider.dart';
import './providers/physical_security_provider.dart';

class DesiredServicesScreen extends StatefulWidget {
  const DesiredServicesScreen({super.key});

  @override
  State<DesiredServicesScreen> createState() => _DesiredServicesScreenState();
}

class _DesiredServicesScreenState extends State<DesiredServicesScreen> {
  void _markServiceComplete(String title) {
    final provider = Provider.of<PhysicalSecurityProvider>(context, listen: false);
    provider.markServiceComplete(title);
  }

  void _showBottomSheet({required String title, required List<String> options}) {
    final provider = Provider.of<PhysicalSecurityProvider>(context, listen: false);
    final structuredItems = getStructuredItems(title);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: 420,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        BounceTap(
                          onTap: () => Navigator.of(context).pop(),
                          child: const CircleAvatar(
                            radius: 16,
                            backgroundColor: Color(0xFFF6F6F6),
                            child: Icon(Icons.close, size: 16, color: Color(0xFF1C2B66)),
                          ),
                        ),
                        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Objective', color: Color(0xFF1C2B66))),
                        const SizedBox(width: 32),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: structuredItems.isNotEmpty
                          ? ServiceDetailOptions(
                              serviceTitle: title,
                              items: structuredItems,
                              initialSelections: provider.structuredSelections[title] ?? {},
                              onOptionSelected: (group, category, value) {
                                provider.updateStructuredSelection(title, group, category, value);
                                setModalState(() {});
                              },
                            )
                          : ListView(
                              children: options.map((option) {
                                return SelectableOptionTile(
                                  label: option,
                                  isSelected: provider.flatSelections[title] == option,
                                  onTap: () {
                                    provider.updateFlatSelection(title, option);
                                    setModalState(() {});
                                  },
                                );
                              }).toList(),
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }).then((_) {
        final structured = provider.structuredSelections[title];
        final flat = provider.flatSelections[title];

        final hasStructuredInput = structured?.values.any((group) =>
            group.values.any((value) => value.toString().isNotEmpty)) ?? false;

        final hasFlatInput = flat?.toString().isNotEmpty ?? false;

        if (hasStructuredInput || hasFlatInput) {
          _markServiceComplete(title);
        } else {
          print("⚠️ No valid input for '$title' — service not marked complete.");
        }
      }
    );
  }

  Widget _buildServiceTile(String title, IconData icon) {
    return Consumer<PhysicalSecurityProvider>(
      builder: (context, provider, _) {
        final isSelected = provider.selectedServices.contains(title);

        final Color activeColor = Color(0xFF1C2B66); // Brand blue

        return BounceTap(
          onTap: () => _showBottomSheet(title: title, options: []),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha((0.05 * 255).toInt()),
                  blurRadius: 6,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      icon,
                      size: 20,
                      color: isSelected ? Colors.green : activeColor,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Objective',
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.green : activeColor,
                      ),
                    ),
                  ],
                ),
                isSelected
                    ? const CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.green,
                        child: Icon(Icons.check, size: 14, color: Colors.white),
                      )
                    : Icon(Icons.arrow_forward_ios_rounded, size: 18, color: activeColor),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PhysicalSecurityProvider>(
      builder: (context, provider, _) {

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
                          child: Text("Physical Security",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Objective', color: Color(0xFF1C2B66)))
                              .animate()
                              .fade(duration: 400.ms)
                              .slideY(begin: 0.3, end: 0),
                        ),
                        
                        const SizedBox(width: 48),
                      ],
                    ),
                    const SizedBox(height: 20),
                    PhysicalSecurityProgressBar(
                      currentStep: 2,
                      percent: provider.progressPercent,
                    ),
                    const SizedBox(height: 24),
                    const Text("Desired Services",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Objective', color: Color(0xFF1C2B66))),
                    const SizedBox(height: 4),
                    const Text("Choose the services you would love to subscribe to",
                        style: TextStyle(fontSize: 13, color: Colors.grey)),
                    const SizedBox(height: 20),
                    Expanded(
                      child: ListView(
                        children: [
                          _buildServiceTile("Perimeter Protection", Icons.security),
                          _buildServiceTile("Patrol", Icons.directions_walk),
                          _buildServiceTile("Visitor Management System", Icons.how_to_reg),
                          _buildServiceTile("Intrusion Detection", Icons.sensors),
                          _buildServiceTile("Alarm", Icons.notifications_active),
                        ],
                      ),
                    ),
                    if (provider.selectedServices.isNotEmpty)
                      Center(
                        child: GlowingArrowsButton(
                          text: 'Confirm Order',
                          onPressed: () {
                            Navigator.pushNamed(context, '/result');
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<Map<String, dynamic>> getStructuredItems(String title) {
    switch (title) {
      case "Perimeter Protection":
        return [
          {
            'title': 'Electric Fence',
            'subOptions': {
              'Monitoring': ['With monitoring', 'Without monitoring'],
              'Response': ['With Response', 'Without Response'],
            },
          },
          {
            'title': 'CCTV',
            'subOptions': {
              'Monitoring': ['With monitoring', 'Without monitoring'],
              'Response': ['With Response', 'Without Response'],
            },
          },
        ];

      case "Patrol":
        return [
          {
            'title': 'Unarmed Patrol',
            'subOptions': {
              'Hour coverage': ['12 hours', '24 hours'],
            },
          },
          {
            'title': 'Armed Patrol',
            'subOptions': {
              'Hour coverage': ['12 hours', '24 hours'],
            },
          },
        ];

      case "Visitor Management System":
        return [
          {
            'title': 'Visitor Management System (VSM)',
            'subOptions': {
              'Select Configuration': [
                'Visitor Management System Only',
                'VMS + Communication Devices (Intercom)',
                'VMS + Communication Devices (CUG)',
              ],
            },
          },
        ];

      case "Intrusion Detection":
        return [
          {
            'title': 'Perimeter Radar System / Monitors',
            'subOptions': {
              'Monitoring': ['With monitoring', 'Without monitoring'],
              'Response': ['With Response', 'Without Response'],
            },
          },
          {
            'title': 'Ground level Doors – All External Doors Monitor',
            'subOptions': {
              'Monitoring': ['With monitoring', 'Without monitoring'],
              'Response': ['With Response', 'Without Response'],
            },
          },
          {
            'title': 'Ground level Windows – All Windows Monitor',
            'subOptions': {
              'Monitoring': ['With monitoring', 'Without monitoring'],
              'Response': ['With Response', 'Without Response'],
            },
          },
          {
            'title': 'Interior Access Way Monitors',
            'subOptions': {
              'Monitoring': ['With monitoring', 'Without monitoring'],
              'Response': ['With Response', 'Without Response'],
            },
          },
        ];

      case "Alarm":
        return [
          {
            'title': 'Interior Fire Alarm',
            'subOptions': {
              'Monitoring': ['With monitoring', 'Without monitoring'],
              'Response': ['With Response', 'Without Response'],
            },
          },
          {
            'title': 'Interior Fire & Smoke Alarm',
            'subOptions': {
              'Monitoring': ['With monitoring', 'Without monitoring'],
              'Response': ['With Response', 'Without Response'],
            },
          },
          {
            'title': 'Interior CO2 / Moisture / Air Quality',
            'subOptions': {
              'Monitoring': ['With monitoring', 'Without monitoring'],
              'Response': ['With Response', 'Without Response'],
            },
          },
        ];

      default:
        return [];
    }
  }
}