import 'package:flutter/material.dart';

import 'animations/animated_count.dart';

class ResultTile extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  final bool highlight;

  /// Si fournie avec [formatter], [value] est ignorée pour l'affichage et
  /// remplacée par un compteur animé qui transitionne vers cette valeur.
  final double? numericValue;

  /// Formatte [numericValue] à chaque frame de l'animation. Requis si
  /// [numericValue] est fourni.
  final String Function(double value)? formatter;

  const ResultTile({
    super.key,
    required this.label,
    required this.value,
    this.color,
    this.highlight = false,
    this.numericValue,
    this.formatter,
  }) : assert(
          numericValue == null || formatter != null,
          'formatter est requis quand numericValue est fourni',
        );

  @override
  Widget build(BuildContext context) {
    final accent = color ?? Theme.of(context).colorScheme.primary;
    final valueStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
          color: highlight ? accent : null,
          fontWeight: FontWeight.w700,
        );

    final valueWidget = (numericValue != null && formatter != null)
        ? AnimatedCount(
            value: numericValue!,
            formatter: formatter!,
            style: valueStyle,
          )
        : Text(value, style: valueStyle);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: highlight
            ? accent.withValues(alpha: 0.10)
            : Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyMedium)),
          const SizedBox(width: 12),
          valueWidget,
        ],
      ),
    );
  }
}
