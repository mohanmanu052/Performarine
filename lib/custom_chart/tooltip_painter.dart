import 'package:flutter/material.dart';

class TooltipPainter extends CustomPainter {
  final String text;
  final Offset position;

  TooltipPainter(this.text, this.position);

  @override
  void paint(Canvas canvas, Size size) {
    final textStyle = TextStyle(color: Colors.black, fontSize: 12, fontFamily: 'Outfit');
    final textSpan = TextSpan(text: text, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    final double tooltipWidth = textPainter.width + 10;
    final double tooltipHeight = textPainter.height + 10;
    final Rect tooltipRect = Rect.fromLTWH(
      position.dx - tooltipWidth / 2,
      position.dy - tooltipHeight - 10,
      tooltipWidth,
      tooltipHeight,
    );

    final paint = Paint()..color = Colors.white;
    canvas.drawRect(tooltipRect, paint);

    textPainter.paint(
      canvas,
      Offset(
        tooltipRect.left + 5,
        tooltipRect.top + 5,
      ),
    );
  }

  @override
  bool shouldRepaint(TooltipPainter oldDelegate) {
    return oldDelegate.text != text || oldDelegate.position != position;
  }
}



