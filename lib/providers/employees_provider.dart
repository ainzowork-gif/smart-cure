import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/database/database_helper.dart';
import '../core/utils/helpers.dart';
import '../models/employee.dart';

final employeesProvider = AsyncNotifierProvider<EmployeesNotifier, List<Employee>>(EmployeesNotifier.new);

class EmployeesNotifier extends AsyncNotifier<List<Employee>> {
  final _db = DatabaseHelper();

  @override
  Future<List<Employee>> build() => _load();

  Future<List<Employee>> _load() async {
    final rows = await _db.query('employees', orderBy: 'name ASC');
    return rows.map(Employee.fromMap).toList();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<void> add(Employee e) async {
    await _db.insert('employees', e.toMap());
    await refresh();
  }

  Future<void> save(Employee e) async {
    await _db.update('employees', e.toMap(), 'id = ?', [e.id]);
    await refresh();
  }

  Future<void> delete(String id) async {
    await _db.delete('employees', 'id = ?', [id]);
    await refresh();
  }
}
