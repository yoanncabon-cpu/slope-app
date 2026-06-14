import 'package:flutter/material.dart';

class ResultTile extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  final bool highlight;

  const ResultTile({
    super.key,
    required this.label,
    required this.value,
    this.color,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final accent = color ?? Theme.of(context).colorScheme.primary;
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
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: highlight ? accent : null,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
