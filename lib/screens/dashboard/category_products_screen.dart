import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class CategoryProductsScreen extends StatelessWidget {
  final String categoryName;

  const CategoryProductsScreen({
    super.key,
    required this.categoryName,
  });

  final List<Map<String, String>> products = const [
    {
      'name': 'Wireless Keyboard',
      'details': 'Electronics',
    },
    {
      'name': 'Bluetooth Speaker',
      'details': 'Electronics',
    },
    {
      'name': 'Laptop',
      'details': 'Electronics',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,

        iconTheme: const IconThemeData(
          color: AppColors.textPrimary,
        ),

        title: Text(
          categoryName.toUpperCase(),
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(20),

        itemCount: products.length,

        itemBuilder: (context, index) {
          final product = products[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 14),

            padding: const EdgeInsets.all(18),

            decoration: BoxDecoration(
              color: AppColors.surface,

              borderRadius: BorderRadius.circular(18),

              border: Border.all(
                color: Colors.white.withOpacity(0.06),
              ),
            ),

            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),

                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),

                    borderRadius: BorderRadius.circular(14),
                  ),

                  child: const Icon(
                    Icons.inventory_2_outlined,
                    color: AppColors.primary,
                    size: 26,
                  ),
                ),

                const SizedBox(width: 16),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      product['name']!,

                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      product['details']!,

                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}