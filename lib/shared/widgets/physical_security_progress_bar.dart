import 'package:flutter/material.dart';

class PhysicalSecurityProgressBar extends StatelessWidget {
  final int currentStep; // 1-based: 1, 2, 3
  final double percent; // from 0.0 to 1.0

  const PhysicalSecurityProgressBar({
    super.key,
    required this.currentStep,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    const brandBlue = Color(0xFF1C2B66);
    const brandYellow = Color(0xFFFFCC29);
    const gradient = LinearGradient(
      colors: [brandBlue, brandYellow],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );

    final stepTitles = ["Site Inspection", "Desired Services", "Review & Submit"];
    final percentComplete = (percent * 100).clamp(0, 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final totalWidth = constraints.maxWidth;
            final pillWidth = totalWidth * percent;

            return Stack(
              children: [
                // Background track
                Container(
                  height: 22,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),

                // Animated gradient progress
                Positioned(
                  left: 1,
                  top: 1,
                  bottom: 1,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    width: pillWidth - 2 < 0 ? 0 : pillWidth - 2,
                    decoration: BoxDecoration(
                      gradient: gradient,
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                ),

                // Completion percentage
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => gradient.createShader(bounds),
                          child: Text(
                            "$percentComplete% completed",
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Objective',
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 12),

        // Step labels
        LayoutBuilder(
          builder: (context, constraints) {
            final isSmallScreen = constraints.maxWidth < 360;

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(stepTitles.length, (index) {
                final isActive = index == currentStep - 1;
                final titleParts = stepTitles[index].split(' ');

                final activeColor = brandBlue;
                final inactiveColor = brandBlue.withOpacity(0.4);

                return Expanded(
                  child: Center(
                    child: isSmallScreen && titleParts.length > 1
                        ? Column(
                            children: titleParts.map((part) {
                              return Text(
                                part,
                                style: TextStyle(
                                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                                  color: isActive ? activeColor : inactiveColor,
                                  fontFamily: 'Objective',
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              );
                            }).toList(),
                          )
                        : Text(
                            stepTitles[index],
                            style: TextStyle(
                              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                              color: isActive ? activeColor : inactiveColor,
                              fontFamily: 'Objective',
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                  ),
                );
              }),
            );
          },
        ),
      ],
    );
  }
}