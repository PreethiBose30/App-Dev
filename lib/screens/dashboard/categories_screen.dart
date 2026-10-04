import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../models/product.dart';
import '../../services/asset_repository.dart';
import '../../services/api_client.dart';
import 'category_products_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  // Kept in sync with AddProductScreen's category dropdown -- these two
  // lists used to diverge (Electronics/Appliances/Documents/Furniture here
  // vs Phone/Laptop/TV/Car/Appliance/Furniture/Other there), which meant
  // most category tiles could never show a product regardless of what was
  // added.
  final List<Map<String, dynamic>> categories = const [
    {'name': 'Phone', 'icon': Icons.smartphone_outlined},
    {'name': 'Laptop', 'icon': Icons.laptop_mac_outlined},
    {'name': 'TV', 'icon': Icons.tv_outlined},
    {'name': 'Car', 'icon': Icons.directions_car_outlined},
    {'name': 'Appliance', 'icon': Icons.kitchen_outlined},
    {'name': 'Furniture', 'icon': Icons.chair_outlined},
    {'name': 'Other', 'icon': Icons.category_outlined},
  ];

  List<Product> products = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future<void> loadProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final result = await AssetRepository.getAssets();
      if (!mounted) return;
      setState(() {
        products = result;
        _isLoading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
    }
  }

  int getCategoryCount(String categoryName) {
    return products.where((product) {
      return product.category.trim().toLowerCase() == categoryName.trim().toLowerCase();
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
          style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: 1.5),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.redAccent, size: 40),
                      const SizedBox(height: 12),
                      Text(_errorMessage!, style: const TextStyle(color: AppColors.textPrimary)),
                      const SizedBox(height: 12),
                      TextButton(onPressed: loadProducts, child: const Text('RETRY')),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(20),
                  child: GridView.builder(
                    itemCount: categories.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.1,
                    ),
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final String categoryName = category['name'] as String;
                      final IconData categoryIcon = category['icon'] as IconData;
                      final int productCount = getCategoryCount(categoryName);

                      return GestureDetector(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CategoryProductsScreen(categoryName: categoryName),
                            ),
                          );
                          loadProducts();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.white.withOpacity(0.06)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(categoryIcon, color: AppColors.primary, size: 34),
                              const Spacer(),
                              Text(
                                categoryName,
                                style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                productCount == 1 ? '1 product' : '$productCount products',
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
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
