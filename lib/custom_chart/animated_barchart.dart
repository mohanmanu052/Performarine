import 'package:flutter/material.dart';
import 'package:performarine/custom_chart/bar_chart_painter1.dart';
import 'package:performarine/new_trip_analytics_screen.dart';

class AnimatedBarChart extends StatefulWidget {
  final List<SalesData> data;

  AnimatedBarChart({required this.data});

  @override
  _AnimatedBarChartState createState() => _AnimatedBarChartState();
}

class _AnimatedBarChartState extends State<AnimatedBarChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  Offset? tooltipPosition;
  SalesData? selectedData;
  String? selectedBarType;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap(TapUpDetails details) {
    final position = details.localPosition;
    final barWidth = 32.0;
    final spacing = 4.5;
    final groupSpacing = 30.0;
    final chartHeight = MediaQuery.of(context).size.height - 120;
    for (int i = 0; i < widget.data.length; i++) {
      final x = i * (2 * barWidth + spacing + groupSpacing);
      final double barHeight2 = chartHeight *
          (widget.data[i].speedDuration / widget.data[i].totalDuration);
      final double difference =
          (widget.data[i].totalDuration - widget.data[i].speedDuration).abs();
      final double barHeightDiff =
          chartHeight * (difference / widget.data[i].totalDuration);
      final double adjustedBlueBarHeight = widget.data[i].speedDuration == 0.0
          ? chartHeight + 4
          : chartHeight + 4;
      final blueBarRect = Rect.fromLTWH(
        x,
        chartHeight - adjustedBlueBarHeight,
        barWidth,
        adjustedBlueBarHeight,
      );
      final redBarRect = Rect.fromLTWH(
        x + barWidth + spacing,
        chartHeight - barHeight2,
        barWidth,
        barHeight2,
      );
      final greenBarRect = Rect.fromLTWH(
        x + barWidth + spacing,
        chartHeight - barHeight2 - barHeightDiff - 4,
        barWidth,
        barHeightDiff,
      );
      if (blueBarRect.contains(position)) {
        setState(() {
          tooltipPosition = position;
          selectedData = widget.data[i];
          selectedBarType = 'blue';
        });
        return;
      } else if (redBarRect.contains(position)) {
        if (widget.data[i].speedDuration == 0) {
          setState(() {
            tooltipPosition = null;
            selectedData = null;
            selectedBarType = null;
          });
          return;
        } else {
          setState(() {
            tooltipPosition = position;
            selectedData = widget.data[i];
            selectedBarType = 'red';
          });
          return;
        }
      } else if (greenBarRect.contains(position)) {
        if (widget.data[i].speedDuration == 0) {
          setState(() {
            tooltipPosition = null;
            selectedData = null;
            selectedBarType = null;
          });
          return;
        } else {
          setState(() {
            tooltipPosition = position;
            selectedData = widget.data[i];
            selectedBarType = 'green';
          });
          return;
        }

      }
    }
    setState(() {
      tooltipPosition = null;
      selectedData = null;
      selectedBarType = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return GestureDetector(
          onTapUp: _handleTap,
          child: CustomPaint(
            size: Size(widget.data.length * 100.0,
                300), // Specify the size of the chart
            painter: BarChartPainter1(widget.data, _animation.value,
                tooltipPosition, selectedData, selectedBarType),
          ),
        );
      },
    );
  }
}
