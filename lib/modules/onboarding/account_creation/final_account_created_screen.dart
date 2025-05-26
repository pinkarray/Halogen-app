import 'package:flutter/material.dart';
import '../../../shared/widgets/check_success_animation.dart';
import '../../../shared/widgets/glowing_arrows.dart';
import '../../../shared/widgets/home_wrapper.dart';

class FinalAccountCreatedScreen extends StatelessWidget {
  const FinalAccountCreatedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFAEA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'HAL',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Objective',
                      color: Colors.black,
                    ),
                  ),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      const Text(
                        'O',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Objective',
                          color: Colors.black,
                        ),
                      ),
                      Transform.translate(
                        offset: const Offset(0, -2.5),
                        child: Image.asset(
                          'assets/images/camera.png',
                          width: 28,
                          height: 24,
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    'GEN',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Objective',
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'SHIELD',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Objective',
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Transform.translate(
                    offset: const Offset(0, -3),
                    child: Image.asset(
                      'assets/images/guide.png',
                      width: 34,
                      height: 34,
                    ),
                  ),
                ],
              ),

              const Spacer(),
              const Center(child: CheckSuccessAnimation()),
              const SizedBox(height: 24),

              const Center(
                child: Text(
                  "Account Created",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Objective',
                    color: Colors.black,
                  ),
                ),
              ),

              const Spacer(),

              // 🚀 Primary Button - Fixed Width
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 280),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const HomeWrapper()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Go to dashboard',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontFamily: 'Objective',
                          ),
                        ),
                        SizedBox(width: 8),
                        GlowingArrows(),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // 🚀 Secondary Button - Fixed Width
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 280),
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/continue-registration');
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.black),
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Continue registration',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontFamily: 'Objective',
                          ),
                        ),
                        SizedBox(width: 8),
                        GlowingArrows(arrowColor: Colors.black),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}