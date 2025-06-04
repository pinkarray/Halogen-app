import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:halogen/shared/widgets/bounce_tap.dart';
import 'package:halogen/shared/widgets/underlined_glow_input_field.dart';

class MonitoringServicesScreen extends StatelessWidget {
  const MonitoringServicesScreen({super.key});

  void _showPurchaseForm(BuildContext context, String deviceName) {
    final nameController = TextEditingController();
    final addressController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 24,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Purchase $deviceName",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Objective',
                        color: Color(0xFF1C2B66),
                      ),
                    ),
                    const SizedBox(height: 20),
                    UnderlinedGlowInputField(
                      label: "Full Name",
                      icon: Icons.person,
                      controller: nameController,
                    ),
                    const SizedBox(height: 15),
                    UnderlinedGlowInputField(
                      label: "Delivery Address",
                      icon: Icons.home,
                      controller: addressController,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFCC29),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Proceed",
                        style: TextStyle(
                          fontFamily: 'Objective',
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDeviceTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
  }) {
    return BounceTap(
      onTap: () => _showPurchaseForm(context, title),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.05),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Animate(
              effects: [
                ScaleEffect(
                  begin: const Offset(1, 1),
                  end: const Offset(1.15, 1.15),
                  duration: 900.ms,
                ),
                FadeEffect(duration: 700.ms),
              ],
              onPlay: (controller) => controller.repeat(reverse: true),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3C1),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFCC29).withValues(alpha: 0.5),
                      blurRadius: 20,
                      spreadRadius: 1,
                    )
                  ],
                ),
                child: Icon(icon, color: const Color(0xFFFFCC29), size: 30),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Objective',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF1C2B66),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontFamily: 'Objective',
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    ).animate().fade(duration: 500.ms).slideY(begin: 0.1).scale();
  }

  @override
  Widget build(BuildContext context) {
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
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 600),
            builder: (context, value, child) => Opacity(
              opacity: value,
              child: child,
            ),
            child: const Text(
              "Monitoring Services",
              style: TextStyle(
                fontFamily: 'Objective',
                fontWeight: FontWeight.bold,
                color: Color(0xFF1C2B66),
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 60, top: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.monitor_heart, size: 60, color: Color(0xFFFFCC29))
                  .animate()
                  .fade(duration: 500.ms)
                  .scale(duration: 400.ms),
              const SizedBox(height: 20),
              const Text(
                "Connect your devices to a live monitoring center for 24/7 updates and security alerts.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Objective',
                  fontSize: 15,
                  color: Color(0xFF1C2B66),
                ),
              ),
              const SizedBox(height: 30),
              _buildDeviceTile(
                context: context,
                icon: Icons.videocam,
                title: "CCTV Camera",
                description: "Real-time surveillance and recording.",
              ),
              _buildDeviceTile(
                context: context,
                icon: Icons.sensors,
                title: "Motion Sensor",
                description: "Instant alerts on unauthorized movement.",
              ),
              _buildDeviceTile(
                context: context,
                icon: Icons.electric_bolt,
                title: "Electric Fence",
                description: "High-voltage perimeter security.",
              ),
              _buildDeviceTile(
                context: context,
                icon: Icons.gps_fixed,
                title: "Vehicle Tracker",
                description: "Track your vehicle location in real time.",
              ),
              const SizedBox(height: 20),
              const Text(
                "More devices coming soon...",
                style: TextStyle(
                  fontFamily: 'Objective',
                  color: Colors.black38,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
