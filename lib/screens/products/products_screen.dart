import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/product_row.dart';
import '../../widgets/swiss.dart';
import '../../theme/theme_controller.dart';
import '../../models/product.dart';
import '../../services/asset_repository.dart';
import '../../services/api_client.dart';
import 'product_detail_screen.dart';

class ProductsScreen extends StatefulWidget {
  final String? initialSearch;

  const ProductsScreen({super.key, this.initialSearch});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> with ThemeAwareState {
  List<Product> products = [];
  bool _isLoading = true;
  String? _errorMessage;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialSearch ?? '');
    loadProducts(search: widget.initialSearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> loadProducts({String? search}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final result = await AssetRepository.getAssets(search: search);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: swissAppBar(context, 'All products'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Container(
              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.rule, width: 0.8))),
              child: Row(
                children: [
                  Icon(Icons.search, color: AppColors.textSecondary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onSubmitted: (value) => loadProducts(search: value.trim()),
                      textInputAction: TextInputAction.search,
                      style: TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        hintText: 'Search',
                        hintStyle: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: AppColors.accent, strokeWidth: 2));
    }
    if (_errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SwissMessage(
          _errorMessage!,
          actionLabel: 'Retry',
          onAction: () => loadProducts(search: _searchController.text.trim()),
        ),
      );
    }
    if (products.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: SwissMessage('No products found', body: 'Add a product to see it here.'),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductRow(
          number: index + 1,
          product: product,
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProductDetailScreen(product: product)),
            );
            loadProducts(search: _searchController.text.trim());
          },
        );
      },
    );
  }
}
