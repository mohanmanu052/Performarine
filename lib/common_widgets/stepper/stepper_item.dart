import 'package:flutter/material.dart';

class StepperItem extends StatelessWidget {
  final Widget child;
  final bool isPassed;
  final bool shouldRedraw;
  final double delayFactor;
  final Duration animationDuration;
  final Duration animationAwaitDuration;
  final Color? activeColor;
  final Color? disabledColor;
  final Curve curve;
  final bool? isCallingFromAddVessel;

  const StepperItem({
    Key? key,
    required this.isPassed,
    required this.child,
    required this.animationDuration,
    required this.shouldRedraw,
    required this.delayFactor,
    required this.curve,
    this.animationAwaitDuration = Duration.zero,
    this.activeColor,
    this.disabledColor,
    this.isCallingFromAddVessel
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Container(
        color: disabledColor ?? Theme.of(context).colorScheme.secondaryContainer,
        child: Stack(
          children: [
            FutureBuilder(
              future: isCallingFromAddVessel! ? Future.delayed(Duration(seconds: 0),): Future.delayed(
                animationDuration * delayFactor + animationAwaitDuration,),
              builder: (context, snapshot) => AnimatedSwitcher(
                transitionBuilder: (child, animation) => SizeTransition(
                  sizeFactor: animation,
                  child: child,
                  axis: Axis.horizontal,
                ),
                switchInCurve: curve,
                duration: Duration(seconds: 0),
                child: isPassed && snapshot.connectionState == ConnectionState.done || !shouldRedraw
                    ? Container(
                  color: activeColor,
                  alignment: Alignment.centerLeft,
                  child: child,
                  foregroundDecoration: BoxDecoration(
                    color: activeColor,
                  ),
                )
                    : const SizedBox(),
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }
}