import 'package:flutter/material.dart';
import 'glowing_arrows.dart';

class GlowingArrowsButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool enabled;
  final bool showLoader;

  const GlowingArrowsButton({
    super.key,
    required this.text,
    this.onPressed,
    this.enabled = true,
    this.showLoader = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled && !showLoader ? onPressed : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: enabled ? 1.0 : 0.5,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          decoration: BoxDecoration(
            color: Color(0xFF1C2B66),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showLoader)
                const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              else
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Objective',
                  ),
                ),
              const SizedBox(width: 8),
              if (!showLoader)
                const GlowingArrows(
                  arrowColor: Colors.white,
                  arrowSize: 16,
                ),
            ],
          ),
        ),
      ),
    );
  }
}