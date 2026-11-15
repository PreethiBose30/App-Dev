import 'package:digital_inventory/models/product.dart';
import 'package:digital_inventory/widgets/product_row.dart';
import 'package:digital_inventory/widgets/swiss.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  testWidgets('ProductRow shows number, name, warranty line and price', (tester) async {
    var taps = 0;
    final product = Product(name: 'Samsung S26', category: 'Phone', price: 80000, warrantyExpiry: DateTime(2027, 7, 1));
    await tester.pumpWidget(_host(ProductRow(number: 1, product: product, onTap: () => taps++)));

    expect(find.text('01'), findsOneWidget);
    expect(find.text('Samsung S26'), findsOneWidget);
    expect(find.text('Phone · Warranty to Jul 2027'), findsOneWidget);
    expect(find.text('₹80,000'), findsOneWidget);

    await tester.tap(find.text('Samsung S26'));
    expect(taps, 1);
  });

  testWidgets('ProductRow hides the price when there is none', (tester) async {
    final product = Product(name: 'Chair', category: 'Furniture');
    await tester.pumpWidget(_host(ProductRow(number: 12, product: product, onTap: () {})));
    expect(find.text('12'), findsOneWidget);
    expect(find.textContaining('₹'), findsNothing);
  });

  testWidgets('SlowHint appears only after the delay, and hides when inactive', (tester) async {
    const text = 'Waking up';
    await tester.pumpWidget(_host(const SlowHint(active: true, text: text, after: Duration(seconds: 5))));
    expect(find.text(text), findsNothing);

    await tester.pump(const Duration(seconds: 4));
    expect(find.text(text), findsNothing);

    await tester.pump(const Duration(seconds: 2));
    expect(find.text(text), findsOneWidget);

    await tester.pumpWidget(_host(const SlowHint(active: false, text: text, after: Duration(seconds: 5))));
    expect(find.text(text), findsNothing);
  });

  testWidgets('SwissButton is disabled while loading', (tester) async {
    var presses = 0;
    await tester.pumpWidget(_host(SwissButton('Save', onPressed: () => presses++, loading: true)));
    expect(find.text('Save'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.tap(find.byType(SwissButton));
    expect(presses, 0);
  });
}
