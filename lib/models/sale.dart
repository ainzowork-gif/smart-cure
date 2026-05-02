class SaleItem {
  final String id;
  final String saleId;
  final String medicineId;
  final String medicineName;
  final String? batchNo;
  final String? expiryDate;
  int quantity;
  final double unitPrice;
  final double discount;
  double get total => (unitPrice * quantity) - discount;

  SaleItem({
    required this.id,
    required this.saleId,
    required this.medicineId,
    required this.medicineName,
    this.batchNo,
    this.expiryDate,
    required this.quantity,
    required this.unitPrice,
    this.discount = 0,
  });

  factory SaleItem.fromMap(Map<String, dynamic> m) => SaleItem(
        id: m['id'] as String,
        saleId: m['sale_id'] as String,
        medicineId: m['medicine_id'] as String,
        medicineName: m['medicine_name'] as String? ?? '',
        batchNo: m['batch_no'] as String?,
        expiryDate: m['expiry_date'] as String?,
        quantity: (m['quantity'] as num?)?.toInt() ?? 1,
        unitPrice: (m['unit_price'] as num?)?.toDouble() ?? 0,
        discount: (m['discount'] as num?)?.toDouble() ?? 0,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'sale_id': saleId,
        'medicine_id': medicineId,
        'medicine_name': medicineName,
        'batch_no': batchNo,
        'expiry_date': expiryDate,
        'quantity': quantity,
        'unit_price': unitPrice,
        'discount': discount,
        'total': total,
      };
}

class Sale {
  final String id;
  final String invoiceNo;
  final String? customerId;
  final String customerName;
  final double total;
  final double discount;
  final double tax;
  final double paid;
  final String status; // paid, pending, returned, insurance
  final String paymentMethod; // cash, card, credit, insurance
  final String? notes;
  final String? employeeId;
  final String? createdAt;
  List<SaleItem> items;

  Sale({
    required this.id,
    required this.invoiceNo,
    this.customerId,
    required this.customerName,
    required this.total,
    this.discount = 0,
    this.tax = 0,
    required this.paid,
    this.status = 'paid',
    this.paymentMethod = 'cash',
    this.notes,
    this.employeeId,
    this.createdAt,
    this.items = const [],
  });

  factory Sale.fromMap(Map<String, dynamic> m) => Sale(
        id: m['id'] as String,
        invoiceNo: m['invoice_no'] as String,
        customerId: m['customer_id'] as String?,
        customerName: m['customer_name'] as String? ?? 'Walk-in',
        total: (m['total'] as num?)?.toDouble() ?? 0,
        discount: (m['discount'] as num?)?.toDouble() ?? 0,
        tax: (m['tax'] as num?)?.toDouble() ?? 0,
        paid: (m['paid'] as num?)?.toDouble() ?? 0,
        status: m['status'] as String? ?? 'paid',
        paymentMethod: m['payment_method'] as String? ?? 'cash',
        notes: m['notes'] as String?,
        employeeId: m['employee_id'] as String?,
        createdAt: m['created_at'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'invoice_no': invoiceNo,
        'customer_id': customerId,
        'customer_name': customerName,
        'total': total,
        'discount': discount,
        'tax': tax,
        'paid': paid,
        'status': status,
        'payment_method': paymentMethod,
        'notes': notes,
        'employee_id': employeeId,
        'created_at': createdAt,
      };

  double get balance => total - paid;
}
