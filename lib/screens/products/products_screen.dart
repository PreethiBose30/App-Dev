import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'product_detail_screen.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  final List<Map<String, String>> products = const [
    {
      "name": "MacBook Pro M2",
      "category": "Electronics",
    },
    {
      "name": "iPhone 15",
      "category": "Mobile",
    },
    {
      "name": "Sony Headphones",
      "category": "Accessories",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          "All Products",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: products.length,
        itemBuilder: (context, index) {

          final product = products[index];

          return InkWell(
            borderRadius: BorderRadius.circular(18),

            onTap: () async {

              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailScreen(
                    productName: product["name"]!,
                    category: product["category"]!,
                  ),
                ),
              );


              if (result != null) {
                Navigator.pop(
                  context,
                  result,
                );
              }

            },

            child: Container(
              margin: const EdgeInsets.only(bottom: 12),

              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
              ),

              child: Row(
                children: [

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),

                    child: const Icon(
                      Icons.inventory_2_outlined,
                      color: AppColors.primary,
                    ),
                  ),


                  const SizedBox(width: 14),


                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [

                      Text(
                        product["name"]!,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),


                      const SizedBox(height: 5),


                      Text(
                        product["category"]!,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),

                    ],
                  ),

                ],
              ),
            ),
          );
        },
      ),
    );
  }
}