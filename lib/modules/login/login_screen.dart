import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:another_flushbar/flushbar.dart';
import '../../shared/widgets/glowing_arrows_button.dart';
import '../../providers/user_form_data_provider.dart';
import 'login_provider.dart';
import '../../shared/widgets/underlined_glow_input_field.dart';
import '../../shared/widgets/underlined_glow_password_field.dart';
import '../../shared/widgets/home_wrapper.dart';
import '../onboarding/signup/signup_screen.dart';
import 'package:halogen/shared/helpers/session_manager.dart';
import 'package:halogen/utils/string_utils.dart'; 
import '../../models/user_model.dart';
import 'package:local_auth/local_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final LocalAuthentication auth = LocalAuthentication();

  String? savedUsername;
  String? savedPassword;

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(() => setState(() {}));
    _passwordController.addListener(() => setState(() {}));
    _attemptBiometricLogin();
  }

  bool get _isFormComplete =>
      _usernameController.text.trim().isNotEmpty &&
      _passwordController.text.trim().isNotEmpty;

    Future<void> _attemptBiometricLogin() async {
    // 🔐 Load saved credentials
      savedUsername = await SessionManager.getSavedUsername();
      savedPassword = await SessionManager.getSavedPassword();

      if (savedUsername != null && savedPassword != null) {
        try {
          bool canCheck = await auth.canCheckBiometrics;
          bool supported = await auth.isDeviceSupported();
          List<BiometricType> biometrics = await auth.getAvailableBiometrics();

          if (canCheck && supported && biometrics.isNotEmpty) {
            bool authenticated = await auth.authenticate(
              localizedReason: 'Please authenticate to log in',
              options: const AuthenticationOptions(
                biometricOnly: true,
                stickyAuth: true,
              ),
            );

            if (authenticated && mounted) {
              await _loginWithSavedCredentials(); // 👇
            }
          }
        } catch (e) {
          _showFlushbar("Biometric login failed: ${e.toString()}");
        }
      }
    }

    Future<void> _loginWithSavedCredentials() async {
      final loginProvider = Provider.of<LoginProvider>(context, listen: false);

      final result = await loginProvider.login(
        phoneNumber: savedUsername!,
        password: savedPassword!,
        deviceId: "ddcee6bc-1445-4d8c-ba12-2c6ff0ae546d",
      );

      if (result.success && mounted) {
        final cleanedUser = UserModel(
          fullName: capitalizeEachWord(result.user!.fullName.trim()),
          email: result.user!.email.trim().toLowerCase(),
          phoneNumber: result.user!.phoneNumber.trim(),
          type: result.user!.type,
        );

        await SessionManager.saveAuthToken(result.token!);
        await SessionManager.saveDeviceId(result.deviceId!);
        await SessionManager.saveUserModel(cleanedUser);

        await context.read<UserFormDataProvider>().hydrateFromSession();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeWrapper()),
        );
      } else {
        _showFlushbar(loginProvider.errorMessage ?? 'Biometric login failed');
      }
    }

    void _showFlushbar(String message) {
      Flushbar(
        message: message,
        duration: const Duration(seconds: 3),
        flushbarPosition: FlushbarPosition.TOP,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        borderRadius: BorderRadius.circular(12),
        backgroundColor: Colors.red.shade600,
        icon: const Icon(Icons.error_outline, color: Colors.white),
        messageColor: Colors.white,
      ).show(context);
    }

    Future<void> _handleLogin() async {
      final loginProvider = Provider.of<LoginProvider>(context, listen: false);
      final username = _usernameController.text.trim();
      final password = _passwordController.text.trim();

      if (username.isEmpty || password.isEmpty) {
        _showFlushbar('Please fill in both fields');
        return;
      }

      final result = await loginProvider.login(
        phoneNumber: username,
        password: password,
        deviceId: "ddcee6bc-1445-4d8c-ba12-2c6ff0ae546d",
      );

      if (result.success && mounted) {
        final cleanedUser = UserModel(
          fullName: capitalizeEachWord(result.user!.fullName.trim()),
          email: result.user!.email.trim().toLowerCase(),
          phoneNumber: result.user!.phoneNumber.trim(),
          type: result.user!.type,
        );

        await SessionManager.saveAuthToken(result.token!);
        await SessionManager.saveDeviceId(result.deviceId!);
        await SessionManager.saveUserModel(cleanedUser);

        // 🧠 Save credentials for biometric login
        await SessionManager.saveUsername(username);
        await SessionManager.savePassword(password);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeWrapper()),
        );
      } else {
        _showFlushbar(loginProvider.errorMessage ?? 'Login failed');
      }
    }

  @override
  Widget build(BuildContext context) {
    final loginProvider = Provider.of<LoginProvider>(context);
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFCC29),
              Colors.white,
              Colors.white,
              Colors.white,
            ],
            stops: [0.0, 0.4, 0.6, 1.0],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    height: screenWidth * 0.3,
                  ).animate().fade(duration: 800.ms).scaleXY(begin: 0.8, end: 1),

                  const SizedBox(height: 40),

                  UnderlinedGlowInputField(
                    label: 'Username or Phone Number',
                    controller: _usernameController,
                    icon: Icons.person,
                    onChanged: (_) => setState(() {}),
                  ).animate().slideX(begin: -1, end: 0).fade(duration: 600.ms),

                  const SizedBox(height: 20),

                  UnderlinedGlowPasswordField(
                    label: 'Password',
                    controller: _passwordController,
                    icon: Icons.lock,
                    onChanged: (_) => setState(() {}),
                  ).animate().slideX(begin: 1, end: 0).fade(duration: 600.ms),
                  const SizedBox(height: 30),

                  GlowingArrowsButton(
                    text: 'Log In',
                    onPressed: _isFormComplete && !loginProvider.isLoading ? _handleLogin : null,
                    enabled: _isFormComplete && !loginProvider.isLoading,
                    showLoader: loginProvider.isLoading,
                  ).animate().fade(duration: 700.ms).scaleXY(begin: 0.8, end: 1),

                  const SizedBox(height: 15),

                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SignUpScreen()),
                      );
                    },
                    child: const Text(
                      "Don't have an account? Sign Up",
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ).animate().fade(duration: 800.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
