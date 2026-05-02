import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/database/database_helper.dart';
import '../core/utils/helpers.dart';
import '../models/supplier.dart';

final suppliersProvider = AsyncNotifierProvider<SuppliersNotifier, List<Supplier>>(SuppliersNotifier.new);

class SuppliersNotifier extends AsyncNotifier<List<Supplier>> {
  final _db = DatabaseHelper();

  @override
  Future<List<Supplier>> build() => _load();

  Future<List<Supplier>> _load() async {
    final rows = await _db.query('suppliers', orderBy: 'name ASC');
    return rows.map(Supplier.fromMap).toList();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<void> add(Supplier s) async {
    await _db.insert('suppliers', s.toMap());
    await refresh();
  }

  Future<void> save(Supplier s) async {
    await _db.update('suppliers', s.toMap(), 'id = ?', [s.id]);
    await refresh();
  }

  Future<void> delete(String id) async {
    await _db.delete('suppliers', 'id = ?', [id]);
    await refresh();
  }

  Supplier newEmpty() => Supplier(id: generateId(), name: '', createdAt: nowIso());
}
