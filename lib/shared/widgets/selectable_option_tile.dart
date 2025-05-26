import 'package:flutter/material.dart';
import 'bounce_tap.dart';

class SelectableOptionTile extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const SelectableOptionTile({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BounceTap(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFFFCC29) : Colors.grey.shade300,
            width: 2,
          ),
          color: isSelected ? const Color(0xFFFFF4CC) : Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontFamily: 'Objective',
                fontWeight: FontWeight.w500,
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Color(0xFFFFCC29), size: 20),
          ],
        ),
      ),
    );
  }
}
