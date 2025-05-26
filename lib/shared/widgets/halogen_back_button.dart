import 'package:flutter/material.dart';

class HalogenBackButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const HalogenBackButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFF1C2B66).withOpacity(0.3), // ✅ Brand blue with soft opacity
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(6),
        child: const Icon(
          Icons.arrow_back_ios_new,
          size: 16,
          color: Color(0xFF1C2B66), // ✅ Solid brand blue
        ),
      ),
      onPressed: onPressed ?? () => Navigator.of(context).maybePop(),
      tooltip: 'Back',
    );
  }
}
