import 'api_client.dart';

class DashboardStats {
  final int totalProducts;
  final double totalValue;
  final int expiringSoon;
  final int expired;
  final List<CategoryCount> byCategory;

  DashboardStats({
    required this.totalProducts,
    required this.totalValue,
    required this.expiringSoon,
    required this.expired,
    required this.byCategory,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalProducts: (json['totalProducts'] as num?)?.toInt() ?? 0,
      totalValue: (json['totalValue'] as num?)?.toDouble() ?? 0,
      expiringSoon: (json['expiringSoon'] as num?)?.toInt() ?? 0,
      expired: (json['expired'] as num?)?.toInt() ?? 0,
      byCategory: ((json['byCategory'] as List?) ?? [])
          .map((c) => CategoryCount.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }
}

class CategoryCount {
  final String category;
  final int count;
  CategoryCount({required this.category, required this.count});

  factory CategoryCount.fromJson(Map<String, dynamic> json) {
    return CategoryCount(category: json['category'] as String? ?? 'Other', count: (json['count'] as num?)?.toInt() ?? 0);
  }
}

class DashboardService {
  static Future<DashboardStats> getMyStats() async {
    final data = await ApiClient.get('/dashboard/stats');
    return DashboardStats.fromJson(data as Map<String, dynamic>);
  }
}
