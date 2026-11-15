import '../models/product.dart';

/// 81234 -> "81,234"; 1234567 -> "12,34,567" (Indian digit grouping).
String formatInr(num amount) {
  final digits = amount.round().abs().toString();
  final sign = amount < 0 ? '-' : '';
  if (digits.length <= 3) return '$sign$digits';
  final last3 = digits.substring(digits.length - 3);
  var rest = digits.substring(0, digits.length - 3);
  final parts = <String>[];
  while (rest.length > 2) {
    parts.insert(0, rest.substring(rest.length - 2));
    rest = rest.substring(0, rest.length - 2);
  }
  if (rest.isNotEmpty) parts.insert(0, rest);
  return '$sign${parts.join(',')},$last3';
}

const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

/// "Jul 2027"
String monthYear(DateTime d) => '${_months[d.month - 1]} ${d.year}';

/// "12 Sep 2026"
String dayMonthYear(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';

/// "Phone · Warranty to Jul 2027" / "Phone · No warranty"
String warrantyLine(Product p) {
  final e = p.warrantyExpiry;
  return '${p.category} · ${e == null ? 'No warranty' : 'Warranty to ${monthYear(e)}'}';
}

/// ₹ amount for display: whole rupees without decimals, paise kept when present.
String formatPrice(double amount) {
  final whole = amount.truncate();
  final paise = ((amount - whole) * 100).round();
  final base = formatInr(whole);
  return paise == 0 ? '₹$base' : '₹$base.${paise.toString().padLeft(2, '0')}';
}
