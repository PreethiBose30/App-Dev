import 'package:flutter/material.dart';
import '../models/product.dart';
import '../theme/app_colors.dart';
import '../utils/format.dart';
import 'swiss.dart';

/// One product in a list: "01  Samsung S26 / Phone · Warranty to Jul 2027 / ₹80,000".
class ProductRow extends StatelessWidget {
  final int number;
  final Product product;
  final VoidCallback onTap;
  const ProductRow({super.key, required this.number, required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SwissRow(
      index: number.toString().padLeft(2, '0'),
      title: product.name,
      subtitle: warrantyLine(product),
      onTap: onTap,
      trailing: product.price == null
          ? null
          : Text('₹${formatInr(product.price!)}',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w800)),
    );
  }
}
