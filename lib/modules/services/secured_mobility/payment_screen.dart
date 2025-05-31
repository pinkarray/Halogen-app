import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  void _showBankTransferBottomSheet(BuildContext context, int amount) {
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
            const Text(
              'Transfer to the account below:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Account Name: Halogen Test'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Account Number: 0123456789'),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 16),
                        onPressed: () {
                          Clipboard.setData(const ClipboardData(text: '0123456789'));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Account number copied')),
                          );
                        },
                      ),
                    ],
                  ),
                  const Text('Bank: GTBank'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Amount: ${formatCurrency(amount)}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),
            GlowingArrowsButton(
              text: "I've sent the money",
              onPressed: () {
                final provider = context.read<SecuredMobilityProvider>();
                provider.markStageComplete(5);
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed('/secured-mobility/payment-success');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _processPaystackPayment(int amount, {bool isTransfer = false}) async {
    setState(() {
      isLoading = true;
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
          // Payment failed
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Payment was not completed: $reason')),
          );
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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SecuredMobilityProvider>();
    final totalCost = provider.totalCost;

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
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    HalogenBackButton(),
                    SizedBox(width: 12),
                    Text(
                      'Payment',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Objective',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
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
                      : GlowingArrowsButton(
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
                ),
              ],
            ),
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
