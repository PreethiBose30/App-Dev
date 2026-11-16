// Mirrors the backend's Asset document (see backend/src/models/Asset.js).
// This is a plain data class -- persistence goes through AssetRepository
// (API when reachable, Hive cache otherwise). Documents are a separate
// collection now (see RemoteDocument/LocalDocument), not fields here.
class Product {
  final String? id;
  final String name;
  final String category;
  final String? brand;
  final String? modelNumber;
  final double? price;
  final DateTime? purchaseDate;
  final int? warrantyDuration; // months
  final DateTime? warrantyExpiry; // computed server-side
  final DateTime? emiDueDate;
  final DateTime? serviceDate;
  final String? notes;
  final bool reminderEnabled;

  Product({
    this.id,
    required this.name,
    required this.category,
    this.brand,
    this.modelNumber,
    this.price,
    this.purchaseDate,
    this.warrantyDuration,
    this.warrantyExpiry,
    this.emiDueDate,
    this.serviceDate,
    this.notes,
    this.reminderEnabled = false,
  });

  /// Purchase, warranty and service dates are calendar dates, not moments
  /// in time. They travel as UTC midnight of that date ("2026-05-01T00:00Z")
  /// so the server's month arithmetic for the warranty expiry works on the
  /// date the user picked, whatever time zone the phone is in. Read back,
  /// a UTC-midnight value is that calendar date; anything else is a value
  /// saved by an older build (which sent the local-midnight instant) and is
  /// converted the way that build expected.
  static DateTime? parseDate(dynamic value) {
    if (value == null) return null;
    final parsed = DateTime.tryParse(value.toString());
    if (parsed == null) return null;
    final isUtcMidnight = parsed.isUtc &&
        parsed.hour == 0 &&
        parsed.minute == 0 &&
        parsed.second == 0 &&
        parsed.millisecond == 0;
    if (isUtcMidnight) return DateTime(parsed.year, parsed.month, parsed.day);
    return parsed.toLocal();
  }

  /// The server reports "no warranty" as 0 months; in the app that is simply
  /// no value.
  static int? _positiveOrNull(int? months) => (months == null || months <= 0) ? null : months;

  static String _dateOnly(DateTime d) => DateTime.utc(d.year, d.month, d.day).toIso8601String();

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] as String? ?? json['id'] as String?,
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? 'Other',
      brand: json['brand'] as String?,
      modelNumber: json['modelNumber'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      purchaseDate: parseDate(json['purchaseDate']),
      warrantyDuration: _positiveOrNull((json['warrantyDurationMonths'] as num?)?.toInt()),
      warrantyExpiry: parseDate(json['warrantyExpiry']),
      emiDueDate: parseDate(json['emiDueDate']),
      serviceDate: parseDate(json['serviceDate']),
      notes: json['notes'] as String?,
      reminderEnabled: json['reminderEnabled'] as bool? ?? false,
    );
  }

  /// Fields the create/update API accepts. warrantyExpiry is server-computed
  /// and intentionally not sent.
  ///
  /// With [forUpdate], optional fields that are empty are sent as explicit
  /// nulls, which the server reads as "remove this value" -- otherwise
  /// blanking a field on the edit form would silently keep the old value.
  Map<String, dynamic> toRequestBody({bool forUpdate = false}) {
    final body = <String, dynamic>{
      'name': name,
      'category': category,
      'brand': brand,
      'modelNumber': modelNumber,
      'price': price,
      'purchaseDate': purchaseDate == null ? null : _dateOnly(purchaseDate!),
      'warrantyDurationMonths': warrantyDuration,
      'serviceDate': serviceDate == null ? null : _dateOnly(serviceDate!),
      'notes': notes,
      'reminderEnabled': reminderEnabled,
    };
    if (!forUpdate) body.removeWhere((key, value) => value == null);
    return body;
  }
}
