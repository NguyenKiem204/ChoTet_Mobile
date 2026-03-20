import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String format(dynamic amount) {
    if (amount == null) return '0đ';
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    return formatCurrency.format(amount);
  }
}
