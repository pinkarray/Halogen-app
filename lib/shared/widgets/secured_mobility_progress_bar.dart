import 'package:flutter/material.dart';

class SecuredMobilityProgressBar extends StatelessWidget {
  final double percent; 
  final int currentStep;

  const SecuredMobilityProgressBar({
    super.key,
    required this.percent,
    required this.currentStep,
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

    const labels = [
      "Stage 1",
      "Stage 2",
      "Stage 3",
      "Stage 4",
      "Stage 5",
    ];

    final percentComplete = (percent * 100).clamp(0, 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress pill
        LayoutBuilder(
          builder: (context, constraints) {
            final totalWidth = constraints.maxWidth;
            final pillWidth = totalWidth * percent;

            return Stack(
              children: [
                Container(
                  height: 22,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
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
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => gradient.createShader(bounds),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Text(
                              "$percentComplete% completed",
                              key: ValueKey(percentComplete),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Objective',
                                color: Colors.white,
                              ),
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

        // Step Labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(labels.length, (index) {
            final labelIndex = index + 1;
            final isActive = currentStep == labelIndex;

            return Expanded(
              child: Center(
                child: Text(
                  labels[index],
                  style: TextStyle(
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    color: isActive ? brandBlue : brandBlue.withOpacity(0.4),
                    fontFamily: 'Objective',
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}