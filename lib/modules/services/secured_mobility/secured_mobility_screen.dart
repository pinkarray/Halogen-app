import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../shared/widgets/secured_mobility_progress_bar.dart';
import '../../../shared/widgets/bounce_tap.dart';
import '../../../shared/widgets/halogen_back_button.dart';
import './providers/secured_mobility_provider.dart';

class SecuredMobilityScreen extends StatefulWidget {
  const SecuredMobilityScreen({super.key});

  @override
  State<SecuredMobilityScreen> createState() => _SecuredMobilityScreenState();
}

class _SecuredMobilityScreenState extends State<SecuredMobilityScreen> {
  static const Color brandBlue = Color(0xFF1C2B66);
  static const Color backgroundColor = Color(0xFFFFFFFF);
  int _getVisualStep(BuildContext context) {
    final route = ModalRoute.of(context)?.settings.name ?? '';
    if (route.contains('desired-services')) return 1;
    if (route.contains('service-configuration')) return 2;
    if (route.contains('schedule-service')) return 3;
    if (route.contains('summary')) return 4;
    if (route.contains('payment')) return 5;
    return 0; // fallback
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Consumer<SecuredMobilityProvider>(
            builder: (context, provider, _) {
              final clampedProgress = provider.progressPercent < 0.05 ? 0.0 : provider.progressPercent;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const HalogenBackButton(),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Secured Mobility',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Objective',
                            color: brandBlue,
                          ),
                        ).animate().fade(duration: 600.ms).slideY(begin: 0.3, end: 0),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SecuredMobilityProgressBar(
                    percent: clampedProgress,
                    currentStep: _getVisualStep(context),
                  ),
                  const SizedBox(height: 24),
                  _buildTile(
                    context,
                    icon: Icons.directions_car,
                    label: 'Desired Services',
                    route: '/secured-mobility/desired-services',
                    isComplete: provider.isTripSectionComplete,
                  ),
                  _buildTile(
                    context,
                    icon: Icons.settings,
                    label: 'Service Configuration',
                    route: '/secured-mobility/service-configuration',
                    isComplete: provider.isServiceConfigurationComplete,
                  ),
                  _buildTile(
                    context,
                    icon: Icons.calendar_today,
                    label: 'Schedule Service',
                    route: '/secured-mobility/schedule-service',
                    isComplete: provider.pickupLocation != null &&
                        provider.dropoffLocation != null &&
                        provider.pickupDate != null &&
                        provider.pickupTime != null,
                  ),
                  _buildTile(
                    context,
                    icon: Icons.receipt_long,
                    label: 'Confirm Order / Order Summary',
                    route: '/secured-mobility/summary',
                    isComplete: provider.totalCost > 0, // optionally change to a better flag
                  ),
                  _buildTile(
                    context,
                    icon: Icons.payment,
                    label: 'Payment',
                    route: '/secured-mobility/payment',
                    isComplete: provider.totalCost > 0, // optionally change to a payment flag
                  ),
                  const SizedBox(height: 40),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String route,
    required bool isComplete,
  }) {
    return BounceTap(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.05 * 255).round()),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFF6F6F6),
              ),
              child: Icon(icon, color: brandBlue, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Objective',
                  color: brandBlue,
                ),
              ),
            ),
            isComplete
                ? const Icon(Icons.check_circle, size: 20, color: Colors.green)
                : const Icon(Icons.arrow_forward_ios_rounded, size: 18, color: brandBlue),
          ],
        ),
      ),
    ).animate().fade(duration: 500.ms).slideY(begin: 0.1, end: 0);
  }
}