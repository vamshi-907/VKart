import 'package:intl/intl.dart';

/// Formats a numeric value as Indian Rupees using the `en_IN` locale.
///
/// Uses `NumberFormat.currency(locale: 'en_IN', symbol: '₹')` to apply Indian
/// digit grouping (e.g. ₹1,23,456.78) with the rupee symbol.
class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
  );

  /// Formats [value] as Indian Rupees.
  static String format(num value) => _currencyFormat.format(value);

  /// Formats [value] as a plain Indian number (no currency symbol).
  static String formatNumber(num value) =>
      NumberFormat.decimalPattern('en_IN').format(value);
}
