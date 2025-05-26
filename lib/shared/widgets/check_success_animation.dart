import 'package:flutter/material.dart';
import 'dart:math' as math;


class CheckSuccessAnimation extends StatefulWidget {
  const CheckSuccessAnimation({super.key});

  @override
  State<CheckSuccessAnimation> createState() => _CheckSuccessAnimationState();
}

class _CheckSuccessAnimationState extends State<CheckSuccessAnimation> with TickerProviderStateMixin {
  bool _isDisposed = false;
  late AnimationController _arcController;
  late AnimationController _fillController;
  late AnimationController _checkController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();

    _arcController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fillController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      lowerBound: 0.0,
      upperBound: 0.05,
    );

    _startAnimationLoop();
  }

  void _startAnimationLoop() async {
    while (mounted && !_isDisposed) {
      await _arcController.forward(from: 0.0);
      await _fillController.forward(from: 0.0);
      await _checkController.forward(from: 0.0);
      await _pulseController.forward(from: 0.0);
      await _pulseController.reverse();

      await Future.delayed(const Duration(milliseconds: 300));

      if (!mounted || _isDisposed) break; // ✅ double safe

      _arcController.reset();
      _fillController.reset();
      _checkController.reset();
      _pulseController.reset();
    }
  }


  @override
  void dispose() {
    _isDisposed = true;
    _arcController.dispose();
    _fillController.dispose();
    _checkController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _arcController,
        _fillController,
        _checkController,
        _pulseController,
      ]),
      builder: (context, child) {
        return Transform.scale(
          scale: 1 + _pulseController.value,
          child: CustomPaint(
            painter: _CheckSuccessPainter(
              arcProgress: _arcController.value,
              fillProgress: _fillController.value,
              checkProgress: _checkController.value,
            ),
            size: const Size(100, 100),
          ),
        );
      },
    );
  }
}

class _CheckSuccessPainter extends CustomPainter {
  final double arcProgress;
  final double fillProgress;
  final double checkProgress;

  _CheckSuccessPainter({
    required this.arcProgress,
    required this.fillProgress,
    required this.checkProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 5;

    // Paint for the arc outline
    final arcPaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw the arc (starting at 3 o'clock, i.e. 0 radians) clockwise
    final startAngle = 0.0;
    final sweepAngle = arcProgress * 2 * math.pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      arcPaint,
    );

    if (fillProgress > 0) {
      // Full green circle
      final greenPaint = Paint()
        ..color = Colors.green
        ..style = PaintingStyle.fill;

      canvas.drawCircle(center, radius, greenPaint);

      // "Cut out" the white center shrinking over time
      final whitePaint = Paint()
        ..color = const Color(0xFFFFFAEA) // your light yellow background
        ..style = PaintingStyle.fill;

      final cutoutRadius = radius * (1 - fillProgress);
      canvas.drawCircle(center, cutoutRadius, whitePaint);
    }

    // Draw the checkmark gradually
    if (checkProgress > 0) {
      final path = Path()
        ..moveTo(size.width * 0.32, size.height * 0.55)
        ..lineTo(size.width * 0.45, size.height * 0.68)
        ..lineTo(size.width * 0.7, size.height * 0.38);

      final metrics = path.computeMetrics().first;
      final extractedPath = metrics.extractPath(0, metrics.length * checkProgress);

      final checkPaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 6
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawPath(extractedPath, checkPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
