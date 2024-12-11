import 'package:flutter/material.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/custom_chart/bar_chart_painter.dart';
import 'package:performarine/new_trip_analytics_screen.dart';

class BarChart extends StatefulWidget {
  final List<SalesData> data;

  BarChart({required this.data});

  @override
  _BarChartState createState() => _BarChartState();
}

class _BarChartState extends State<BarChart> {
  int? selectedIndex;
  bool isSales1 = true;

  void _handleTap(int index, bool isSales1) {
    setState(() {
      selectedIndex = index;
      this.isSales1 = isSales1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) {
        RenderBox box = context.findRenderObject() as RenderBox;
        Offset localOffset = box.globalToLocal(details.globalPosition);

        // Perform hit testing in BarChartPainter
        CustomPaint customPaint = context.findRenderObject() as CustomPaint;
        BarChartPainter painter = customPaint.painter as BarChartPainter;

        painter.hitTest(localOffset);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 50),
        child: CustomPaint(
          size: Size(displayWidth(context), 220), // Adjust size as needed
          painter: BarChartPainter(
            data: widget.data,
            onBarTap: _handleTap,
            context: context,
          ),
        ),
      ),
    );
  }
}
