import 'package:flutter/material.dart';

/// Anime une valeur numérique vers [value], reformatée à chaque frame via
/// [formatter]. TweenAnimationBuilder interpole automatiquement depuis la
/// valeur affichée courante vers la nouvelle [value] à chaque rebuild.
class AnimatedCount extends StatelessWidget {
  final double value;
  final String Function(double value) formatter;
  final Duration duration;
  final Curve curve;
  final TextStyle? style;
  final TextAlign? textAlign;

  const AnimatedCount({
    super.key,
    required this.value,
    required this.formatter,
    this.duration = const Duration(milliseconds: 600),
    this.curve = Curves.easeOutCubic,
    this.style,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value),
      duration: duration,
      curve: curve,
      builder: (context, animatedValue, _) =>
          Text(formatter(animatedValue), style: style, textAlign: textAlign),
    );
  }
}
