import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../shared/widgets/glowing_arrows.dart';
import 'signup/signup_screen.dart';
import '../login/login_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFFAEA), // light yellow
              Colors.white,
            ],
          ),
        ),
        child: Stack(
          children: [
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // HALOGEN with camera inside "O"
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'HAL',
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'Objective',
                            color: Colors.black,
                          ),
                        ),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Text(
                              'O',
                              style: TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'Objective',
                                color: Colors.black,
                              ),
                            ),
                            Transform.translate(
                              offset: const Offset(0, -3.5),
                              child: Image.asset(
                                'assets/images/camera.png',
                                width: 42,
                                height: 32,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'GEN',
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'Objective',
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'SHIELD',
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'Objective',
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Transform.translate(
                          offset: const Offset(0, -4),
                          child: Image.asset(
                            'assets/images/guide.png',
                            width: 48,
                            height: 48,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      'Manage your security with ease',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ).animate().fade(duration: 500.ms, delay: 200.ms),

                    const SizedBox(height: 30),

                    Hero(
                      tag: 'auth-button',
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                          backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              transitionDuration: const Duration(milliseconds: 900),
                              pageBuilder: (_, __, ___) => const SignUpScreen(),
                              transitionsBuilder: (_, animation, __, child) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: child,
                                );
                              },
                            ),
                          );
                        },
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Text(
                                'Get Started',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontFamily: 'Objective',
                                ),
                              ),
                              SizedBox(width: 10),
                              GlowingArrows(
                                arrowColor: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ).animate().fade(duration: 600.ms).scaleXY(begin: 0.8, end: 1),
                    ),

                    const SizedBox(height: 15),

                   // ✅ Perfect left alignment with other text
                    Container(
                      alignment: Alignment.centerLeft,
                      width: double.infinity, // Makes sure it starts from the left
                      margin: const EdgeInsets.only(top: 10), // Adjust if needed
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              transitionDuration: const Duration(milliseconds: 900),
                              pageBuilder: (_, __, ___) => const LoginScreen(),
                              transitionsBuilder: (_, animation, __, child) {
                                return FadeTransition(opacity: animation, child: child);
                              },
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero, // Prevents unwanted spacing
                          alignment: Alignment.centerLeft,
                        ),
                        child: Text.rich(
                          TextSpan(
                            text: "Are you an existing user? ",
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontFamily: 'Objective',
                            ),
                            children: const [
                              TextSpan(
                                text: "Log in",
                                style: TextStyle(
                                  color: Color(0xFF1C2B66), // Brand blue
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            IgnorePointer(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Image.asset(
                    'assets/images/cctv.png',
                    width: screenWidth * 0.8,
                  )
                      .animate()
                      .fade(duration: 600.ms)
                      .slideY(begin: 0.3, end: 0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
