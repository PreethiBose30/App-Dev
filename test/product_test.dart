import 'package:digital_inventory/models/product.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Product dates are calendar dates', () {
    test('a UTC-midnight value reads back as that calendar date', () {
      final d = Product.parseDate('2026-05-01T00:00:00+00:00')!;
      expect([d.year, d.month, d.day], [2026, 5, 1]);
      expect(d.isUtc, isFalse);
      expect([d.hour, d.minute], [0, 0]);
    });

    test('the Z form is treated the same way', () {
      final d = Product.parseDate('2027-02-28T00:00:00.000Z')!;
      expect([d.year, d.month, d.day], [2027, 2, 28]);
    });

    test('a value saved by an older build is converted to local time', () {
      final legacy = DateTime.utc(2026, 4, 30, 18, 30); // 1 May 00:00 in India
      final d = Product.parseDate(legacy.toIso8601String())!;
      expect(d.isAtSameMomentAs(legacy), isTrue);
      expect(d.isUtc, isFalse);
    });

    test('null and rubbish give null', () {
      expect(Product.parseDate(null), isNull);
      expect(Product.parseDate('not a date'), isNull);
    });

    test('dates are sent as UTC midnight of the picked day', () {
      final p = Product(name: 'TV', category: 'TV', purchaseDate: DateTime(2026, 5, 1), serviceDate: DateTime(2026, 12, 31, 23, 59));
      final body = p.toRequestBody();
      expect(body['purchaseDate'], '2026-05-01T00:00:00.000Z');
      expect(body['serviceDate'], '2026-12-31T00:00:00.000Z');
    });

    test('a picked date survives the round trip unchanged', () {
      final picked = DateTime(2026, 5, 1);
      final sent = Product(name: 'TV', category: 'TV', purchaseDate: picked).toRequestBody()['purchaseDate'];
      expect(Product.parseDate(sent), picked);
    });
  });

  group('Product.toRequestBody', () {
    test('create leaves empty optional fields out', () {
      final body = Product(name: 'Chair', category: 'Furniture').toRequestBody();
      expect(body.keys.toSet(), {'name', 'category', 'reminderEnabled'});
    });

    test('update sends empty optional fields as null so the server clears them', () {
      final body = Product(name: 'Chair', category: 'Furniture', price: 100).toRequestBody(forUpdate: true);
      expect(body['price'], 100);
      for (final key in ['brand', 'modelNumber', 'purchaseDate', 'warrantyDurationMonths', 'serviceDate', 'notes']) {
        expect(body.containsKey(key), isTrue, reason: key);
        expect(body[key], isNull, reason: key);
      }
    });
  });

  test('fromJson reads the server shape', () {
    final p = Product.fromJson({
      '_id': 'abc',
      'name': 'Phone',
      'category': 'Phone',
      'price': 80000,
      'warrantyDurationMonths': 12,
      'purchaseDate': '2026-07-01T00:00:00+00:00',
      'warrantyExpiry': '2027-07-01T00:00:00+00:00',
      'reminderEnabled': true,
    });
    expect(p.id, 'abc');
    expect(p.price, 80000.0);
    expect(p.warrantyDuration, 12);
    expect(p.warrantyExpiry, DateTime(2027, 7, 1));
    expect(p.reminderEnabled, isTrue);
  });
}
