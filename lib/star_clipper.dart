import 'dart:math' as math;
import 'package:flutter/material.dart';

class StarPainter extends CustomPainter {
  StarPainter(this.numberOfPoints, this.needPaint, this.internalRaduis, {this.color});
  final Color? color;
  final int numberOfPoints;
  final bool needPaint;
  final double internalRaduis;

  @override
  void paint(Canvas canvas, Size size) {
    double sh = size.height;
    double sw = size.width;

    final paint = Paint()
      ..color = color ?? Colors.cyan
      ..strokeWidth = 5
      ..style = needPaint ? PaintingStyle.fill :PaintingStyle.stroke;

    double width = size.width;

    double halfWidth = width / 2;

    double bigRadius = halfWidth;

    double radius = internalRaduis;

    double degreesPerStep = _degToRad(360 / numberOfPoints) as double;

    double halfDegreesPerStep = degreesPerStep / 2;

    var path = Path();

    double max = 2 * math.pi;

    path.moveTo(width, halfWidth);

    for (double step = 0; step < max; step += degreesPerStep) {
      path.lineTo(halfWidth + bigRadius * math.cos(step),
          halfWidth + bigRadius * math.sin(step));
      path.lineTo(halfWidth + radius * math.cos(step + halfDegreesPerStep),
          halfWidth + radius * math.sin(step + halfDegreesPerStep));
    }

    path.close();

    // Path path = Path()
    //   ..moveTo(sw / 2, 0)
    //   ..quadraticBezierTo(sw / 2, sh / 2, sw, sh / 2)
    //   ..quadraticBezierTo(sw / 2, sh / 2, sw / 2, sh)
    //   ..quadraticBezierTo(sw / 2, sh / 2, 0, sh / 2)
    //   ..quadraticBezierTo(sw / 2, sh / 2, sw / 2, 0);

    canvas.drawPath(path, paint);
  }

  num _degToRad(num deg) => deg * (math.pi / 180.0);
  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
