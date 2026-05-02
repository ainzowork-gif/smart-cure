import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/database/database_helper.dart';
import '../core/utils/helpers.dart';
import '../models/customer.dart';

final customersProvider = AsyncNotifierProvider<CustomersNotifier, List<Customer>>(CustomersNotifier.new);

class CustomersNotifier extends AsyncNotifier<List<Customer>> {
  final _db = DatabaseHelper();

  @override
  Future<List<Customer>> build() => _load();

  Future<List<Customer>> _load() async {
    final rows = await _db.query('customers', orderBy: 'name ASC');
    return rows.map(Customer.fromMap).toList();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<void> add(Customer c) async {
    await _db.insert('customers', c.toMap());
    await refresh();
  }

  Future<void> save(Customer c) async {
    await _db.update('customers', c.toMap(), 'id = ?', [c.id]);
    await refresh();
  }

  Future<void> delete(String id) async {
    await _db.delete('customers', 'id = ?', [id]);
    await refresh();
  }

  Customer newEmpty() => Customer(id: generateId(), name: '', createdAt: nowIso());
}
