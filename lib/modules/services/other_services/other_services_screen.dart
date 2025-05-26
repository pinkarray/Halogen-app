import 'package:flutter/material.dart';
import '../../../shared/widgets/bounce_tap.dart';
import '../../../shared/widgets/halogen_back_button.dart';
import 'widgets/service_description_bottom_sheet.dart';

class ServiceItem {
  final String title;
  final String description;
  final IconData icon;

  ServiceItem({
    required this.title,
    required this.description,
    required this.icon,
  });
}

class OtherServicesScreen extends StatefulWidget {
  const OtherServicesScreen({super.key});

  @override
  State<OtherServicesScreen> createState() => _OtherServicesScreenState();
}

class _OtherServicesScreenState extends State<OtherServicesScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  final List<ServiceItem> services = [
    ServiceItem(
      title: 'Concierge Services',
      description:
          'A Concierge Service provides tailored support and convenience, handling everything from day-to-day errands to exclusive requests. Whether it’s booking flights, securing reservations, arranging transport, or managing special events, concierge professionals act as your personal assistant, ensuring a smooth, stress-free experience.',
      icon: Icons.room_service,
    ),
    ServiceItem(
      title: 'Reports & Alerts',
      description:
          'Stay informed with real-time alerts and detailed reports about your environment, threats, and security updates. Our system ensures you’re always aware of important developments.',
      icon: Icons.campaign,
    ),
    ServiceItem(
      title: 'Intelligence Analysis & Reporting',
      description:
          'We provide professional intelligence reporting that helps organizations make better decisions about risk and safety with data-driven insights and strategic assessments.',
      icon: Icons.insights,
    ),
    ServiceItem(
      title: 'Crowd Management',
      description:
          'Ensure public events and gatherings are safe and well-coordinated with our expert crowd control teams and logistics planning.',
      icon: Icons.groups,
    ),
    ServiceItem(
      title: 'Health & Safety Service',
      description:
          'From workplace inspections to emergency response plans, we help ensure regulatory compliance and employee safety.',
      icon: Icons.health_and_safety,
    ),
    ServiceItem(
      title: 'LEA & GSF Liaison Service',
      description:
          'We coordinate with Law Enforcement Agencies and Government Security Forces to provide extended protection and intelligence sharing.',
      icon: Icons.local_police,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showServiceDetails(String title, String description) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ServiceDescriptionBottomSheet(
        title: title,
        description: description,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Color(0xFFFFFAEA)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: const [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: HalogenBackButton(),
                    ),
                    Text(
                      'Also by Halogen',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Objective',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.15, // Slightly shorter
                  physics: const NeverScrollableScrollPhysics(),
                  children: services.map((service) {
                    return BounceTap(
                      onTap: () => _showServiceDetails(
                        service.title,
                        service.description,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFFF4F4F4),
                              ),
                              child: Icon(
                                service.icon,
                                size: 20,
                                color: Color(0xFF1C2B66), // brand blue
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              service.title,
                              style: const TextStyle(
                                fontFamily: 'Objective',
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.left,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
