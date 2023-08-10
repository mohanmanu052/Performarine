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
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Container(
        color: disabledColor ?? Theme.of(context).colorScheme.secondaryVariant,
        child: Stack(
          children: [
            FutureBuilder(
              future: Future.delayed(
                animationDuration * delayFactor + animationAwaitDuration,
              ),
              builder: (context, snapshot) => AnimatedSwitcher(
                transitionBuilder: (child, animation) => SizeTransition(
                  sizeFactor: animation,
                  child: child,
                  axis: Axis.horizontal,
                ),
                switchInCurve: curve,
                duration: animationDuration,
                child: isPassed && snapshot.connectionState == ConnectionState.done || !shouldRedraw
                    ? Container(
                  color: activeColor ?? Theme.of(context).primaryColor,
                  alignment: Alignment.centerLeft,
                  child: child,
                  foregroundDecoration: BoxDecoration(
                    color: activeColor ?? Theme.of(context).primaryColor,
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
