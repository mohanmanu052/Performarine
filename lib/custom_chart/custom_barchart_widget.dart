import 'package:flutter/material.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/constants.dart';
import 'package:performarine/custom_chart/animated_barchart.dart';
import 'package:performarine/new_trip_analytics_screen.dart';

class CustomBarChartWidget extends StatelessWidget {
  final List<SalesData> data;

  CustomBarChartWidget({required this.data});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: 10, right: 10),
        width: data.length * 100.0, // Adjust this value to control the width of the chart
        //width:displayWidth(context), // Adjust this value to control the width of the chart
        //height: 300,
        child: AnimatedBarChart(data: data),
      ),
    );
  }
}