import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as fm;
import 'package:performarine/new_trip_analytics_screen.dart';

class BarChartPainter extends CustomPainter {
  final List<SalesData> data;
  final double barWidth;
  final double barSpacing;
  final Function(int, bool) onBarTap;
  final BuildContext context;

  BarChartPainter({
    required this.data,
    this.barWidth = 25.0,
    this.barSpacing = 18.0,
    required this.onBarTap,
    required this.context,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()..color = Colors.blue;
    final paint2 = Paint()..color = Colors.red;

    // Compute max sales for scaling purposes
    final maxSales = data.map((d) => d.speedDuration > d.totalDuration ? d.speedDuration : d.totalDuration).reduce((a, b) => a > b ? a : b);

    // Calculate bar positions and draw bars
    for (int i = 0; i < data.length; i++) {
      final sales1Height = (data[i].totalDuration / maxSales) * size.height;
      final sales2Height = (data[i].speedDuration / maxSales) * size.height;

      final barX = i * (2 * barWidth + barSpacing);

      final rect1 = Rect.fromLTWH(barX, size.height - sales1Height, barWidth, sales1Height);
      final rect2 = Rect.fromLTWH(barX + barWidth, size.height - sales2Height, barWidth, sales2Height);

      canvas.drawRect(rect1, paint1);
      canvas.drawRect(rect2, paint2);
    }

    // Draw X-axis labels
    final textStyle = TextStyle(color: Colors.black, fontSize: 10);
    final textPainter = TextPainter(textAlign: TextAlign.center, textDirection: TextDirection.ltr);

    for (int i = 0; i < data.length; i++) {
      final barX = i * (2 * barWidth + barSpacing) + barWidth + barSpacing;

     var parse = fm.DateFormat('yyyy-MM-dd').format(data[i].year);
     debugPrint("SHOW DATE $parse");
      textPainter.text = TextSpan(text: parse.toString(), style: textStyle);
      textPainter.layout();
      textPainter.paint(canvas, Offset(barX - textPainter.width / 2, size.height + 4));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  @override
  bool hitTest(Offset position) {
    for (int i = 0; i < data.length; i++) {
      final barX = i * (2 * barWidth + barSpacing);
      final sales1Height = (data[i].totalDuration / 60) * 220; // Adjusted for example
      final sales2Height = (data[i].speedDuration / 60) * 220; // Adjusted for example

      final rect1 = Rect.fromLTWH(barX, 220 - sales1Height, barWidth, sales1Height);
      final rect2 = Rect.fromLTWH(barX + barWidth, 220 - sales2Height, barWidth, sales2Height);

      if (rect1.contains(position)) {
        onBarTap(i, true);
        _showTooltip(data[i].totalDuration.toString(), rect1.center);
        return true;
      } else if (rect2.contains(position)) {
        onBarTap(i, false);
        _showTooltip(data[i].speedDuration.toString(), rect2.center);
        return true;
      }
    }
    return false;
  }

  void _showTooltip(String text, Offset position) {
    final RenderBox overlay = Overlay.of(context)!.context.findRenderObject() as RenderBox;
    final Offset overlayTopLeft = overlay.localToGlobal(Offset.zero);

    final OverlayEntry entry = OverlayEntry(
      builder: (context) => Positioned(
        left: position.dx - overlayTopLeft.dx - 25,
        top: position.dy - overlayTopLeft.dy - 50,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              text,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(entry);
    Future.delayed(Duration(seconds: 2)).then((_) {
      entry.remove();
    });
  }
}
