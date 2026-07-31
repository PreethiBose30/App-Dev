import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../models/product.dart';
import '../../services/hive_service.dart';
import 'product_detail_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
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

        title: const Text(
          "All Products",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: products.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              color: AppColors.textSecondary,
              size: 50,
            ),

            SizedBox(height: 14),

            Text(
              "No products added",
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),

            SizedBox(height: 6),

            Text(
              "Add a product to see it here",
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      )

          : ListView.builder(
        padding: const EdgeInsets.all(16),

        itemCount: products.length,

        itemBuilder: (context, index) {
          final Product product = products[index];

          return InkWell(
            borderRadius:
            BorderRadius.circular(18),

            onTap: () {
              Navigator.push(
                context,

                MaterialPageRoute(
                  builder: (context) =>
                      ProductDetailScreen(
                        product: product,
                      ),
                ),
              );
            },

            child: Container(
              margin:
              const EdgeInsets.only(
                bottom: 12,
              ),

              padding:
              const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: AppColors.surface,

                borderRadius:
                BorderRadius.circular(
                  18,
                ),
              ),

              child: Row(
                children: [
                  Container(
                    padding:
                    const EdgeInsets.all(
                      12,
                    ),

                    decoration:
                    BoxDecoration(
                      color: AppColors
                          .primary
                          .withOpacity(
                        0.15,
                      ),

                      borderRadius:
                      BorderRadius
                          .circular(
                        14,
                      ),
                    ),

                    child: const Icon(
                      Icons
                          .inventory_2_outlined,

                      color:
                      AppColors.primary,
                    ),
                  ),

                  const SizedBox(
                    width: 14,
                  ),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                      children: [
                        Text(
                          product.name,

                          style:
                          const TextStyle(
                            color: AppColors
                                .textPrimary,

                            fontWeight:
                            FontWeight
                                .w600,

                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(
                          height: 5,
                        ),

                        Text(
                          product.category,

                          style:
                          const TextStyle(
                            color: AppColors
                                .textSecondary,

                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Icon(
                    Icons
                        .chevron_right_rounded,

                    color: AppColors
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