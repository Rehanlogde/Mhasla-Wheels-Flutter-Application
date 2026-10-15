import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Full-width artwork shared by the login and registration screens.
class RentalHeader extends StatelessWidget {
  const RentalHeader({super.key, required this.scale, required this.top});
  final double scale;
  final double top;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 230 * scale + top,
    child: ClipRect(
      child: Stack(
        children: [
          const Positioned.fill(
            child: CustomPaint(painter: RentalRoadPainter()),
          ),
          Positioned(
            left: 24 * scale,
            top: top + 12,
            child: Row(
              children: [
                CustomPaint(
                  size: Size(29 * scale, 22 * scale),
                  painter: RentalLogoPainter(),
                ),
                SizedBox(width: 12 * scale),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MHASLA WHEELS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12 * scale,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.6 * scale,
                      ),
                    ),
                    SizedBox(height: 3 * scale),
                    Text(
                      'YOUR JOURNEY. BEAUTIFULLY SIMPLE.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 5.5 * scale,
                        letterSpacing: .7 * scale,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            left: 24 * scale,
            right: 10 * scale,
            top: top + 112 * scale,
            child: Text(
              'Best Car Rental\nOut there in Kokan',
              style: TextStyle(
                fontFamily: 'BarlowCondensed',
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                fontSize: 40 * scale,
                height: 1.18,
                letterSpacing: 1.1 * scale,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

// The shared road and logo painters are appended from the existing login page.

const _ink = Color(0xFF103B33);
const _cream = Color(0xFFF7F5EC);

class RentalRoadPainter extends CustomPainter {
  const RentalRoadPainter();
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 390, size.height / 230);
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, 390, 230),
      Paint()..color = const Color(0xFFBC0000),
    );
    canvas.drawCircle(
      const Offset(248, 27),
      27,
      Paint()..color = const Color(0xFFFFCE00),
    );
    final land = Path()
      ..moveTo(390, 0)
      ..cubicTo(300, 10, 248, 29, 250, 58)
      ..cubicTo(252, 91, 306, 104, 276, 143)
      ..lineTo(218, 230)
      ..lineTo(390, 230)
      ..close();
    canvas.drawPath(land, Paint()..color = _ink);
    final coast = Path()
      ..moveTo(390, 4)
      ..cubicTo(312, 17, 268, 32, 273, 59)
      ..cubicTo(280, 94, 326, 107, 298, 149)
      ..lineTo(240, 230)
      ..lineTo(390, 230)
      ..close();
    canvas.drawPath(coast, Paint()..color = const Color(0xFF50C1C0));
    final sand = Path()
      ..moveTo(390, 19)
      ..cubicTo(326, 30, 289, 37, 297, 65)
      ..cubicTo(307, 95, 354, 111, 324, 155)
      ..lineTo(270, 230)
      ..lineTo(390, 230)
      ..close();
    canvas.drawPath(
      sand,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF70C5B5), Color(0xFFD7C38A)],
        ).createShader(const Rect.fromLTWH(270, 0, 120, 230)),
    );
    final road = Path()
      ..moveTo(399, 28)
      ..cubicTo(341, 37, 306, 37, 312, 63)
      ..cubicTo(318, 88, 367, 108, 338, 152)
      ..lineTo(286, 230);
    canvas.drawPath(
      road,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 17
        ..color = const Color(0xFF365D4C),
    );
    canvas.drawPath(
      road,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..color = const Color(0xFF6C8063),
    );
    for (final metric in road.computeMetrics()) {
      for (double distance = 0; distance < metric.length; distance += 12) {
        canvas.drawPath(
          metric.extractPath(distance, math.min(distance + 6, metric.length)),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.1
            ..color = _cream,
        );
      }
      final car = metric.getTangentForOffset(metric.length * .61)!;
      canvas.save();
      canvas.translate(car.position.dx, car.position.dy);
      canvas.rotate(car.angle);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(-9, -4, 18, 8),
          const Radius.circular(3),
        ),
        Paint()..color = _cream,
      );
      canvas.drawRect(
        const Rect.fromLTWH(-4, -3, 5, 6),
        Paint()..color = const Color(0xFFB8D3C0),
      );
      canvas.restore();
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant RentalRoadPainter oldDelegate) => false;
}

class RentalLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width * .2, 0)
      ..lineTo(size.width * .54, size.height)
      ..moveTo(size.width * .25, size.height)
      ..lineTo(size.width * .5, 0)
      ..lineTo(size.width * .8, size.height)
      ..moveTo(size.width * .54, size.height)
      ..lineTo(size.width * .78, 0)
      ..lineTo(size.width, size.height);
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFFFDF9C)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.7,
    );
  }

  @override
  bool shouldRepaint(covariant RentalLogoPainter oldDelegate) => false;
}
