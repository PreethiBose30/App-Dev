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

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    // The backend always returns UTC ISO strings (Mongoose Date -> JSON).
    // Converting to local here -- once, at the parse boundary -- means
    // every screen that reads .day/.month/.year sees the calendar date the
    // user actually picked, instead of it shifting by a day near midnight
    // for anyone east/west of UTC. Comparisons (isAfter/isBefore/difference)
    // are unaffected either way since those operate on the absolute instant.
    return DateTime.tryParse(value.toString())?.toLocal();
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] as String? ?? json['id'] as String?,
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? 'Other',
      brand: json['brand'] as String?,
      modelNumber: json['modelNumber'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      purchaseDate: _parseDate(json['purchaseDate']),
      warrantyDuration: (json['warrantyDurationMonths'] as num?)?.toInt(),
      warrantyExpiry: _parseDate(json['warrantyExpiry']),
      emiDueDate: _parseDate(json['emiDueDate']),
      serviceDate: _parseDate(json['serviceDate']),
      notes: json['notes'] as String?,
      reminderEnabled: json['reminderEnabled'] as bool? ?? false,
    );
  }

  // Fields the create/update API accepts. warrantyExpiry is server-computed
  // and intentionally not sent.
  Map<String, dynamic> toRequestBody() {
    return {
      'name': name,
      'category': category,
      if (brand != null) 'brand': brand,
      if (modelNumber != null) 'modelNumber': modelNumber,
      if (price != null) 'price': price,
      // .toUtc() first: a bare local-time ISO string (no 'Z'/offset) is
      // ambiguous and, per the JS Date spec, gets reinterpreted as the
      // *server's* local time zone when it lands in Node -- fine when
      // client and server share a time zone (as in local dev), wrong by
      // the zone offset otherwise. Sending an explicit UTC instant removes
      // the ambiguity; _parseDate's .toLocal() on the way back undoes it.
      if (purchaseDate != null) 'purchaseDate': purchaseDate!.toUtc().toIso8601String(),
      if (warrantyDuration != null) 'warrantyDurationMonths': warrantyDuration,
      if (serviceDate != null) 'serviceDate': serviceDate!.toUtc().toIso8601String(),
      if (notes != null) 'notes': notes,
      'reminderEnabled': reminderEnabled,
    };
  }
}
