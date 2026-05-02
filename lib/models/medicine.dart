class Medicine {
  final String id;
  final String name;
  final String? scientificName;
  final String? category;
  final String? barcode;
  final String? batchNo;
  final String? expiryDate;
  final double purchasePrice;
  final double salePrice;
  final int quantity;
  final int minQuantity;
  final String unit;
  final String? supplierId;
  final String? activeIngredient;
  final String? alternatives;
  final String? location;
  final String? notes;
  final String? createdAt;
  final String? updatedAt;

  const Medicine({
    required this.id,
    required this.name,
    this.scientificName,
    this.category,
    this.barcode,
    this.batchNo,
    this.expiryDate,
    this.purchasePrice = 0,
    this.salePrice = 0,
    this.quantity = 0,
    this.minQuantity = 10,
    this.unit = 'unit',
    this.supplierId,
    this.activeIngredient,
    this.alternatives,
    this.location,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory Medicine.fromMap(Map<String, dynamic> m) => Medicine(
        id: m['id'] as String,
        name: m['name'] as String,
        scientificName: m['scientific_name'] as String?,
        category: m['category'] as String?,
        barcode: m['barcode'] as String?,
        batchNo: m['batch_no'] as String?,
        expiryDate: m['expiry_date'] as String?,
        purchasePrice: (m['purchase_price'] as num?)?.toDouble() ?? 0,
        salePrice: (m['sale_price'] as num?)?.toDouble() ?? 0,
        quantity: (m['quantity'] as num?)?.toInt() ?? 0,
        minQuantity: (m['min_quantity'] as num?)?.toInt() ?? 10,
        unit: m['unit'] as String? ?? 'unit',
        supplierId: m['supplier_id'] as String?,
        activeIngredient: m['active_ingredient'] as String?,
        alternatives: m['alternatives'] as String?,
        location: m['location'] as String?,
        notes: m['notes'] as String?,
        createdAt: m['created_at'] as String?,
        updatedAt: m['updated_at'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'scientific_name': scientificName,
        'category': category,
        'barcode': barcode,
        'batch_no': batchNo,
        'expiry_date': expiryDate,
        'purchase_price': purchasePrice,
        'sale_price': salePrice,
        'quantity': quantity,
        'min_quantity': minQuantity,
        'unit': unit,
        'supplier_id': supplierId,
        'active_ingredient': activeIngredient,
        'alternatives': alternatives,
        'location': location,
        'notes': notes,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };

  Medicine copyWith({
    String? name, String? scientificName, String? category, String? barcode,
    String? batchNo, String? expiryDate, double? purchasePrice, double? salePrice,
    int? quantity, int? minQuantity, String? unit, String? supplierId,
    String? activeIngredient, String? alternatives, String? location, String? notes,
  }) =>
      Medicine(
        id: id,
        name: name ?? this.name,
        scientificName: scientificName ?? this.scientificName,
        category: category ?? this.category,
        barcode: barcode ?? this.barcode,
        batchNo: batchNo ?? this.batchNo,
        expiryDate: expiryDate ?? this.expiryDate,
        purchasePrice: purchasePrice ?? this.purchasePrice,
        salePrice: salePrice ?? this.salePrice,
        quantity: quantity ?? this.quantity,
        minQuantity: minQuantity ?? this.minQuantity,
        unit: unit ?? this.unit,
        supplierId: supplierId ?? this.supplierId,
        activeIngredient: activeIngredient ?? this.activeIngredient,
        alternatives: alternatives ?? this.alternatives,
        location: location ?? this.location,
        notes: notes ?? this.notes,
        createdAt: createdAt,
        updatedAt: DateTime.now().toIso8601String(),
      );

  bool get isLowStock => quantity <= minQuantity;
  bool get isExpired {
    if (expiryDate == null) return false;
    return DateTime.tryParse(expiryDate!)?.isBefore(DateTime.now()) ?? false;
  }
  bool get isNearExpiry {
    if (expiryDate == null) return false;
    final d = DateTime.tryParse(expiryDate!);
    if (d == null) return false;
    return !isExpired && d.difference(DateTime.now()).inDays <= 30;
  }
}
