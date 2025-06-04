import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:pay_with_paystack/pay_with_paystack.dart';
import 'package:uuid/uuid.dart';
import 'providers/secured_mobility_provider.dart';
import '../../../shared/widgets/halogen_back_button.dart';
import '../../../shared/widgets/glowing_arrows_button.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String? selectedMethod;
  bool isLoading = false;
  bool paymentCancelled = false;

  void _processPaystackPayment(int amount, {bool isTransfer = false}) async {
    setState(() {
      isLoading = true;
      paymentCancelled = false;
    });

    try {
      // Generate a unique reference for this transaction
      final uuid = Uuid();
      final reference = uuid.v4();
      
      const secretKey = 'sk_test_9fb37d4abb5aa1d55a16d6f604f6e69298e1709e'; // Get this from your Paystack dashboard
      
      await PayWithPayStack().now(
        context: context,
        secretKey: secretKey, // Use secret key here, not public key
        customerEmail: 'customer@example.com', // Replace with actual user email
        reference: reference,
        currency: 'NGN',
        amount: amount.toDouble(),
        callbackUrl: 'https://halogen.com/callback',
        // If it's a bank transfer, specify the payment channel
        paymentChannel: isTransfer ? ["bank_transfer"] : null,
        transactionCompleted: (paymentData) {
          // Payment was successful
          final provider = context.read<SecuredMobilityProvider>();
          provider.markStageComplete(5);
          Navigator.of(context).pushNamed('/secured-mobility/payment-success');
        },
        transactionNotCompleted: (String reason) {
          // Payment failed or was cancelled
          setState(() {
            paymentCancelled = true;
          });
          
          if (reason.toLowerCase().contains('cancel') || reason.toLowerCase().contains('aborted')) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Payment cancelled')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Payment was not completed: $reason')),
            );
          }
        },
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error processing payment: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  String formatCurrency(int amount) {
    final formatter = NumberFormat.currency(locale: 'en_NG', symbol: '₦');
    return formatter.format(amount);
  }

  void _returnToServicePage() {
    Navigator.of(context).popUntil(
      (route) => route.settings.name == '/secured-mobility' || route.isFirst
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SecuredMobilityProvider>();
    final totalCost = provider.totalCost;
    final screenSize = MediaQuery.of(context).size;

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
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    HalogenBackButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Payment',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Objective',
                      ),
                    ),
                    const Spacer(),
                    if (paymentCancelled)
                      TextButton(
                        onPressed: _returnToServicePage,
                        child: const Text('Return to Services'),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: screenSize.height - 150, // Adjust for app bar height
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1C2B66),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text(
                                'Available Balance',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontFamily: 'Objective',
                                ),
                              ),
                              Text(
                                'NGN500,000',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Objective',
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          'Payment Method',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            fontFamily: 'Objective',
                          ),
                        ),
                        const SizedBox(height: 12),
                        _paymentOption('Wallet'),
                        _paymentOption('Bank Transfer'),
                        _paymentOption('Card Payment'),
                        const SizedBox(height: 32),
                        Center(
                          child: isLoading
                              ? const CircularProgressIndicator()
                              : Column(
                                  children: [
                                    GlowingArrowsButton(
                                      text: 'Pay ${formatCurrency(totalCost)}',
                                      onPressed: () {
                                        if (selectedMethod == 'Bank Transfer') {
                                          _processPaystackPayment(totalCost, isTransfer: true);
                                        } else if (selectedMethod == 'Wallet') {
                                          provider.markStageComplete(5);
                                          Navigator.of(context).pushNamed('/secured-mobility/payment-success');
                                        } else if (selectedMethod == 'Card Payment') {
                                          _processPaystackPayment(totalCost);
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Please select a payment method')),
                                          );
                                        }
                                      },
                                    ),
                                    if (paymentCancelled) ...[
                                      const SizedBox(height: 16),
                                      TextButton(
                                        onPressed: _returnToServicePage,
                                        child: const Text('Cancel and Return to Services'),
                                      ),
                                    ],
                                  ],
                                ),
                        ),
                        const SizedBox(height: 20),
                      ],
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

  Widget _paymentOption(String title) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedMethod = title;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 14, fontFamily: 'Objective'),
              ),
            ),
            Icon(
              selectedMethod == title
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              color: Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}
