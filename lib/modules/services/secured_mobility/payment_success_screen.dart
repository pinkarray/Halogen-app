import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/secured_mobility_provider.dart';
import '../../../shared/widgets/glowing_arrows_button.dart';

class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Show the confirmation modal after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showConfirmationModal(context);
    });
    
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFFFFAEA)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                  size: 100,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Payment Successful!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Objective',
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Your payment has been processed successfully.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Objective',
                  ),
                ),
                const SizedBox(height: 40),
                // Remove the Continue button since we're showing the modal automatically
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showConfirmationModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 60,
            ),
            const SizedBox(height: 16),
            const Text(
              'Thank You!',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            const Text(
              'We have received your payment and our agent will contact you soon. Thanks!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 24),
            GlowingArrowsButton(
              text: 'Back to Services',
              onPressed: () {
                final provider = context.read<SecuredMobilityProvider>();
                provider.markStageComplete(5);
                Navigator.of(context).pushNamedAndRemoveUntil('/services', (_) => false);
              },
            ),
          ],
        ),
      ),
    );
  }
}