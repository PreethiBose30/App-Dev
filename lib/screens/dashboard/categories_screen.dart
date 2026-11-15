import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/swiss.dart';
import '../../theme/theme_controller.dart';
import '../../models/product.dart';
import '../../services/asset_repository.dart';
import '../../services/api_client.dart';
import 'category_products_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> with ThemeAwareState {
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
      appBar: swissAppBar(context, 'Categories'),
      body: RefreshIndicator(
        color: AppColors.accent,
        onRefresh: loadProducts,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          children: [
            Text(
              'Browse by type',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 40, height: 1.0, fontWeight: FontWeight.w900, letterSpacing: -2),
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator(color: AppColors.accent, strokeWidth: 2)),
              )
            else if (_errorMessage != null)
              SwissMessage(_errorMessage!, actionLabel: 'Retry', onAction: loadProducts)
            else
              Container(
                decoration: BoxDecoration(border: Border(top: BorderSide(color: AppColors.rule, width: 0.8))),
                child: Column(
                  children: [
                    for (var i = 0; i < categories.length; i++)
                      Builder(builder: (context) {
                        final name = categories[i]['name'] as String;
                        final count = getCategoryCount(name);
                        return SwissRow(
                          index: (i + 1).toString().padLeft(2, '0'),
                          title: name,
                          trailingTop: 0,
                          trailing: Text(
                            '$count',
                            style: TextStyle(
                              color: count == 0 ? AppColors.textSecondary : AppColors.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => CategoryProductsScreen(categoryName: name)),
                            );
                            loadProducts();
                          },
                        );
                      }),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
