import 'package:digital_inventory/models/product.dart';
import 'package:digital_inventory/utils/format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatInr (Indian digit grouping)', () {
    test('small numbers are left alone', () {
      expect(formatInr(0), '0');
      expect(formatInr(999), '999');
    });
    test('thousands, lakhs and crores', () {
      expect(formatInr(1234), '1,234');
      expect(formatInr(81234), '81,234');
      expect(formatInr(241135), '2,41,135');
      expect(formatInr(1234567), '12,34,567');
      expect(formatInr(123456789), '12,34,56,789');
    });
    test('rounds and keeps the sign', () {
      expect(formatInr(1234.5), '1,235');
      expect(formatInr(-45000), '-45,000');
    });
  });

  group('formatPrice', () {
    test('whole rupees have no decimals', () => expect(formatPrice(80000), '₹80,000'));
    test('paise are kept when present', () => expect(formatPrice(1234.5), '₹1,234.50'));
  });

  group('dates', () {
    final d = DateTime(2027, 7, 4);
    test('monthYear', () => expect(monthYear(d), 'Jul 2027'));
    test('dayMonthYear', () => expect(dayMonthYear(d), '4 Jul 2027'));
  });

  group('warrantyLine', () {
    test('with a warranty date', () {
      final p = Product(name: 'S26', category: 'Phone', warrantyExpiry: DateTime(2027, 7, 1));
      expect(warrantyLine(p), 'Phone · Warranty to Jul 2027');
    });
    test('without one', () {
      final p = Product(name: 'Chair', category: 'Furniture');
      expect(warrantyLine(p), 'Furniture · No warranty');
    });
  });
}
