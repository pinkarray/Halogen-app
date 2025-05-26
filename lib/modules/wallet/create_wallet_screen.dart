import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'provider/wallet_provider.dart';
import 'setup_pin_screen.dart';
import '../../shared/helpers/session_manager.dart';

class CreateWalletScreen extends StatefulWidget {
  const CreateWalletScreen({super.key});

  @override
  State<CreateWalletScreen> createState() => _CreateWalletScreenState();
}

class _CreateWalletScreenState extends State<CreateWalletScreen> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;
  final String apiUrl = "http://185.203.216.113:3004/api/v1";

  @override
  void initState() {
    super.initState();
    _prefillPhone();
  }

  Future<void> _prefillPhone() async {
    final user = await SessionManager.getUserModel();
    if (user != null) {
      phoneController.text = user.phoneNumber;
    }
  }

  Future<String?> _getOrCreateDeviceId() async {
    final existing = await SessionManager.getDeviceId();
    if (existing != null) return existing;

    try {
      final res = await http.post(
        Uri.parse('$apiUrl/device'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "device_token": "Testtest",
          "device_type": "android",
          "device_data": {"Platform": "flutter"},
          "app_data": {"Version": "1.0"}
        }),
      );

      if (res.statusCode == 200) {
        final deviceId = jsonDecode(res.body)['data']['device_id'];
        await SessionManager.saveDeviceId(deviceId);
        return deviceId;
      } else {
        debugPrint("❌ Failed to register device: ${res.body}");
        return null;
      }
    } catch (e) {
      debugPrint("❌ Error fetching device ID: $e");
      return null;
    }
  }

  Future<void> _createWallet() async {
    final phone = phoneController.text.trim();
    final password = passwordController.text.trim();

    if (phone.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Phone and password are required")),
      );
      return;
    }

    setState(() => _isLoading = true);

    final deviceId = await _getOrCreateDeviceId();
    if (deviceId == null) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to register device")),
      );
      return;
    }

    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    final success = await walletProvider.createWallet(
      phoneNumber: phone,
      password: password,
      deviceId: deviceId,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SetupPinScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Wallet creation failed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFAEA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Image.asset('assets/images/logo.png', height: 140)
                  .animate()
                  .fade()
                  .slideY(begin: 0.2),
              const SizedBox(height: 20),
              const Text(
                "Create Your Wallet",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Objective',
                  color: Color(0xFF1C2B66),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Enter your phone number and password to get started.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  fontFamily: 'Objective',
                ),
              ),
              const SizedBox(height: 30),

              _inputField("Phone Number", phoneController),
              const SizedBox(height: 16),
              _inputField("Password", passwordController, obscure: true),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _isLoading ? null : _createWallet,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1C2B66),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Create Wallet",
                        style: TextStyle(
                          fontFamily: 'Objective',
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ).animate().fade().scale(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputField(String label, TextEditingController controller, {bool obscure = false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontFamily: 'Objective'),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    ).animate().fade(duration: 500.ms).slideY(begin: 0.2);
  }
}
