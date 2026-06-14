import 'package:intl/intl.dart';

final NumberFormat _euroFormat = NumberFormat.currency(
  locale: 'fr_FR',
  symbol: '€',
  decimalDigits: 0,
);

final NumberFormat _euroFormatDecimals = NumberFormat.currency(
  locale: 'fr_FR',
  symbol: '€',
  decimalDigits: 2,
);

final NumberFormat _decimalFormat = NumberFormat.decimalPattern('fr_FR');

String formatEuro(num value, {bool decimals = false}) {
  return decimals ? _euroFormatDecimals.format(value) : _euroFormat.format(value);
}

String formatNumber(num value) => _decimalFormat.format(value);

String formatPercent(double value, {int fractionDigits = 1}) {
  return '${value.toStringAsFixed(fractionDigits)} %';
}
