import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/auth_service.dart';
import 'package:sms_autofill/sms_autofill.dart';
import '../../../services/secure_storage_service.dart';
import '../../../providers/user_form_data_provider.dart';
import '../account_creation/account_creation_screen.dart';
import '../../../shared/widgets/custom_progress_bar.dart';
import '../../../shared/widgets/halogen_back_button.dart';
import '../../../shared/widgets/glowing_arrows.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../shared/helpers/session_manager.dart';
import 'dart:async';

class OTPVerificationScreen extends StatefulWidget {
  const OTPVerificationScreen({super.key});

  @override
  OTPVerificationScreenState createState() => OTPVerificationScreenState();
}

class OTPVerificationScreenState extends State<OTPVerificationScreen>
    with CodeAutoFill {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  bool _isLoading = false;
  int _resendCooldown = 60;
  bool _isResendAvailable = false;
  late Timer _resendTimer;
  String _otpCode = "";

  @override
  void initState() {
    super.initState();
    listenForCode();
    _startResendCooldown();
    context.read<UserFormDataProvider>().updateSignUpStep(3);
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    if (_resendTimer.isActive) {
      _resendTimer.cancel();
    }
    cancel();
    super.dispose();
  }

  @override
  void codeUpdated() {
    final receivedCode = code ?? '';
    setState(() {
      _otpCode = receivedCode;
    });

    // Autofill the text fields
    for (int i = 0; i < _otpControllers.length && i < receivedCode.length; i++) {
      _otpControllers[i].text = receivedCode[i];
    }
  }

  void _startResendCooldown() {
    setState(() {
      _resendCooldown = 60;
      _isResendAvailable = false;
    });

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCooldown == 0) {
        timer.cancel();
        setState(() {
          _isResendAvailable = true;
        });
      } else {
        if (!mounted) return;
        setState(() {
          _resendCooldown--;
        });
      }
    });
  }

  Future<void> _handleResendOtp() async {
    FocusScope.of(context).unfocus();
    final provider = context.read<UserFormDataProvider>();

    if (provider.phoneNumber?.isEmpty ?? true) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Phone number is missing.")));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await sendOtp(phoneNumber: provider.phoneNumber!);
      if (!mounted) return;

      if (result.containsKey("confirmation_id")) {
        provider.saveConfirmationId(result["confirmation_id"]);
      }

      _startResendCooldown();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("OTP resent successfully.")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to resend OTP: $e")));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: const HalogenBackButton(),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFFAEA), Colors.white],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomProgressBar(
                  currentStep: 1,
                  percent:
                      context
                          .watch<UserFormDataProvider>()
                          .stage1ProgressPercent,
                ).animate().fade(duration: 600.ms),

                const SizedBox(height: 20),

                const Text(
                  "Verify Number",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Objective',
                    color: Color(0xFF1C2B66),
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  "Enter the OTP code sent to your number",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    fontFamily: 'Objective',
                  ),
                ),

                const SizedBox(height: 20),

                PinFieldAutoFill(
                  codeLength: 6,
                  currentCode: _otpCode,
                  onCodeChanged: (code) {
                    if (code != null && code.length <= 6) {
                      setState(() => _otpCode = code);
                    }
                  },
                  onCodeSubmitted: (code) {
                    setState(() => _otpCode = code);
                  },
                  decoration: UnderlineDecoration(
                    textStyle: const TextStyle(
                      fontSize: 20,
                      color: Color(0xFF1C2B66),
                      fontFamily: 'Objective',
                    ),
                    colorBuilder: FixedColorBuilder(Colors.black),
                  ),
                ),

                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Didn't get code? ",
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Objective',
                        color: Colors.grey,
                      ),
                    ),
                    _isResendAvailable
                        ? GestureDetector(
                          onTap: _handleResendOtp,
                          child: const Text(
                            "Resend Code",
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Objective',
                              color: Color(0xFF1C2B66),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                        : Text(
                          "Wait ($_resendCooldown s)",
                          style: const TextStyle(
                            fontSize: 14,
                            fontFamily: 'Objective',
                            color: Colors.grey,
                          ),
                        ),
                  ],
                ).animate().fade(duration: 500.ms),

                const SizedBox(height: 30),

                Center(
                  child: Hero(
                    tag: 'auth-button',
                    child: SizedBox(
                      width: 200,
                      child: ElevatedButton(
                        onPressed:
                            _isLoading
                                ? null
                                : () async {
                                  final otpCode = _otpCode;

                                  if (_otpCode.length != 6) {

                                    if (!mounted) return;
                                    FocusScope.of(context).unfocus();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Please enter the complete OTP',
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  final provider =
                                      context.read<UserFormDataProvider>();

                                  if ((provider.phoneNumber ?? "").isEmpty || _otpCode.length != 6) {
                                    if (!mounted) return;
                                    FocusScope.of(context).unfocus();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Phone number or OTP is missing or incomplete'),
                                      ),
                                    );
                                    return;
                                  }

                                  if (!mounted) return;
                                  setState(() {
                                    _isLoading = true;
                                  });

                                  try {
                                    print("📦 Confirming OTP with:");
                                    print("Phone: ${provider.phoneNumber}");
                                    print("OTP: $_otpCode");

                                    final response = await confirmOtp(
                                      phoneNumber: provider.phoneNumber!,
                                      otp: otpCode,
                                    );

                                    print("✅ OTP confirmed. Response: $response");

                                    if (!mounted) return;

                                    final data = response['data'];
                                      if (data != null && data.containsKey('confirmation_id')) {
                                        provider.markOtpVerified();
                                        provider.saveConfirmationId(data['confirmation_id']);
                                        print("✅ confirmation_id saved: ${data['confirmation_id']}");
                                      } else {
                                        print("❌ confirmation_id missing in response data!");
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Something went wrong. Please try again.')),
                                        );
                                        return;
                                      }

                                    // Convert to user model
                                    final userModel = provider.toUserModel();

                                    // Save credentials for biometric login
                                    final password = provider.password;
                                    final phone = provider.phoneNumber;

                                    if (password != null &&
                                        password.isNotEmpty &&
                                        phone != null &&
                                        phone.isNotEmpty) {
                                      await SecureStorageService().saveUserCredentials(phone, password);
                                    }

                                    await SessionManager.saveUserModel(userModel);
                                    await SessionManager.saveUserProfile(userModel.toJson());

                                    debugPrint('✅ UserModel created: ${userModel.toJson()}');

                                    if (!mounted) return;

                                    Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        transitionDuration: const Duration(milliseconds: 900),
                                        pageBuilder: (_, __, ___) => const AccountCreationScreen(),
                                        transitionsBuilder: (_, animation, __, child) =>
                                            FadeTransition(opacity: animation, child: child),
                                      ),
                                    );
                                  } catch (e) {
                                    if (!mounted) return;
                                    FocusScope.of(context).unfocus();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('OTP Verification failed: $e')),
                                    );
                                  } finally {
                                    if (mounted) {
                                      setState(() => _isLoading = false);
                                    }
                                  }
                                },

                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          backgroundColor: Color(0xFF1C2B66),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child:
                            _isLoading
                                ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                                : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Text(
                                      "Continue",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontFamily: 'Objective',
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    GlowingArrows(arrowColor: Colors.white),
                                  ],
                                ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const Center(
                  child: Text(
                    "By continuing, you agree to our Terms of Service and Privacy Policy",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontFamily: 'Objective',
                    ),
                  ),
                ).animate().fade(duration: 600.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
