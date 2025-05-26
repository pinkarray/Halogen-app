import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'providers/secured_mobility_provider.dart';
import '../../../shared/widgets/halogen_back_button.dart';
import '../../../shared/widgets/secured_mobility_progress_bar.dart';
import '../../../shared/widgets/glowing_arrows_button.dart';

class ConfirmOrderScreen extends StatelessWidget {
  const ConfirmOrderScreen({super.key});

  String formatCurrency(int amount) {
    final formatter = NumberFormat.currency(locale: 'en_NG', symbol: '₦');
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SecuredMobilityProvider>();
    final clampedProgress = provider.progressPercent < 0.05 ? 0.0 : provider.progressPercent;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Color(0xFFFFFAEA)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const HalogenBackButton(),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Confirm Order',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Objective',
                            color: Color(0xFF1C2B66),
                          ),
                        ).animate().fade(duration: 600.ms).slideY(begin: 0.3, end: 0),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SecuredMobilityProgressBar(
                    percent: clampedProgress,
                    currentStep: 4,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Order Summary',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Objective',
                      color: Color(0xFF1C2B66),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _summaryCard('Trip Type', provider.tripType),
                  if ((provider.serviceConfiguration['vehicle_choice']?['enabled'] ?? false))
                    _summaryCard('Vehicle Choice', provider.serviceConfiguration['vehicle_choice']?['selection']),
                  if ((provider.serviceConfiguration['pilot_vehicle']?['enabled'] ?? false))
                    _summaryCard('Pilot Vehicle', provider.serviceConfiguration['pilot_vehicle']?['selection']),
                  if ((provider.serviceConfiguration['in_car_protection']?['enabled'] ?? false))
                    _summaryCard('In Car Protection', provider.serviceConfiguration['in_car_protection']?['selection']),
                  _summaryCard('Pick Up Location', provider.pickupLocation),
                  _summaryCard('Drop Off Location', provider.dropoffLocation),
                  _summaryCard('Pick Up Date', _formatDate(provider.pickupDate)),
                  _summaryCard('Pick Up Time', _formatTime(provider.pickupTime)),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Total: ${formatCurrency(provider.totalCost)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Objective',
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: GlowingArrowsButton(
                      text: 'Confirm Order',
                      onPressed: () {
                        if (provider.totalCost > 0 && provider.currentStage < 5) {
                          provider.markStageComplete(5);
                        }
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ).animate().fade().slideY(begin: 0.1, end: 0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(String title, dynamic value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        '$title: ${value ?? "-"}',
        style: const TextStyle(
          fontSize: 13,
          fontFamily: 'Objective',
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "-";
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return "-";
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}