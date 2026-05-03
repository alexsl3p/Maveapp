import 'package:intl/intl.dart';

class AppFormatters {
  AppFormatters._();

  static final _currency = NumberFormat.currency(
    locale: 'de_DE',
    symbol: '€',
    decimalDigits: 2,
  );

  static final _monthYear = DateFormat('MMMM yyyy', 'ru_RU');
  static final _dayMonth = DateFormat('d MMM', 'ru_RU');
  static final _dayMonthYear = DateFormat('d MMM yyyy', 'ru_RU');
  static final _fullDateTime = DateFormat('d MMMM yyyy, HH:mm', 'ru_RU');
  static final _monthKey = DateFormat('yyyy-MM');
  static final _dayOfMonth = DateFormat('d');

  static String price(double amount) => _currency.format(amount);

  static String percent(double value) {
    if (value.isNaN || value.isInfinite || value < 0) return '0.0%';
    return '${value.toStringAsFixed(1)}%';
  }

  static String monthYear(DateTime date) => _monthYear.format(date);
  static String dayMonth(DateTime date) => _dayMonth.format(date);
  static String dayMonthYear(DateTime date) => _dayMonthYear.format(date);
  static String fullDateTime(DateTime date) => _fullDateTime.format(date);
  static String dayOfMonth(DateTime date) => _dayOfMonth.format(date);

  static String toMonthKey(DateTime date) => _monthKey.format(date);

  static DateTime fromMonthKey(String key) {
    final parts = key.split('-');
    return DateTime(int.parse(parts[0]), int.parse(parts[1]));
  }

  static String monthKeyToDisplay(String key) {
    return monthYear(fromMonthKey(key));
  }

  static String compactPrice(double amount) {
    if (amount >= 1000) {
      return '€${(amount / 1000).toStringAsFixed(1)}k';
    }
    return price(amount);
  }
}
