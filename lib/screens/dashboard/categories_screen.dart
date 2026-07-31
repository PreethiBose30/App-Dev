import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../models/product.dart';
import '../../services/hive_service.dart';
import 'category_products_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final List<Map<String, dynamic>> categories = [
    {
      'name': 'Electronics',
      'icon': Icons.devices_outlined,
    },
    {
      'name': 'Appliances',
      'icon': Icons.kitchen_outlined,
    },
    {
      'name': 'Documents',
      'icon': Icons.description_outlined,
    },
    {
      'name': 'Furniture',
      'icon': Icons.chair_outlined,
    },
  ];

  List<Product> products = [];

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  void loadProducts() {
    setState(() {
      products = HiveService.getProducts();
    });
  }

  int getCategoryCount(String categoryName) {
    return products.where((product) {
      return product.category.trim().toLowerCase() ==
          categoryName.trim().toLowerCase();
    }).length;
  }

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

            final String categoryName =
            category['name'] as String;

            final IconData categoryIcon =
            category['icon'] as IconData;

            final int productCount =
            getCategoryCount(categoryName);

            return GestureDetector(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        CategoryProductsScreen(
                          categoryName: categoryName,
                        ),
                  ),
                );

                loadProducts();
              },

              child: Container(
                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),

                  border: Border.all(
                    color:
                    Colors.white.withOpacity(0.06),
                  ),
                ),

                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [
                    Icon(
                      categoryIcon,
                      color: AppColors.primary,
                      size: 34,
                    ),

                    const Spacer(),

                    Text(
                      categoryName,

                      style: const TextStyle(
                        color:
                        AppColors.textPrimary,

                        fontSize: 16,

                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      productCount == 1
                          ? '1 product'
                          : '$productCount products',

                      style: const TextStyle(
                        color:
                        AppColors.textSecondary,

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