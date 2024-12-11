import 'package:flutter/material.dart';

class GestureDetectorPainter extends CustomPainter {
  final GestureDetector gestureDetector;

  GestureDetectorPainter(this.gestureDetector);

  @override
  void paint(Canvas canvas, Size size) {
    // No need to paint anything, the gesture detector will handle interactions
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}