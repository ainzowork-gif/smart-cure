import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/database/database_helper.dart';
import '../core/utils/helpers.dart';
import '../models/purchase.dart';
import 'inventory_provider.dart';

final purchasesProvider = AsyncNotifierProvider<PurchasesNotifier, List<Purchase>>(PurchasesNotifier.new);

class PurchasesNotifier extends AsyncNotifier<List<Purchase>> {
  final _db = DatabaseHelper();

  @override
  Future<List<Purchase>> build() => _load();

  Future<List<Purchase>> _load() async {
    final rows = await _db.query('purchases', orderBy: 'created_at DESC');
    return rows.map(Purchase.fromMap).toList();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<String> createPurchase({
    required String supplierName,
    String? supplierId,
    required List<PurchaseItem> items,
    String? dueDate,
    String? notes,
  }) async {
    final count = state.valueOrNull?.length ?? 0;
    final id = generateId();
    final poNo = generatePoNo(count);
    final total = items.fold<double>(0, (s, i) => s + i.total);

    final purchase = Purchase(
      id: id,
      poNo: poNo,
      supplierId: supplierId,
      supplierName: supplierName,
      total: total,
      paid: 0,
      status: 'pending',
      dueDate: dueDate,
      notes: notes,
      createdAt: nowIso(),
    );

    await _db.insert('purchases', purchase.toMap());

    for (final item in items) {
      final pItem = PurchaseItem(
        id: generateId(),
        purchaseId: id,
        medicineId: item.medicineId,
        medicineName: item.medicineName,
        batchNo: item.batchNo,
        expiryDate: item.expiryDate,
        quantity: item.quantity,
        unitCost: item.unitCost,
      );
      await _db.insert('purchase_items', pItem.toMap());
    }

    await refresh();
    return poNo;
  }

  Future<void> receivePurchase(String id) async {
    final rows = await _db.query('purchase_items', where: 'purchase_id = ?', whereArgs: [id]);
    final items = rows.map(PurchaseItem.fromMap).toList();
    for (final item in items) {
      await ref.read(inventoryProvider.notifier).adjustStock(item.medicineId, item.quantity);
    }
    await _db.update('purchases', {'status': 'received', 'paid': (await _db.query('purchases', where: 'id = ?', whereArgs: [id])).first['total']}, 'id = ?', [id]);
    await refresh();
  }

  Future<List<PurchaseItem>> getItems(String purchaseId) async {
    final rows = await _db.query('purchase_items', where: 'purchase_id = ?', whereArgs: [purchaseId]);
    return rows.map(PurchaseItem.fromMap).toList();
  }
}
