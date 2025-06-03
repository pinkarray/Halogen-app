import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/auth_service.dart';
import '../../../providers/user_form_data_provider.dart';
import 'package:halogen/shared/helpers/session_manager.dart';
import 'final_account_created_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AccountCreationScreen extends StatefulWidget {
  const AccountCreationScreen({super.key});

  @override
  State<AccountCreationScreen> createState() => _AccountCreationScreenState();
}

class _AccountCreationScreenState extends State<AccountCreationScreen>
    with SingleTickerProviderStateMixin {
  int _countdown = 7;
  late Timer _timer;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _createAccount();
  }

  Future<void> _createAccount() async {
    try {
      final provider = context.read<UserFormDataProvider>();

      if ((provider.confirmationId ?? "").isEmpty || (provider.password ?? "").isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Missing password or confirmation ID')),
        );
        Navigator.pop(context);
        return;
      }

      await createPassword(
        confirmationId: provider.confirmationId!,
        password: provider.password!,
      );

      if (!mounted) return;

      final userModel = provider.toUserModel();
      await SessionManager.saveUserModel(userModel);
      await SessionManager.saveUserProfile(userModel.toJson());

      provider.setOnboardingStage(1);
      await SessionManager.saveStage(1);

      _startCountdown();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Account creation failed: $e')),
      );
      Navigator.pop(context);
    }
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 1) {
        setState(() {
          _countdown--;
        });
      } else {
        _timer.cancel();
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const FinalAccountCreatedScreen()),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    if (_timer.isActive) _timer.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFAEA),
      body: SafeArea(
        child: Center(
          child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Image.asset(
                        'assets/images/logocut.png',
                        height: 80,
                        width: 80,
                      ),
                    ),
                    const SizedBox(
                      width: double.infinity,
                      child: Text(
                        "Hang tight. We're setting things up!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Objective',
                          color: Color(0xFF1C2B66),
                        ),
                      ),
                    ),
                    Text(
                      "Ready in $_countdown seconds",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        fontFamily: 'Objective',
                      ),
                    ),
                    const SizedBox(height: 30),
                    const CircularProgressIndicator(
                      color: Color(0xFFFFCC29),
                    ),
                  ],
                ).animate().fade(duration: 500.ms),
        ),
      ),
    );
  }
}
