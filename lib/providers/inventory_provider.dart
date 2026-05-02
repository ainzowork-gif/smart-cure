import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/database/database_helper.dart';
import '../core/utils/helpers.dart';
import '../models/medicine.dart';
import 'app_provider.dart';

final inventoryProvider = AsyncNotifierProvider<InventoryNotifier, List<Medicine>>(InventoryNotifier.new);

class InventoryNotifier extends AsyncNotifier<List<Medicine>> {
  final _db = DatabaseHelper();

  @override
  Future<List<Medicine>> build() => _load();

  Future<List<Medicine>> _load() async {
    final rows = await _db.query('medicines', orderBy: 'name ASC');
    return rows.map(Medicine.fromMap).toList();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<void> add(Medicine m) async {
    await _db.insert('medicines', m.toMap());
    await refresh();
  }

  Future<void> save(Medicine m) async {
    await _db.update('medicines', m.toMap(), 'id = ?', [m.id]);
    await refresh();
  }

  Future<void> delete(String id) async {
    await _db.delete('medicines', 'id = ?', [id]);
    await refresh();
  }

  Future<void> adjustStock(String id, int delta) async {
    final rows = await _db.query('medicines', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return;
    final m = Medicine.fromMap(rows.first);
    final newQty = (m.quantity + delta).clamp(0, 999999);
    await _db.update('medicines', {'quantity': newQty, 'updated_at': nowIso()}, 'id = ?', [id]);
    await refresh();
  }

  List<Medicine> get lowStock => state.valueOrNull?.where((m) => m.isLowStock).toList() ?? [];
  List<Medicine> get expired => state.valueOrNull?.where((m) => m.isExpired).toList() ?? [];
  List<Medicine> get nearExpiry => state.valueOrNull?.where((m) => m.isNearExpiry).toList() ?? [];
}

final inventorySearchProvider = Provider<List<Medicine>>((ref) {
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final all = ref.watch(inventoryProvider).valueOrNull ?? [];
  if (query.isEmpty) return all;
  return all.where((m) =>
    m.name.toLowerCase().contains(query) ||
    (m.category?.toLowerCase().contains(query) ?? false) ||
    (m.barcode?.contains(query) ?? false) ||
    (m.batchNo?.toLowerCase().contains(query) ?? false)
  ).toList();
});

