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
  final bool? isCallingFromAddVessel;

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
    required this.value,
    this.isCallingFromAddVessel
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return isCallingFromAddVessel! ?
    Expanded(
      child: LinearProgressIndicator(
        backgroundColor: dropDownBackgroundColor,
        valueColor: new AlwaysStoppedAnimation<Color>(blueColor),
        value: value,
      ),
    )
        : Expanded(
      child: Stack(
        children: [
          Divider(
            thickness: connectorThickness,
            color: disabledColor ?? Theme.of(context).colorScheme.secondaryContainer,
          ),
          FutureBuilder(
            future: Future.delayed(
              animationDuration * delayFactor + animationAwaitDuration,
            ),
            builder: (context, snapshot) => AnimatedSwitcher(
              switchInCurve: curve,
              transitionBuilder: (child, animation) => SizeTransition(
                sizeFactor: animation,
                child: child,
                axis: Axis.horizontal,
              ),
              duration: animationDuration,
              child: isPassed && snapshot.connectionState == ConnectionState.done || !shouldRedraw
                  ? Divider(
                thickness: connectorThickness,
                color: activeColor ?? Theme.of(context).primaryColor,
              )
                  : const SizedBox(),
            ),
          ),
        ],
      ),
    );
  }
}