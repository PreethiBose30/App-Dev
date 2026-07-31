import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../models/product.dart';
import '../../services/hive_service.dart';
import '../products/product_detail_screen.dart';

class CategoryProductsScreen extends StatefulWidget {
  final String categoryName;

  const CategoryProductsScreen({
    super.key,
    required this.categoryName,
  });

  @override
  State<CategoryProductsScreen> createState() =>
      _CategoryProductsScreenState();
}

class _CategoryProductsScreenState
    extends State<CategoryProductsScreen> {
  List<Product> categoryProducts = [];

  @override
  void initState() {
    super.initState();
    loadCategoryProducts();
  }

  void loadCategoryProducts() {
    final List<Product> allProducts =
    HiveService.getProducts();

    setState(() {
      categoryProducts = allProducts.where((product) {
        return product.category.trim().toLowerCase() ==
            widget.categoryName.trim().toLowerCase();
      }).toList();
    });
  }

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
          widget.categoryName.toUpperCase(),

          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
      ),

      body: categoryProducts.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,

          children: [
            const Icon(
              Icons.inventory_2_outlined,
              color: AppColors.textSecondary,
              size: 48,
            ),

            const SizedBox(height: 16),

            Text(
              'No products in ${widget.categoryName}',

              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'Add a product to see it here',

              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      )

          : ListView.builder(
        padding: const EdgeInsets.all(20),

        itemCount:
        categoryProducts.length,

        itemBuilder:
            (context, index) {
          final Product product =
          categoryProducts[index];

          return InkWell(
            borderRadius:
            BorderRadius.circular(18),

            onTap: () async {
              await Navigator.push(
                context,

                MaterialPageRoute(
                  builder: (context) =>
                      ProductDetailScreen(
                        product: product,
                      )
                ),
              );

              loadCategoryProducts();
            },

            child: Container(
              margin:
              const EdgeInsets.only(
                bottom: 14,
              ),

              padding:
              const EdgeInsets.all(
                18,
              ),

              decoration:
              BoxDecoration(
                color:
                AppColors.surface,

                borderRadius:
                BorderRadius.circular(
                  18,
                ),

                border: Border.all(
                  color:
                  Colors.white
                      .withOpacity(
                    0.06,
                  ),
                ),
              ),

              child: Row(
                children: [
                  Container(
                    padding:
                    const EdgeInsets
                        .all(12),

                    decoration:
                    BoxDecoration(
                      color:
                      AppColors
                          .primary
                          .withOpacity(
                        0.12,
                      ),

                      borderRadius:
                      BorderRadius
                          .circular(
                        14,
                      ),
                    ),

                    child:
                    const Icon(
                      Icons
                          .inventory_2_outlined,

                      color:
                      AppColors
                          .primary,

                      size: 26,
                    ),
                  ),

                  const SizedBox(
                    width: 16,
                  ),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                      children: [
                        Text(
                          product.name,

                          maxLines: 1,

                          overflow:
                          TextOverflow
                              .ellipsis,

                          style:
                          const TextStyle(
                            color:
                            AppColors
                                .textPrimary,

                            fontSize:
                            15,

                            fontWeight:
                            FontWeight
                                .w600,
                          ),
                        ),

                        const SizedBox(
                          height: 5,
                        ),

                        Text(
                          product.category,

                          style:
                          const TextStyle(
                            color:
                            AppColors
                                .textSecondary,

                            fontSize:
                            12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Icon(
                    Icons
                        .chevron_right_rounded,

                    color:
                    AppColors
                        .textSecondary,
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