import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../models/product.dart';
import '../../services/recent_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState
    extends State<ProductDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: 3,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String formatDate(DateTime? date) {
    if (date == null) {
      return 'Not added';
    }

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  bool get isWarrantyActive {
    if (widget.product.warrantyExpiry == null) {
      return false;
    }

    return widget.product.warrantyExpiry!
        .isAfter(DateTime.now());
  }

  int get remainingDays {
    if (widget.product.warrantyExpiry == null) {
      return 0;
    }

    return widget.product.warrantyExpiry!
        .difference(DateTime.now())
        .inDays;
  }

  @override
  Widget build(BuildContext context) {
    final Product product = widget.product;

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.textPrimary,
          ),

          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Text(
          'Product Details',

          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(18),

            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.18),
                  AppColors.surface,
                ],

                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),

              borderRadius:
              BorderRadius.circular(24),
            ),

            child: Row(
              children: [
                Container(
                  height: 70,
                  width: 70,

                  decoration: BoxDecoration(
                    color: AppColors.primary
                        .withOpacity(0.15),

                    borderRadius:
                    BorderRadius.circular(20),
                  ),

                  child: const Icon(
                    Icons.inventory_2_outlined,

                    color: AppColors.primary,
                    size: 35,
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,

                    children: [
                      Text(
                        product.name,

                        style: const TextStyle(
                          color:
                          AppColors.textPrimary,

                          fontWeight:
                          FontWeight.bold,

                          fontSize: 18,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        product.category,

                        style: const TextStyle(
                          color:
                          AppColors.textSecondary,

                          fontSize: 13,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Container(
                        padding:
                        const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),

                        decoration: BoxDecoration(
                          color: isWarrantyActive
                              ? Colors.green
                              .withOpacity(0.15)
                              : Colors.red
                              .withOpacity(0.15),

                          borderRadius:
                          BorderRadius.circular(
                            20,
                          ),
                        ),

                        child: Text(
                          product.warrantyExpiry ==
                              null
                              ? 'No warranty date'
                              : isWarrantyActive
                              ? 'Warranty Active'
                              : 'Warranty Expired',

                          style: TextStyle(
                            color:
                            isWarrantyActive
                                ? Colors.green
                                : Colors.red,

                            fontSize: 11,

                            fontWeight:
                            FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Container(
            margin:
            const EdgeInsets.symmetric(
              horizontal: 16,
            ),

            decoration: BoxDecoration(
              color: AppColors.surface,

              borderRadius:
              BorderRadius.circular(20),
            ),

            child: TabBar(
              controller: _tabController,

              indicatorColor:
              AppColors.primary,

              labelColor:
              AppColors.primary,

              unselectedLabelColor:
              AppColors.textSecondary,

              tabs: const [
                Tab(text: 'Details'),
                Tab(text: 'Warranty'),
                Tab(text: 'Files'),
              ],
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: TabBarView(
              controller: _tabController,

              children: [
                _buildDetailsTab(product),

                _buildWarrantyTab(product),

                _buildFilesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsTab(
      Product product,
      ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),

      child: Container(
        padding: const EdgeInsets.all(18),

        decoration: BoxDecoration(
          color: AppColors.surface,

          borderRadius:
          BorderRadius.circular(22),
        ),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [
            const Text(
              'Product Information',

              style: TextStyle(
                color:
                AppColors.textPrimary,

                fontSize: 16,

                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(height: 18),

            _detailRow(
              'Product Name',
              product.name,
            ),

            _detailRow(
              'Category',
              product.category,
            ),

            _detailRow(
              'Price',
              product.price == null
                  ? 'Not added'
                  : '₹${product.price!.toStringAsFixed(2)}',
            ),

            _detailRow(
              'Purchase Date',
              formatDate(
                product.purchaseDate,
              ),
            ),

            _detailRow(
              'Warranty Expiry',
              formatDate(
                product.warrantyExpiry,
              ),
            ),

            _detailRow(
              'EMI Due Date',
              formatDate(
                product.emiDueDate,
              ),
            ),

            _detailRow(
              'Notes',
              product.notes == null ||
                  product.notes!
                      .trim()
                      .isEmpty
                  ? 'No notes added'
                  : product.notes!,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarrantyTab(
      Product product,
      ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),

      child: Container(
        padding: const EdgeInsets.all(18),

        decoration: BoxDecoration(
          color: AppColors.surface,

          borderRadius:
          BorderRadius.circular(22),
        ),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [
            const Text(
              'Warranty Status',

              style: TextStyle(
                color:
                AppColors.textPrimary,

                fontSize: 16,

                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(height: 18),

            _detailRow(
              'Expires On',
              formatDate(
                product.warrantyExpiry,
              ),
            ),

            const SizedBox(height: 12),

            Container(
              padding:
              const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),

              decoration: BoxDecoration(
                color: product.warrantyExpiry ==
                    null
                    ? AppColors.primary
                    .withOpacity(0.1)
                    : isWarrantyActive
                    ? Colors.green
                    .withOpacity(0.15)
                    : Colors.red
                    .withOpacity(0.15),

                borderRadius:
                BorderRadius.circular(
                  18,
                ),
              ),

              child: Text(
                product.warrantyExpiry ==
                    null
                    ? 'No warranty information'
                    : isWarrantyActive
                    ? '$remainingDays days remaining'
                    : 'Warranty has expired',

                style: TextStyle(
                  color:
                  product.warrantyExpiry ==
                      null
                      ? AppColors.primary
                      : isWarrantyActive
                      ? Colors.green
                      : Colors.red,

                  fontWeight:
                  FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilesTab() {
    return Center(
      child: Column(
        mainAxisAlignment:
        MainAxisAlignment.center,

        children: [
          const Icon(
            Icons.folder_open_outlined,

            color:
            AppColors.textSecondary,

            size: 50,
          ),

          const SizedBox(height: 14),

          const Text(
            'No documents added',

            style: TextStyle(
              color:
              AppColors.textPrimary,

              fontWeight:
              FontWeight.w600,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Bills and warranty files will appear here',

            style: TextStyle(
              color:
              AppColors.textSecondary,

              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(
      String label,
      String value,
      ) {
    return Padding(
      padding:
      const EdgeInsets.only(
        bottom: 16,
      ),

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [
          Text(
            label,

            style: const TextStyle(
              color:
              AppColors.textSecondary,

              fontSize: 12,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            value,

            style: const TextStyle(
              color:
              AppColors.textPrimary,

              fontSize: 15,

              fontWeight:
              FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void openFile(
      String fileName,
      ) {
    RecentService.addRecent(
      fileName,
      'File',
      widget.product.name,
    );

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content:
        Text('$fileName opened'),
      ),
    );
  }
}