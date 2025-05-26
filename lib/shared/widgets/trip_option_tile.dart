import 'package:flutter/material.dart';
import 'bounce_tap.dart';

class TripOptionTile extends StatelessWidget {
  final bool isSelected;
  final String title;
  final String description;
  final VoidCallback onTap;
  final Widget? child;

  const TripOptionTile({
    super.key,
    required this.isSelected,
    required this.title,
    required this.description,
    required this.onTap,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    const brandBlue = Color(0xFF1C2B66);
    const brandYellow = Color(0xFFFFCC29);

    return BounceTap(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: isSelected
              ? const LinearGradient(
                  colors: [brandBlue, brandYellow],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
        ),
        padding: isSelected ? const EdgeInsets.all(2.0) : EdgeInsets.zero,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: !isSelected
                ? Border.all(
                    color: Colors.grey.shade300,
                    width: 2,
                  )
                : null,
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Custom-styled radio icon
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? brandBlue : Colors.grey,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? Center(
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: brandYellow,
                                shape: BoxShape.circle,
                              ),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Objective',
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isSelected ? brandBlue : Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                height: 1,
                color: const Color(0xFFE0E0E0),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
              if (isSelected && child != null) ...[
                const SizedBox(height: 16),
                child!,
              ]
            ],
          ),
        ),
      ),
    );
  }
}