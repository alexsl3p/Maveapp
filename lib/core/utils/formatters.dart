import 'package:intl/intl.dart';

class AppFormatters {
  AppFormatters._();

  static final _currency = NumberFormat.currency(
    locale: 'de_DE',
    symbol: '€',
    decimalDigits: 2,
  );

  static final _dayMonth = DateFormat('d MMM', 'ru_RU');
  static final _fullDateTime = DateFormat('d MMMM yyyy, HH:mm', 'ru_RU');
  static final _monthKey = DateFormat('yyyy-MM');

  // Russian intl gives genitive case (мая, января…).
  // Use explicit nominative forms everywhere months are shown as headings.
  static const _nominative = [
    'Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь',
    'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь',
  ];

  static String price(double amount) => _currency.format(amount);

  static String percent(double value) {
    if (value.isNaN || value.isInfinite || value < 0) return '0.0%';
    return '${value.toStringAsFixed(1)}%';
  }

  /// "Май 2026"
  static String monthYear(DateTime date) =>
      '${_nominative[date.month - 1]} ${date.year}';

  /// "май" — lowercase nominative for inline use
  static String monthLower(DateTime date) =>
      _nominative[date.month - 1].toLowerCase();

  static String dayMonth(DateTime date) => _dayMonth.format(date);

  static String fullDateTime(DateTime date) => _fullDateTime.format(date);

  static String toMonthKey(DateTime date) => _monthKey.format(date);

  static DateTime fromMonthKey(String key) {
    final parts = key.split('-');
    return DateTime(int.parse(parts[0]), int.parse(parts[1]));
  }

  static String monthKeyToDisplay(String key) =>
      monthYear(fromMonthKey(key));

  static String compactPrice(double amount) {
    if (amount >= 1000) {
      return '€${(amount / 1000).toStringAsFixed(1)}k';
    }
    return price(amount);
  }
}
