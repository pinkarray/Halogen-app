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
          border: Border.all(color: Colors.black.withValues(alpha: 77), width: 1),
        ),
        padding: const EdgeInsets.all(6),
        child: const Icon(Icons.arrow_back_ios_new, size: 16, color: Colors.black),
      ),
      onPressed: onPressed ?? () => Navigator.of(context).maybePop(),
      tooltip: 'Back',
    );
  }
}
