import 'dart:async';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../products/product_detail_screen.dart';
import '../products/products_screen.dart';
import '../../utils/page_route.dart';
import '../scanner/scan_screen.dart';
import 'categories_screen.dart';
import 'chatbot_tab.dart';
import 'profile_screen.dart';
import '../../models/product.dart';
import '../../services/asset_repository.dart';
import '../../services/auth_service.dart';
import '../../services/api_client.dart';
import '../../services/dashboard_service.dart';
import '../../services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;
  List<Product> recentProducts = [];
  DashboardStats? _stats;
  bool _isLoading = true;
  String? _errorMessage;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> loadProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final products = await AssetRepository.getAssets();

      // Re-sync reminders against the full list every time it loads (not
      // just at create/edit time) -- local notifications live on-device, so
      // a fresh install or a second device logged into the same account
      // would otherwise never get them scheduled at all. Fire-and-forget:
      // it shouldn't block or fail the screen if it errors.
      unawaited(NotificationService.syncAll(products));

      // Stats aren't critical to the page -- if this call fails, still show
      // the product list rather than blocking the whole screen on it.
      DashboardStats? stats;
      try {
        stats = await DashboardService.getMyStats();
      } on ApiException {
        stats = null;
      }
      if (!mounted) return;
      setState(() {
        recentProducts = products.take(3).toList();
        _stats = stats;
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

  void _runSearch(String query) {
    if (query.trim().isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductsScreen(initialSearch: query.trim()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;
    final displayName = AuthService.cachedUser?.name ?? 'there';

    const sectionGap = SizedBox(height: 24);

    return Scaffold(
      backgroundColor: AppColors.background,

      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ScanScreen(),
            ),
          );

          loadProducts();
        },
        child: const Icon(
          Icons.add,
          color: Colors.black,
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) async {
            if (index == 1) {
              await Navigator.push(context, FadeSlideRoute(page: const CategoriesScreen()));
              loadProducts();
            } else if (index == 2) {
              Navigator.push(context, FadeSlideRoute(page: const ChatbotTab()));
            } else if (index == 3) {
              await Navigator.push(context, FadeSlideRoute(page: const ProfileScreen()));
              loadProducts();
            } else {
              setState(() => currentIndex = index);
            }
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
            BottomNavigationBarItem(icon: Icon(Icons.category), label: ""),
            BottomNavigationBarItem(icon: Icon(Icons.auto_awesome), label: ""),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: ""),
          ],
        ),
      ),

      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          "Digital Inventory",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications_none_rounded),
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),

      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: loadProducts,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: w * 0.05, vertical: h * 0.02),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(w * 0.06),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    gradient: LinearGradient(
                      colors: [AppColors.primary.withOpacity(0.35), AppColors.surface],
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Welcome back",
                            style: TextStyle(color: AppColors.textSecondary, fontSize: w * 0.04),
                          ),
                          SizedBox(height: h * 0.01),
                          Text(
                            displayName,
                            style: TextStyle(fontSize: w * 0.08, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary.withOpacity(.15),
                        ),
                        child: const Icon(Icons.folder_copy_outlined, color: AppColors.primary, size: 34),
                      ),
                    ],
                  ),
                ),

                sectionGap,

                if (_stats != null) ...[
                  _sectionChip("Vault Overview"),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(22)),
                    child: Row(
                      children: [
                        _statTile('Products', '${_stats!.totalProducts}'),
                        _statTile('Value', '₹${_stats!.totalValue.toStringAsFixed(0)}'),
                        _statTile('Expiring soon', '${_stats!.expiringSoon}', warn: _stats!.expiringSoon > 0),
                        _statTile('Expired', '${_stats!.expired}', warn: _stats!.expired > 0),
                      ],
                    ),
                  ),
                  sectionGap,
                ],

                Container(
                  height: h * 0.065,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: AppColors.textSecondary),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onSubmitted: _runSearch,
                          textInputAction: TextInputAction.search,
                          style: const TextStyle(color: AppColors.textPrimary),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: "Search products...",
                            hintStyle: TextStyle(color: AppColors.textSecondary),
                            isCollapsed: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                sectionGap,

                _sectionChip("Recent Products"),
                const SizedBox(height: 12),

                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                  )
                else if (_errorMessage != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(18)),
                    child: Column(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.redAccent, size: 30),
                        const SizedBox(height: 10),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 10),
                        TextButton(onPressed: loadProducts, child: const Text('RETRY')),
                      ],
                    ),
                  )
                else if (recentProducts.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(18)),
                    child: const Column(
                      children: [
                        Icon(Icons.inventory_2_outlined, color: AppColors.textSecondary, size: 30),
                        SizedBox(height: 10),
                        Text(
                          "No recent products",
                          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Products you add will appear here",
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  )
                else
                  ...recentProducts.map((product) => _productCard(product)),

                const SizedBox(height: 8),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ProductsScreen()),
                      );
                      loadProducts();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text(
                      "VIEW ALL PRODUCTS",
                      style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
                    ),
                  ),
                ),

                SizedBox(height: h * 0.05),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionChip(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(title, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
    );
  }

  Widget _statTile(String label, String value, {bool warn = false}) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: warn ? Colors.orangeAccent : AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _productCard(Product product) {
    return InkWell(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProductDetailScreen(product: product)),
        );
        loadProducts();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(18)),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.inventory_2_outlined, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(product.category, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
