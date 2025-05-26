import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'wallet_dashboard_screen.dart';
import 'package:local_auth/local_auth.dart';

class SetupPinScreen extends StatefulWidget {
  const SetupPinScreen({super.key});

  @override
  State<SetupPinScreen> createState() => _SetupPinScreenState();
}

class _SetupPinScreenState extends State<SetupPinScreen> {
  final pinController = TextEditingController();
  final confirmPinController = TextEditingController();
  bool _biometricEnabled = false;
  bool _isSaving = false;

  final LocalAuthentication auth = LocalAuthentication();

  Future<void> _savePinAndContinue() async {
    final pin = pinController.text.trim();
    final confirmPin = confirmPinController.text.trim();

    if (pin.length < 4 || pin != confirmPin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("PINs do not match or are too short")),
      );
      return;
    }

    setState(() => _isSaving = true);

    // Store PIN securely in real app — this is simulated:
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("wallet_pin", pin);
    await prefs.setBool("biometric_enabled", _biometricEnabled);

    setState(() => _isSaving = false);

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const WalletDashboardScreen()),
        (route) => false,
      );
    }
  }

  Future<void> _checkBiometricAvailability() async {
    final available = await auth.canCheckBiometrics;
    final supported = await auth.isDeviceSupported();
    if (!available || !supported) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Biometric not available on this device")),
      );
      setState(() => _biometricEnabled = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFAEA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              const Icon(Icons.lock_outline, size: 80, color: Color(0xFF1C2B66))
                  .animate()
                  .fade()
                  .slideY(begin: 0.3),
              const SizedBox(height: 20),
              const Text(
                "Set Your Wallet PIN",
                style: TextStyle(
                  fontFamily: 'Objective',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1C2B66),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Add a secure PIN to protect your wallet access.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Objective',
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 30),

              _buildPinField("Enter PIN", pinController),
              const SizedBox(height: 16),
              _buildPinField("Confirm PIN", confirmPinController),
              const SizedBox(height: 24),

              _buildBiometricToggle(),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: _isSaving ? null : _savePinAndContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1C2B66),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Continue",
                        style: TextStyle(
                          fontFamily: 'Objective',
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ).animate().fade().scale(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPinField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      obscureText: true,
      keyboardType: TextInputType.number,
      maxLength: 6,
      decoration: InputDecoration(
        labelText: label,
        counterText: '',
        labelStyle: const TextStyle(fontFamily: 'Objective'),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    ).animate().fade().slideY(begin: 0.2);
  }

  Widget _buildBiometricToggle() {
    return SwitchListTile(
      value: _biometricEnabled,
      onChanged: (val) async {
        if (val) {
          final available = await auth.canCheckBiometrics;
          final supported = await auth.isDeviceSupported();
          if (!available || !supported) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Biometric not supported on this device."),
              ),
            );
            return;
          }
        }
        setState(() => _biometricEnabled = val);
      },
      title: const Text(
        "Enable Biometric Unlock",
        style: TextStyle(
          fontFamily: 'Objective',
          fontSize: 16,
          color: Color(0xFF1C2B66),
        ),
      ),
      subtitle: const Text(
        "Use fingerprint or face ID to unlock wallet",
        style: TextStyle(
          fontFamily: 'Objective',
          fontSize: 13,
          color: Colors.black54,
        ),
      ),
      activeColor: const Color(0xFF1C2B66),
    ).animate().fade().slideX(begin: -0.3);
  }
}
