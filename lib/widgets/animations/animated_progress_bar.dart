import 'package:flutter/material.dart';

/// LinearProgressIndicator dont la valeur s'anime en douceur lors des
/// changements (ex: progression de module qui évolue).
class AnimatedProgressBar extends StatelessWidget {
  final double value;
  final double minHeight;
  final Color? backgroundColor;
  final Color? color;
  final BorderRadius borderRadius;
  final Duration duration;

  const AnimatedProgressBar({
    super.key,
    required this.value,
    this.minHeight = 6,
    this.backgroundColor,
    this.color,
    this.borderRadius = const BorderRadius.all(Radius.circular(100)),
    this.duration = const Duration(milliseconds: 500),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: value.clamp(0.0, 1.0)),
        duration: duration,
        curve: Curves.easeOutCubic,
        builder: (context, animatedValue, _) => LinearProgressIndicator(
          value: animatedValue,
          minHeight: minHeight,
          backgroundColor: backgroundColor,
          valueColor: AlwaysStoppedAnimation(color ?? Theme.of(context).colorScheme.primary),
        ),
      ),
    );
  }
}
