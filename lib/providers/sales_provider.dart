import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/database/database_helper.dart';
import '../core/utils/helpers.dart';
import '../models/sale.dart';
import 'inventory_provider.dart';

final salesProvider = AsyncNotifierProvider<SalesNotifier, List<Sale>>(SalesNotifier.new);

class SalesNotifier extends AsyncNotifier<List<Sale>> {
  final _db = DatabaseHelper();

  @override
  Future<List<Sale>> build() => _load();

  Future<List<Sale>> _load() async {
    final rows = await _db.query('sales', orderBy: 'created_at DESC');
    return rows.map(Sale.fromMap).toList();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<String> createSale({
    required String customerName,
    String? customerId,
    required List<SaleItem> items,
    required double discount,
    required String paymentMethod,
    String? notes,
  }) async {
    final count = state.valueOrNull?.length ?? 0;
    final id = generateId();
    final invoiceNo = generateInvoiceNo(count);
    final subtotal = items.fold<double>(0, (s, i) => s + i.total);
    final total = subtotal - discount;
    final paid = paymentMethod == 'credit' ? 0.0 : total;

    final sale = Sale(
      id: id,
      invoiceNo: invoiceNo,
      customerId: customerId,
      customerName: customerName,
      total: total,
      discount: discount,
      paid: paid,
      status: paymentMethod == 'credit' ? 'pending' : 'paid',
      paymentMethod: paymentMethod,
      notes: notes,
      createdAt: nowIso(),
    );

    await _db.insert('sales', sale.toMap());

    for (final item in items) {
      final sItem = SaleItem(
        id: generateId(),
        saleId: id,
        medicineId: item.medicineId,
        medicineName: item.medicineName,
        batchNo: item.batchNo,
        expiryDate: item.expiryDate,
        quantity: item.quantity,
        unitPrice: item.unitPrice,
        discount: item.discount,
      );
      await _db.insert('sale_items', sItem.toMap());
      await ref.read(inventoryProvider.notifier).adjustStock(item.medicineId, -item.quantity);
    }

    // Treasury entry
    await _db.insert('treasury', {
      'id': generateId(),
      'type': 'income',
      'category': 'Sales',
      'description': 'Invoice $invoiceNo - $customerName',
      'amount': paid,
      'reference_id': id,
      'reference_type': 'sale',
      'created_at': nowIso(),
    });

    await refresh();
    return invoiceNo;
  }

  Future<List<SaleItem>> getItems(String saleId) async {
    final rows = await _db.query('sale_items', where: 'sale_id = ?', whereArgs: [saleId]);
    return rows.map(SaleItem.fromMap).toList();
  }

  Future<void> updateStatus(String id, String status) async {
    await _db.update('sales', {'status': status}, 'id = ?', [id]);
    await refresh();
  }

  List<Sale> todaySales() {
    final today = DateTime.now();
    return state.valueOrNull?.where((s) {
      if (s.createdAt == null) return false;
      final d = DateTime.tryParse(s.createdAt!);
      if (d == null) return false;
      return d.year == today.year && d.month == today.month && d.day == today.day;
    }).toList() ?? [];
  }

  double todayTotal() => todaySales().fold(0.0, (s, sale) => s + sale.paid);
}
