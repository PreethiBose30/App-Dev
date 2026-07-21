import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'category_products_screen.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  final List<Map<String, dynamic>> categories = const [
    {
      'name': 'Electronics',
      'icon': Icons.devices_outlined,
      'count': 3,
    },
    {
      'name': 'Appliances',
      'icon': Icons.kitchen_outlined,
      'count': 2,
    },
    {
      'name': 'Documents',
      'icon': Icons.description_outlined,
      'count': 5,
    },
    {
      'name': 'Furniture',
      'icon': Icons.chair_outlined,
      'count': 1,
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
          'CATEGORIES',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: GridView.builder(
          itemCount: categories.length,

          gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.1,
          ),

          itemBuilder: (context, index) {
            final category = categories[index];

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CategoryProductsScreen(
                      categoryName: category['name'],
                    ),
                  ),
                );
              },

              child: Container(
                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),

                  border: Border.all(
                    color: Colors.white.withOpacity(0.06),
                  ),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Icon(
                      category['icon'],
                      color: AppColors.primary,
                      size: 34,
                    ),

                    const Spacer(),

                    Text(
                      category['name'],
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      '${category['count']} products',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}