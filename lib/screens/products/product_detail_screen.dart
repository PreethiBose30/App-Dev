import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../services/recent_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productName;
  final String category;

  const ProductDetailScreen({
    super.key,
    required this.productName,
    required this.category,
  });

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

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.textPrimary,
          ),

          onPressed: () {
            Navigator.pop(
              context,
              {
                "name": widget.productName,
                "category": widget.category,
              },
            );
          },
        ),

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
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                Container(
                  height: 70,
                  width: 70,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.laptop_mac_outlined,
                    color: AppColors.primary,
                    size: 35,
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    Text(
                      widget.productName,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                      const SizedBox(height: 6),

                      Text(
                        widget.category,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              "Warranty Active",
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                          const SizedBox(width: 8),

                          const Text(
                            "Added 2 days ago",
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
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

          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Warranty Status",
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Expires on",
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "Active",
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                const Text(
                  "12 March 2027",
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 14),

                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: const LinearProgressIndicator(
                    value: 0.65,
                    minHeight: 8,
                    backgroundColor: Colors.white12,
                    valueColor: AlwaysStoppedAnimation(
                      Colors.green,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  "245 days remaining",
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          /// 📂 TAB CONTENT
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [

                _buildList(
                  getBills()
                      .map((file) => _fileCard(file, "PDF", "2 MB"))
                      .toList(),
                ),

                _buildList(
                  getWarrantyFiles()
                      .map((file) => _fileCard(file, "PDF", "800 KB"))
                      .toList(),
                ),

                _buildList(
                  getOtherFiles()
                      .map((file) => _fileCard(file, "PDF", "3 MB"))
                      .toList(),
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }

  List<String> getBills() {
    if (widget.productName == "MacBook Pro M2") {
      return [
        "MacBook_Invoice.pdf",
        "Apple_Purchase_Bill.jpg",
      ];
    }

    if (widget.productName == "iPhone 15") {
      return [
        "iPhone_Invoice.pdf",
        "Apple_Store_Bill.jpg",
      ];
    }

    return [
      "Headphones_Invoice.pdf",
      "Sony_Bill.jpg",
    ];
  }


  List<String> getWarrantyFiles() {
    if (widget.productName == "MacBook Pro M2") {
      return [
        "MacBook_Warranty.pdf",
        "AppleCare_Terms.pdf",
      ];
    }

    if (widget.productName == "iPhone 15") {
      return [
        "iPhone_Warranty.pdf",
        "AppleCare_Plan.pdf",
      ];
    }

    return [
      "Sony_Warranty.pdf",
      "Warranty_Terms.pdf",
    ];
  }


  List<String> getOtherFiles() {
    if (widget.productName == "MacBook Pro M2") {
      return [
        "MacBook_User_Manual.pdf",
        "Setup_Guide.pdf",
      ];
    }

    if (widget.productName == "iPhone 15") {
      return [
        "iPhone_User_Guide.pdf",
        "Safety_Manual.pdf",
      ];
    }

    return [
      "Headphone_Manual.pdf",
      "Bluetooth_Guide.pdf",
    ];
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

    return InkWell(
      onTap: () {

        RecentService.addRecent(
          name,
          type,
          widget.productName,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("$name opened"),
          ),
        );

      },

      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.08),
          ),
        ),

        child: Row(
          children: [

            Container(
              height: 48,
              width: 48,

              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),

              child: Icon(
                type == "PDF"
                    ? Icons.picture_as_pdf_outlined
                    : Icons.image_outlined,

                color: AppColors.primary,
              ),
            ),


            const SizedBox(width: 14),


            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  Text(
                    name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),


                  const SizedBox(height: 6),


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


            Container(
              padding: const EdgeInsets.all(8),

              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),

              child: const Icon(
                Icons.open_in_new_rounded,
                color: AppColors.primary,
                size: 18,
              ),
            ),

          ],
        ),
      ),
    );
  }
}
