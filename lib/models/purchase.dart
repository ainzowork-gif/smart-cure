class PurchaseItem {
  final String id;
  final String purchaseId;
  final String medicineId;
  final String medicineName;
  final String? batchNo;
  final String? expiryDate;
  int quantity;
  final double unitCost;
  double get total => unitCost * quantity;

  PurchaseItem({
    required this.id,
    required this.purchaseId,
    required this.medicineId,
    required this.medicineName,
    this.batchNo,
    this.expiryDate,
    required this.quantity,
    required this.unitCost,
  });

  factory PurchaseItem.fromMap(Map<String, dynamic> m) => PurchaseItem(
        id: m['id'] as String,
        purchaseId: m['purchase_id'] as String,
        medicineId: m['medicine_id'] as String,
        medicineName: m['medicine_name'] as String? ?? '',
        batchNo: m['batch_no'] as String?,
        expiryDate: m['expiry_date'] as String?,
        quantity: (m['quantity'] as num?)?.toInt() ?? 1,
        unitCost: (m['unit_cost'] as num?)?.toDouble() ?? 0,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'purchase_id': purchaseId,
        'medicine_id': medicineId,
        'medicine_name': medicineName,
        'batch_no': batchNo,
        'expiry_date': expiryDate,
        'quantity': quantity,
        'unit_cost': unitCost,
        'total': total,
      };
}

class Purchase {
  final String id;
  final String poNo;
  final String? supplierId;
  final String supplierName;
  final double total;
  final double paid;
  final String status; // pending, received, cancelled
  final String? dueDate;
  final String? notes;
  final String? employeeId;
  final String? createdAt;
  List<PurchaseItem> items;

  Purchase({
    required this.id,
    required this.poNo,
    this.supplierId,
    required this.supplierName,
    required this.total,
    this.paid = 0,
    this.status = 'received',
    this.dueDate,
    this.notes,
    this.employeeId,
    this.createdAt,
    this.items = const [],
  });

  factory Purchase.fromMap(Map<String, dynamic> m) => Purchase(
        id: m['id'] as String,
        poNo: m['po_no'] as String,
        supplierId: m['supplier_id'] as String?,
        supplierName: m['supplier_name'] as String? ?? '',
        total: (m['total'] as num?)?.toDouble() ?? 0,
        paid: (m['paid'] as num?)?.toDouble() ?? 0,
        status: m['status'] as String? ?? 'received',
        dueDate: m['due_date'] as String?,
        notes: m['notes'] as String?,
        employeeId: m['employee_id'] as String?,
        createdAt: m['created_at'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'po_no': poNo,
        'supplier_id': supplierId,
        'supplier_name': supplierName,
        'total': total,
        'paid': paid,
        'status': status,
        'due_date': dueDate,
        'notes': notes,
        'employee_id': employeeId,
        'created_at': createdAt,
      };

  double get balance => total - paid;
}
