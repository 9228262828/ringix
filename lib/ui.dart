import 'dart:math';

import 'package:flutter/material.dart';

import 'models.dart';

const ringixBg = Color(0xFF10131F);
const ringixPurple = Color(0xFF845EF7);
const ringixCyan = Color(0xFF35D0BA);
const ringixOrange = Color(0xFFFF9F43);
const ringixPink = Color(0xFFF06595);
const ringixWhite = Color(0xFFF8F9FA);
const ringixSurface = Color(0xFF1A2030);
const ringixDanger = Color(0xFFFF5D73);

ThemeData ringixTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: ColorScheme.fromSeed(
      seedColor: ringixPurple,
      brightness: brightness,
      primary: ringixPurple,
      secondary: ringixCyan,
    ),
    scaffoldBackgroundColor:
        dark ? ringixBg : const Color(0xFFF4F5FA),
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: dark ? ringixSurface : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
    ),
  );
}

Color ringColor(int index) {
  switch (index % 4) {
    case 0:
      return ringixPurple;
    case 1:
      return ringixCyan;
    case 2:
      return ringixOrange;
    default:
      return ringixPink;
  }
}

IconData modeIcon(GameMode mode) {
  switch (mode) {
    case GameMode.endless:
      return Icons.all_inclusive_rounded;
    case GameMode.rush60:
      return Icons.timer_rounded;
    case GameMode.oneMistake:
      return Icons.flash_on_rounded;
  }
}

class RingixLogo extends StatelessWidget {
  final double size;

  const RingixLogo({super.key, this.size = 72});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: ringixSurface,
        borderRadius: BorderRadius.circular(size * .28),
        border: Border.all(
          color: ringixPurple.withOpacity(.5),
          width: 2,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size * .56,
            height: size * .56,
            child: CustomPaint(
              painter: MiniRingPainter(),
            ),
          ),
          Container(
            width: size * .12,
            height: size * .12,
            decoration: const BoxDecoration(
              color: ringixWhite,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

class MiniRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * .17
      ..strokeCap = StrokeCap.butt;

    for (var i = 0; i < 4; i++) {
      paint.color = ringColor(i);
      canvas.drawArc(
        rect,
        -pi / 2 + i * pi / 2,
        pi / 2,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant MiniRingPainter oldDelegate) => false;
}

class RingGamePainter extends CustomPainter {
  final int rotationSteps;
  final int targetSegment;
  final double progress;

  RingGamePainter({
    required this.rotationSteps,
    required this.targetSegment,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * .47);
    final radius = min(size.width * .31, size.height * .28);
    final trackRect = Rect.fromCircle(
      center: center,
      radius: radius,
    );

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 32
      ..strokeCap = StrokeCap.butt;

    for (var i = 0; i < 4; i++) {
      final colorIndex = (i - rotationSteps) % 4;
      ringPaint.color = ringColor(colorIndex);
      canvas.drawArc(
        trackRect,
        -pi / 2 + i * pi / 2,
        pi / 2,
        false,
        ringPaint,
      );
    }

    final targetAngle = -pi / 2 + targetSegment * pi / 2 + pi / 4;

    final targetPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 48
      ..strokeCap = StrokeCap.round
      ..color = ringixWhite.withOpacity(.25);

    canvas.drawArc(
      trackRect,
      targetAngle - .11,
      .22,
      false,
      targetPaint,
    );

    final end = Offset(
      center.dx + cos(targetAngle) * radius,
      center.dy + sin(targetAngle) * radius,
    );

    final travelPoint = Offset.lerp(
      center,
      end,
      progress.clamp(0.0, 1.0).toDouble(),
    )!;

    final guidePaint = Paint()
      ..color = ringixWhite.withOpacity(.07)
      ..strokeWidth = 4;

    canvas.drawLine(center, end, guidePaint);

    final dotGlow = Paint()..color = ringixWhite.withOpacity(.18);
    final dotPaint = Paint()..color = ringColor(targetSegment);

    canvas.drawCircle(travelPoint, 24, dotGlow);
    canvas.drawCircle(travelPoint, 11, dotPaint);

    final centerPaint = Paint()..color = ringixSurface;
    canvas.drawCircle(center, radius * .50, centerPaint);

    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'RINGIX',
        style: TextStyle(
          color: ringixWhite,
          fontSize: 24,
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant RingGamePainter oldDelegate) => true;
}

class GameStat extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const GameStat({
    super.key,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: color.withOpacity(.08),
        border: Border.all(color: color.withOpacity(.18)),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: .8,
            ),
          ),
        ],
      ),
    );
  }
}

String hitGradeLabel(HitGrade grade) {
  switch (grade) {
    case HitGrade.match:
      return 'MATCH';
    case HitGrade.perfect:
      return 'PERFECT';
    case HitGrade.miss:
      return 'MISS';
  }
}

Color hitGradeColor(HitGrade grade) {
  switch (grade) {
    case HitGrade.match:
      return ringixOrange;
    case HitGrade.perfect:
      return ringixCyan;
    case HitGrade.miss:
      return ringixDanger;
  }
}
