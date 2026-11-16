import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/product_row.dart';
import '../../widgets/swiss.dart';
import '../../theme/theme_controller.dart';
import '../../models/product.dart';
import '../../services/asset_repository.dart';
import '../../services/api_client.dart';
import '../products/product_detail_screen.dart';

class CategoryProductsScreen extends StatefulWidget {
  final String categoryName;

  const CategoryProductsScreen({super.key, required this.categoryName});

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> with ThemeAwareState {
  List<Product> categoryProducts = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    loadCategoryProducts();
  }

  Future<void> loadCategoryProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      List<Product> result;
      if (widget.categoryName.toLowerCase() == 'other') {
        // "Other" is everything outside the named categories, which the
        // server cannot filter for, so it is picked out of the full list.
        const named = {'phone', 'laptop', 'tv', 'car', 'appliance', 'furniture'};
        final all = await AssetRepository.getAssets();
        result = all.where((p) => !named.contains(p.category.trim().toLowerCase())).toList();
      } else {
        result = await AssetRepository.getAssets(category: widget.categoryName);
      }
      if (!mounted) return;
      setState(() {
        categoryProducts = result;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: swissAppBar(context, widget.categoryName),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: AppColors.accent, strokeWidth: 2));
    }
    if (_errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SwissMessage(_errorMessage!, actionLabel: 'Retry', onAction: loadCategoryProducts),
      );
    }
    if (categoryProducts.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SwissMessage('No products in ${widget.categoryName}', body: 'Add a product to see it here.'),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      itemCount: categoryProducts.length,
      itemBuilder: (context, index) {
        final product = categoryProducts[index];
        return ProductRow(
          number: index + 1,
          product: product,
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProductDetailScreen(product: product)),
            );
            loadCategoryProducts();
          },
        );
      },
    );
  }
}
