import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/underlined_glow_input_field.dart';
import '../../../shared/widgets/underlined_glow_password_field.dart';
import '../../../shared/widgets/custom_progress_bar.dart';
import '../../../providers/user_form_data_provider.dart';
import '../../../shared/widgets/glowing_arrows.dart';
import '../../../shared/widgets/halogen_back_button.dart';
import '../../../shared/widgets/shake_widget.dart';
import '../phone_verification/phone_verification_screen.dart';
import 'signup_provider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  SignUpScreenState createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<ShakeWidgetState> _passwordFieldKey =
      GlobalKey<ShakeWidgetState>();
  final GlobalKey<ShakeWidgetState> _confirmPasswordFieldKey =
      GlobalKey<ShakeWidgetState>();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    final signUpProvider = context.watch<SignUpProvider>();
    final userFormProvider = context.read<UserFormDataProvider>();

    return Scaffold(
      extendBodyBehindAppBar: true,
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
                  percent: signUpProvider.percentOfStage1 / 100,
                ),
                const SizedBox(height: 20),
                const Text(
                  "Let's get you started",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Objective',
                    color: Color(0xFF1C2B66),
                  ),
                ),
                const Text(
                  'Join Halogen and experience integrated security',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF1C2B66),
                    fontFamily: 'Objective',
                  ),
                ),
                const SizedBox(height: 20),

                UnderlinedGlowInputField(
                  label: 'First Name',
                  controller: firstNameController,
                  icon: Icons.person,
                    onChanged: (val) {
                      signUpProvider.updateFirstName(val);
                      userFormProvider.updateFirstName(val);
                    },
                ),
                const SizedBox(height: 12),

                UnderlinedGlowInputField(
                  label: 'Last Name',
                  controller: lastNameController,
                  icon: Icons.person_outline,
                  onChanged: (val) {
                    signUpProvider.updateLastName(val);
                    userFormProvider.updateLastName(val);
                  },
                ),
                const SizedBox(height: 12),

                UnderlinedGlowInputField(
                  label: 'Email Address',
                  controller: emailController,
                  icon: Icons.email_outlined,
                  onChanged: (val) {
                    signUpProvider.updateEmail(val);
                    userFormProvider.updateEmail(val);
                  },
                ),
                const SizedBox(height: 12),

                ShakeWidget(
                  key: _passwordFieldKey,
                  child: UnderlinedGlowPasswordField(
                    label: 'Password',
                    controller: passwordController,
                    icon: Icons.lock,
                    onChanged: (val) {
                      signUpProvider.updatePassword(val);
                      userFormProvider.updatePassword(val);
                    },
                  ),
                ),
                ShakeWidget(
                  key: _confirmPasswordFieldKey,
                  child: UnderlinedGlowPasswordField(
                    label: 'Confirm Password',
                    controller: confirmPasswordController,
                    icon: Icons.lock_outline,
                    onChanged: signUpProvider.updateConfirmPassword,
                  ),
                ),

                const SizedBox(height: 10),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: signUpProvider.isChecked,
                      activeColor: Color(0xFF1C2B66),
                      onChanged: signUpProvider.toggleCheckbox,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text.rich(
                          TextSpan(
                            text: 'By registering, you accept our ',
                            style: const TextStyle(fontFamily: 'Objective'),
                            children: const [
                              TextSpan(
                                text: 'Terms of Use',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(text: ' and '),
                              TextSpan(
                                text: 'Privacy Policy',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                if (signUpProvider.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      signUpProvider.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),

                const SizedBox(height: 20),

                Center(
                  child: Hero(
                    tag: 'auth-button',
                    child: SizedBox(
                      width: 200,
                      child: ElevatedButton(
                        onPressed:
                            signUpProvider.isChecked &&
                                    !signUpProvider.isLoading
                                ? () async {
                                  final success =
                                      await signUpProvider.submitForm();
                                  if (success && mounted) {
                                              userFormProvider.updateFirstName(signUpProvider.firstName);
                                    userFormProvider.updateLastName(signUpProvider.lastName);
                                    userFormProvider.updateEmail(signUpProvider.email);
                                    userFormProvider.updatePassword(signUpProvider.password);
                                    userFormProvider.toggleCheckbox(signUpProvider.isChecked);
                                    Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        transitionDuration: const Duration(
                                          milliseconds: 900,
                                        ),
                                        pageBuilder:
                                            (_, __, ___) =>
                                                const PhoneVerificationScreen(),
                                        transitionsBuilder:
                                            (_, animation, __, child) =>
                                                FadeTransition(
                                                  opacity: animation,
                                                  child: child,
                                                ),
                                      ),
                                    );
                                  } else {
                                    if (signUpProvider.password !=
                                        signUpProvider.confirmPassword) {
                                      _passwordFieldKey.currentState?.shake();
                                      _confirmPasswordFieldKey.currentState
                                          ?.shake();
                                    }
                                  }
                                }
                                : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          backgroundColor:
                              signUpProvider.isChecked
                                  ? Color(0xFF1C2B66)
                                  : Colors.grey[300],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child:
                            signUpProvider.isLoading
                                ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                                : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Text(
                                      'Continue',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontFamily: 'Objective',
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    GlowingArrows(),
                                  ],
                                ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
