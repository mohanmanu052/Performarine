import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as fm;
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/constants.dart';
import 'package:performarine/custom_chart/bar_chart_enums.dart';
import 'package:performarine/new_trip_analytics_screen.dart';

class BarChartPainter1 extends CustomPainter {
  final List<TripSpeedData> data;
  final double animationValue;
  final Offset? tooltipPosition;
  final TripSpeedData? selectedData;
  final BarChartBarType? selectedBarType;
  Size? cachedSize;
  Canvas? displayCanvas;
  Function(BarChartBarType tappdeBarType,Offset position, TripSpeedData selectedBarData)? OnBarTap;
  Paint? displayPaint;
Function(Offset offestValues,String tooltipText)? toolTipCallBack;
  BarChartPainter1(this.data, this.animationValue, this.tooltipPosition,
      this.selectedData, this.selectedBarType,this.OnBarTap);

  @override
  void paint(Canvas canvas, Size size) {
    cachedSize=size;
    displayCanvas=canvas;
    
    final paint = Paint()..style = PaintingStyle.fill;

    Paint barPaint = Paint()..style = PaintingStyle.fill;

    final double barWidth = 32;
    final double spacing = 4.5;
    final double groupSpacing = 30;
    //final double chartHeight = size.height - 20; // leave some padding at the top and bottom
    final double chartHeight =
        size.height - 60; // leave some padding at the top and bottom
    //final double fixedBlueBarHeight = chartHeight * 0.7; // Set a fixed height for blue bars
    final double fixedBlueBarHeight =
        chartHeight * 0.85; // Set a fixed height for blue bars
    double gapBetweenBars = 4;

    // Draw x-axis
    final axisPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1;
    final double xAxisY = size.height -
        40; // Adjust this value to control the position of the x-axis
    canvas.drawLine(Offset(0, xAxisY), Offset(size.width+300, xAxisY), axisPaint);

    for (int i = 0; i < data.length; i++) {
      final x = i * (2 * barWidth + spacing + groupSpacing);

      // Calculate heights for red and green bars
      final double barHeight2 = fixedBlueBarHeight *
          double.parse((data[i].speedDuration / data[i].totalDuration)
              .toStringAsFixed(3));
      double difference =
      (double.parse(data[i].totalDuration.toStringAsFixed(2)) -
          double.parse(data[i].speedDuration.toStringAsFixed(2)));

      final double barHeightDiff = fixedBlueBarHeight *
          (difference / double.parse(data[i].totalDuration.toStringAsFixed(2)));

      // Adjust blue bar height if value2 is 0.0
      final double adjustedBlueBarHeight = data[i].speedDuration == 0.0
          ? fixedBlueBarHeight + gapBetweenBars
          : fixedBlueBarHeight + gapBetweenBars;
      // Draw first bar (blue) with adjusted height
      paint.color = blueColor;
      canvas.drawRect(
        Rect.fromLTWH(
            x,
            size.height - adjustedBlueBarHeight * animationValue - 40,
            barWidth,
            adjustedBlueBarHeight * animationValue),
        paint,
      );

      // Draw the red bar
      paint.color = Color(0xFF67C6C7);
      canvas.drawRect(
        Rect.fromLTWH(
            x + barWidth + spacing,
            size.height -
                barHeight2 * animationValue -
                40 -
                (difference == 0.0 ? 4 : 0),
            barWidth,
            ((barHeight2 * animationValue) + (difference == 0.0 ? 4 : 0))),
        paint,
      );

      print(
          'DIFF: $difference - ${(data[i].totalDuration - data[i].speedDuration)} - ${data[i].speedDuration.toStringAsFixed(2)}');

      if (data[i].speedDuration != 0.0) {
        // Draw the green bar only if value2 is not 0.0
        // if(difference <= 0.01){
        //   gapBetweenBars = 0;
        // }
        final double yPositionDiff = size.height -
            barHeight2 * animationValue -
            barHeightDiff * animationValue -
            gapBetweenBars -
            40;

        paint.color = Colors.yellow;
        if (!difference.isNegative) {
          canvas.drawRect(
            Rect.fromLTWH(x + barWidth + spacing, yPositionDiff, barWidth,
                barHeightDiff * animationValue),
            paint,
          );
        }


        // Draw labels on top of the green difference bar
      //   final valueTextDiff = TextSpan(
      //     text: difference == 0 || difference < 0
      //         ? ''
      //         : difference.toStringAsFixed(2),
      //     style:
      //     TextStyle(color: Colors.black, fontSize: 10, fontFamily: outfit),
      //   );
      //   final textPainterDiff = TextPainter(
      //     text: valueTextDiff,
      //     textDirection: TextDirection.ltr,
      //   );
      //   if (difference >= 0.01) {
      //     textPainterDiff.layout();
      //     textPainterDiff.paint(
      //       canvas,
      //       Offset(
      //           x +
      //               barWidth +
      //               spacing +
      //               barWidth / 2 -
      //               textPainterDiff.width / 2,
      //           yPositionDiff +2),
      //     );
      //   }
       }

      // Draw labels on top of the blue bar
      // final valueText1 = TextSpan(
      //   text: data[i].totalDuration == 0 || data[i].totalDuration < 0
      //       ? ''
      //       : data[i].totalDuration.toStringAsFixed(2),
      //   style: TextStyle(color: Colors.white, fontSize: 10, fontFamily: outfit),
      // );
      // final textPainter1 = TextPainter(
      //   text: valueText1,
      //   textDirection: TextDirection.ltr,
      // );
      // textPainter1.layout();
      // textPainter1.paint(
      //   canvas,
      //   Offset(x + barWidth / 2 - textPainter1.width / 2,
      //       size.height - adjustedBlueBarHeight * animationValue - 35),
      // );

      // // Draw labels inside the red bar at the top
      // final valueText2 = TextSpan(
      //   text: data[i].speedDuration == 0 || data[i].speedDuration < 0
      //       ? ''
      //       : data[i].speedDuration.toStringAsFixed(2),
      //   style: TextStyle(color: Colors.black, fontSize: 10, fontFamily: outfit),
      // );
      // final textPainter2 = TextPainter(
      //   text: valueText2,
      //   textDirection: TextDirection.ltr,
      // );
      // textPainter2.layout();
      // textPainter2.paint(
      //   canvas,
      //   Offset(
      //       x + barWidth + spacing + barWidth / 2 - textPainter2.width / 2,
      //       size.height -
      //           barHeight2 * animationValue -
      //           40 +
      //           5 -
      //           (difference.toStringAsFixed(2) == '0.00' ? 4 : 0)),
      // );

      // Draw date label at the bottom center of the group of bars
      var parse = fm.DateFormat('yyyy-MM-dd').format(data[i].year);
      final dateText = TextSpan(
        text: parse.toString(),
        style: TextStyle(color: Colors.black, fontSize: 11, fontFamily: outfit),
      );
      final textPainter = TextPainter(
        text: dateText,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x + (barWidth + spacing + barWidth) / 2 - textPainter.width / 2,
            size.height - 35),
      );
    }
    if (tooltipPosition != null && selectedData != null) {
      
      String tooltipText = '';
      if (selectedBarType == BarChartBarType.TOTAL_DURATION) {
        tooltipText =
        'Total: ${selectedData!.totalDuration.toStringAsFixed(2)} ${selectedData?.timeType??""}';
      } else if (selectedBarType == BarChartBarType.BELOW_5KT) {
        tooltipText =
        '> 5KT: ${selectedData!.speedDuration.toStringAsFixed(2)} ${selectedData?.timeType??""}';
      } else if (selectedBarType == BarChartBarType.FUELSAVED) {
        final double difference =
        (selectedData!.totalDuration - selectedData!.speedDuration).abs();
        tooltipText = '< 5KT: ${difference.toStringAsFixed(2)} ${selectedData?.timeType??""}';
      }
      final textPainter = TextPainter(
        text: TextSpan(
          text: tooltipText,
          style: TextStyle(color: Colors.white, fontSize: 12),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      paint.color = Colors.black.withOpacity(0.7);
      final tooltipRect = Rect.fromLTWH(
        tooltipPosition!.dx - textPainter.width / 2 +17,
        tooltipPosition!.dy - textPainter.height - 8,
        textPainter.width + 16,
        textPainter.height + 8,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(tooltipRect, Radius.circular(4)),
        paint,
      );
      textPainter.paint(
        canvas,
        Offset(
          tooltipPosition!.dx+27 - textPainter.width / 2,
          tooltipPosition!.dy - textPainter.height - 4,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

//Todo Uncomment for showing the tool tip

//   @override
//   bool? hitTest(Offset position) {
//     if(cachedSize==null){
//       return true;
//     }else{
//       var size=cachedSize;
//           final paint = Paint()..style = PaintingStyle.fill;


//     final double barWidth = 32;
//     final double spacing = 4.5;
//     final double groupSpacing = 30;
//     //final double chartHeight = size.height - 20; // leave some padding at the top and bottom
//     final double chartHeight =
//         size!.height - 60; // leave some padding at the top and bottom
//     //final double fixedBlueBarHeight = chartHeight * 0.7; // Set a fixed height for blue bars
//     final double fixedBlueBarHeight =
//         chartHeight * 0.85; // Set a fixed height for blue bars
//     double gapBetweenBars = 4;

//     // Draw x-axis
//     //canvas.drawLine(Offset(0, xAxisY), Offset(size.width, xAxisY), axisPaint);
// Rect? totalDurationRect;
// Rect? fuelSavedRect;
// Rect? below5KtRect;
//     for (int i = 0; i < data.length; i++) {
//       final x = i * (2 * barWidth + spacing + groupSpacing);

//       // Calculate heights for red and green bars
//       final double barHeight2 = fixedBlueBarHeight *
//           double.parse((data[i].speedDuration / data[i].totalDuration)
//               .toStringAsFixed(3));
//       double difference =
//       (double.parse(data[i].totalDuration.toStringAsFixed(2)) -
//           double.parse(data[i].speedDuration.toStringAsFixed(2)));

//       final double barHeightDiff = fixedBlueBarHeight *
//           (difference / double.parse(data[i].totalDuration.toStringAsFixed(2)));

//       // Adjust blue bar height if value2 is 0.0
//       final double adjustedBlueBarHeight = data[i].speedDuration == 0.0
//           ? fixedBlueBarHeight + gapBetweenBars
//           : fixedBlueBarHeight + gapBetweenBars;
//       // Draw first bar (blue) with adjusted height
//       paint.color = blueColor;
//      totalDurationRect=    Rect.fromLTWH(
//             x,
//             size.height - adjustedBlueBarHeight * animationValue - 40,
//             barWidth,
//             adjustedBlueBarHeight * animationValue);
//       // Draw the red bar
//       paint.color = Color(0xFF67C6C7);
//      // canvas.drawRect(
//       below5KtRect=   Rect.fromLTWH(
//             x + barWidth + spacing,
//             size.height -
//                 barHeight2 * animationValue -
//                 40 -
//                 (difference == 0.0 ? 4 : 0),
//             barWidth,
//             ((barHeight2 * animationValue) + (difference == 0.0 ? 4 : 0)));
//        // paint,
//      // );


//      if (data[i].speedDuration != 0.0) {
//         final double yPositionDiff = size.height -
//             barHeight2 * animationValue -
//             barHeightDiff * animationValue -
//             gapBetweenBars -
//             40;

//         paint.color = Colors.yellow;
//         if (!difference.isNegative) {
//          // canvas.drawRect(
//          fuelSavedRect=   Rect.fromLTWH(x + barWidth + spacing, yPositionDiff, barWidth,
//                 barHeightDiff * animationValue);
//            // paint,
//            //);
//        }
        
//         }


//             if(totalDurationRect.contains(position)){
//        var positiontemp=       Offset(position.dx,position.dy);
//               OnBarTap!(BarChartBarType.TOTAL_DURATION,positiontemp,data[i]);
//     return super.hitTest(position);

//       }else if(below5KtRect.contains(position)){
//               OnBarTap!(BarChartBarType.BELOW_5KT,position,data[i]);

//     return super.hitTest(position);

//       }
      
//       else if(fuelSavedRect!=null&&fuelSavedRect.contains(position)){

//               OnBarTap!(BarChartBarType.FUELSAVED,position,data[i]);


//     return super.hitTest(position);

//       }

//     }

//     return super.hitTest(position);
//   }
//     }
    
    }