import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';

class CalculatorField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? suffixText;
  final IconData? prefixIcon;
  final ValueChanged<String>? onChanged;

  const CalculatorField({
    super.key,
    required this.label,
    required this.controller,
    this.suffixText,
    this.prefixIcon,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: colorScheme.outline.withValues(alpha: 0.3)),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          suffixText: suffixText,
          prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
          filled: true,
          fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
          border: border,
          enabledBorder: border,
          focusedBorder: border.copyWith(
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
      ),
    );
  }
}
