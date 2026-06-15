import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

enum AlertType { info, warning, danger, success }

/// Bandeau d'information coloré (info/avertissement/erreur/succès),
/// utilisé pour mettre en avant un message contextuel dans les outils
/// de simulation.
class AlertBanner extends StatelessWidget {
  final AlertType type;
  final String message;

  const AlertBanner({super.key, required this.type, required this.message});

  Color get _color {
    switch (type) {
      case AlertType.info:
        return AppColors.info;
      case AlertType.warning:
        return AppColors.warning;
      case AlertType.danger:
        return AppColors.danger;
      case AlertType.success:
        return AppColors.success;
    }
  }

  IconData get _icon {
    switch (type) {
      case AlertType.info:
        return Icons.info_outline;
      case AlertType.warning:
        return Icons.warning_amber_rounded;
      case AlertType.danger:
        return Icons.error_outline;
      case AlertType.success:
        return Icons.check_circle_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_icon, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
