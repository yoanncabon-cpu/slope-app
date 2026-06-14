import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CalculatorField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? suffixText;
  final ValueChanged<String>? onChanged;

  const CalculatorField({
    super.key,
    required this.label,
    required this.controller,
    this.suffixText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
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
        ),
      ),
    );
  }
}
