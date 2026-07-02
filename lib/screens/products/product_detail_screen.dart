import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          "Product Details",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Column(
        children: [

          /// 📦 PRODUCT HEADER
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.inventory_2_outlined,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "MacBook Pro M2",
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Electronics • Added 2 days ago",
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),

          /// 📑 TABS
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              tabs: const [
                Tab(text: "Bills"),
                Tab(text: "Warranty"),
                Tab(text: "Files"),
              ],
            ),
          ),

          const SizedBox(height: 10),

          /// 📂 TAB CONTENT
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [

                /// 📄 BILLS
                _buildList([
                  _fileCard("Invoice_001.pdf", "PDF", "2 MB"),
                  _fileCard("Purchase_Bill.jpg", "Image", "1.2 MB"),
                ]),

                /// 🧾 WARRANTY
                _buildList([
                  _fileCard("Warranty_Card.pdf", "PDF", "800 KB"),
                  _fileCard("Warranty_Terms.pdf", "PDF", "500 KB"),
                ]),

                /// 📎 FILES
                _buildList([
                  _fileCard("User_Manual.pdf", "PDF", "3 MB"),
                  _fileCard("Setup_Guide.pdf", "PDF", "2 MB"),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 📄 FILE LIST BUILDER
  Widget _buildList(List<Widget> items) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: items,
    );
  }

  /// 📎 FILE CARD UI
  Widget _fileCard(String name, String type, String size) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.insert_drive_file_outlined,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "$type • $size",
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.more_horiz,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}
