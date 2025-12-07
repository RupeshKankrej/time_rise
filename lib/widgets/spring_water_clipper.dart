import 'package:flutter/cupertino.dart';
import 'dart:math' as math;

class SpringWaterClipper extends CustomClipper<Path> {
  final List<Offset> points;
  final double progress;
  SpringWaterClipper({required this.points, required this.progress});

  @override
  Path getClip(Size size) {
    var path = Path();
    double waterHeight = size.height * (1 - progress);

    if (progress == 0) return Path();
    if (progress == 1) {
      path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));
      return path;
    }
    if (points.isEmpty) return Path();

    path.moveTo(points[0].dx, points[0].dy);

    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(SpringWaterClipper oldClipper) => true;
}
