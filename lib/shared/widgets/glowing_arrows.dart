// lib/widgets/glowing_arrows.dart
import 'package:flutter/material.dart';

// Enhanced glowing_arrows.dart
class GlowingArrows extends StatefulWidget {
  final int arrowCount;
  final Color arrowColor;
  final Color? glowColor;
  final double arrowSize;
  final Duration loopDelay;

  const GlowingArrows({
    super.key,
    this.arrowCount = 3,
    this.arrowColor = Colors.white,
    this.glowColor,
    this.arrowSize = 18,
    this.loopDelay = const Duration(milliseconds: 300),
  });

  @override
  State<GlowingArrows> createState() => _GlowingArrowsState();
}

class _GlowingArrowsState extends State<GlowingArrows> {
  int _activeIndex = 0;

  @override
  void initState() {
    super.initState();
    _startLooping();
  }

  void _startLooping() {
    Future.doWhile(() async {
      await Future.delayed(widget.loopDelay);
      if (!mounted) return false;
      setState(() {
        _activeIndex = (_activeIndex + 1) % widget.arrowCount;
      });
      return true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final glowColor = widget.glowColor ?? widget.arrowColor;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.arrowCount, (index) {
        final isActive = index == _activeIndex;
        return AnimatedOpacity(
          opacity: isActive ? 1.0 : 0.3,
          duration: const Duration(milliseconds: 250),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1.0),
            child: Text(
              '›',
              style: TextStyle(
                fontSize: widget.arrowSize,
                fontWeight: FontWeight.bold,
                color: widget.arrowColor,
                shadows: isActive
                    ? [
                        Shadow(
                          color: glowColor,
                          blurRadius: 6,
                          offset: const Offset(0, 0),
                        )
                      ]
                    : [],
              ),
            ),
          ),
        );
      }),
    );
  }
}