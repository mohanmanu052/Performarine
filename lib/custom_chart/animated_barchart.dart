import 'package:flutter/material.dart';
import 'package:performarine/custom_chart/bar_chart_painter1.dart';
import 'package:performarine/custom_chart/bar_chart_enums.dart';
import 'package:performarine/new_trip_analytics_screen.dart';

class AnimatedBarChart extends StatefulWidget {
  final List<TripSpeedData> data;

  AnimatedBarChart({required this.data});

  @override
  _AnimatedBarChartState createState() => _AnimatedBarChartState();
}

class _AnimatedBarChartState extends State<AnimatedBarChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  Offset? tooltipPosition;
  TripSpeedData? selectedData;
  BarChartBarType selectedBarType=BarChartBarType.NONE;
Function(String tappedBarType)? onBarTap;
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

  void _handleTap(BarChartBarType tappedBarType,Offset position,TripSpeedData data) {
    setState(() {
          selectedBarType=tappedBarType;
                     tooltipPosition = position;
          selectedData = data;


    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return GestureDetector(
         // onTapUp: _handleTap,
          child: CustomPaint(
            size: Size(widget.data.length * 100.0,
                300), // Specify the size of the chart
            painter: BarChartPainter1(widget.data, _animation.value,
                tooltipPosition, selectedData, selectedBarType,(type,tooltipOffset,selectedData){
                  _handleTap(type,tooltipOffset,selectedData);

                }
                
                
                ),
          ),
        );
      },
    );
  }
}