import 'package:flutter/material.dart';

import '../utils/colors.dart';

class StepperConnector extends StatelessWidget {
  final bool isPassed;
  final bool shouldRedraw;
  final double delayFactor;
  final Duration animationDuration;
  final Duration animationAwaitDuration;
  final Color? activeColor;
  final Color? disabledColor;
  final Curve curve;
  final double connectorThickness;
  final double value;

  const StepperConnector({
    Key? key,
    required this.isPassed,
    required this.delayFactor,
    required this.shouldRedraw,
    required this.animationDuration,
    required this.curve,
    required this.connectorThickness,
    this.animationAwaitDuration = Duration.zero,
    this.activeColor,
    this.disabledColor,
    required this.value
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Stack(
        children: [
          LinearProgressIndicator(
            backgroundColor: dropDownBackgroundColor,
            valueColor: new AlwaysStoppedAnimation<Color>(blueColor),
            value: value,
          ),
        ],
      ),
    );
  }
}
