import 'dart:async';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/theme_controller.dart';
import '../products/product_detail_screen.dart';
import '../products/products_screen.dart';
import '../../utils/page_route.dart';
import '../scanner/scan_screen.dart';
import 'categories_screen.dart';
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

class _HomeScreenState extends State<HomeScreen> with ThemeAwareState {
  List<Product> _products = [];
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

      // Stats aren't critical to the page -- if this call fails, the numbers
      // are worked out from the product list instead (see _summary).
      DashboardStats? stats;
      try {
        stats = await DashboardService.getMyStats();
      } on ApiException {
        stats = null;
      }
      if (!mounted) return;
      setState(() {
        _products = products;
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

  /// Server stats when we have them, otherwise the same numbers computed
  /// from the (offline-cached) product list: expiring = within 30 days.
  ({int total, double value, int expiring, int expired}) get _summary {
    final s = _stats;
    if (s != null) {
      return (total: s.totalProducts, value: s.totalValue, expiring: s.expiringSoon, expired: s.expired);
    }
    final now = DateTime.now();
    final soon = now.add(const Duration(days: 30));
    var value = 0.0, expiring = 0, expired = 0;
    for (final p in _products) {
      value += p.price ?? 0;
      final e = p.warrantyExpiry;
      if (e == null) continue;
      if (e.isBefore(now)) {
        expired++;
      } else if (e.isBefore(soon)) {
        expiring++;
      }
    }
    return (total: _products.length, value: value, expiring: expiring, expired: expired);
  }

  /// 81234 -> "81,234"; 1234567 -> "12,34,567" (Indian digit grouping).
  static String _inr(num amount) {
    final digits = amount.round().abs().toString();
    if (digits.length <= 3) return '${amount < 0 ? '-' : ''}$digits';
    final last3 = digits.substring(digits.length - 3);
    var rest = digits.substring(0, digits.length - 3);
    final parts = <String>[];
    while (rest.length > 2) {
      parts.insert(0, rest.substring(rest.length - 2));
      rest = rest.substring(0, rest.length - 2);
    }
    if (rest.isNotEmpty) parts.insert(0, rest);
    return '${amount < 0 ? '-' : ''}${parts.join(',')},$last3';
  }

  static const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

  static String _warrantyLine(Product p) {
    final e = p.warrantyExpiry;
    final warranty = e == null ? 'No warranty' : 'Warranty to ${_months[e.month - 1]} ${e.year}';
    return '${p.category} · $warranty';
  }

  @override
  Widget build(BuildContext context) {
    final firstName = (AuthService.cachedUser?.name ?? '').trim().split(' ').first;
    final title = firstName.isEmpty ? 'Inventory' : 'Inventory — $firstName';
    final summary = _summary;
    final recent = _products.take(5).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Masthead: title, bell, heavy rule.
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 12, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w800),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.notifications_none_rounded, size: 22),
                    color: AppColors.textPrimary,
                  ),
                ],
              ),
            ),
            Container(height: 1.5, color: AppColors.rule),

            Expanded(
              child: RefreshIndicator(
                color: AppColors.accent,
                onRefresh: loadProducts,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                  children: [
                    Text(
                      'Total value, ${summary.total} ${summary.total == 1 ? 'product' : 'products'}',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '₹${_inr(summary.value)}',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 68,
                          height: 1.1,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    _statRow(summary),
                    _searchField(),
                    const SizedBox(height: 22),
                    _recentHeader(),
                    _recentList(recent),
                  ],
                ),
              ),
            ),

            _bottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _statRow(({int total, double value, int expiring, int expired}) s) {
    final covered = (s.total - s.expired).clamp(0, s.total);
    Widget cell(String value, String label, {bool alert = false, bool first = false}) {
      return Expanded(
        child: Container(
          padding: EdgeInsets.fromLTRB(first ? 0 : 12, 12, 8, 12),
          decoration: BoxDecoration(
            border: first ? null : Border(left: BorderSide(color: AppColors.rule, width: 0.8)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: alert ? AppColors.accent : AppColors.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.rule, width: 0.8),
          bottom: BorderSide(color: AppColors.rule, width: 0.8),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            cell('$covered', 'Covered', first: true),
            cell('${s.expiring}', 'Expiring'),
            cell('${s.expired}', 'Expired', alert: true),
          ],
        ),
      ),
    );
  }

  Widget _searchField() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.rule, width: 0.8))),
      child: Row(
        children: [
          Icon(Icons.search, color: AppColors.textSecondary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              onSubmitted: _runSearch,
              textInputAction: TextInputAction.search,
              style: TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                hintText: 'Search',
                hintStyle: TextStyle(color: AppColors.textSecondary),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _recentHeader() {
    return Container(
      padding: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.rule, width: 0.8))),
      child: Row(
        children: [
          Text('Recent', style: TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w800)),
          const Spacer(),
          GestureDetector(
            onTap: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (context) => const ProductsScreen()));
              loadProducts();
            },
            child: Text('All →', style: TextStyle(color: AppColors.accent, fontSize: 13, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _recentList(List<Product> recent) {
    if (_isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator(color: AppColors.accent, strokeWidth: 2)),
      );
    }
    if (_errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_errorMessage!, style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextButton(onPressed: loadProducts, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (recent.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 28),
        child: Text(
          'No products yet. Tap + to add your first one.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
      );
    }
    return Column(
      children: [
        for (var i = 0; i < recent.length; i++) _productRow(i + 1, recent[i]),
      ],
    );
  }

  Widget _productRow(int index, Product product) {
    return InkWell(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProductDetailScreen(product: product)),
        );
        loadProducts();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.rule, width: 0.8))),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 36,
              child: Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(
                  index.toString().padLeft(2, '0'),
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _warrantyLine(product),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            if (product.price != null)
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(
                  '₹${_inr(product.price!)}',
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w800),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Bottom bar: heavy top rule, text labels, and the square accent Add tab
  /// docked on the right.
  Widget _bottomBar() {
    Widget tab(String label, {bool selected = false, VoidCallback? onTap}) {
      return Expanded(
        child: InkWell(
          onTap: onTap,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? AppColors.textPrimary : AppColors.textSecondary,
                fontSize: 13,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.rule, width: 1.5)),
      ),
      child: Row(
        children: [
          tab('Home', selected: true),
          tab('Categories', onTap: () async {
            await Navigator.push(context, FadeSlideRoute(page: const CategoriesScreen()));
            loadProducts();
          }),
          tab('Profile', onTap: () async {
            await Navigator.push(context, FadeSlideRoute(page: const ProfileScreen()));
            loadProducts();
          }),
          InkWell(
            onTap: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (context) => const ScanScreen()));
              loadProducts();
            },
            child: Container(
              width: 72,
              color: AppColors.accent,
              alignment: Alignment.center,
              child: Icon(Icons.add, color: AppColors.onAccent, size: 28),
            ),
          ),
        ],
      ),
    );
  }
}
