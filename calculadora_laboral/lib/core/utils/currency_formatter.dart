import 'package:intl/intl.dart';

/// Utilidades de formateo de moneda para la aplicación.
///
/// Centraliza el formato "S/. 1,234.56" en un único lugar.
abstract final class CurrencyFormatter {
  static final _formatter = NumberFormat.currency(
    locale: 'es_PE',
    symbol: 'S/. ',
    decimalDigits: 2,
  );

  static final _formatterNoSymbol = NumberFormat('#,##0.00', 'es_PE');

  /// Formatea un monto como "S/. 1,234.56"
  static String format(double amount) => _formatter.format(amount);

  /// Formatea un monto sin símbolo: "1,234.56"
  static String formatNoSymbol(double amount) =>
      _formatterNoSymbol.format(amount);

  /// Formatea un porcentaje como "13.00%"
  static String formatPercent(double rate) =>
      '${(rate * 100).toStringAsFixed(2)}%';
}
