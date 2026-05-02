import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/database/database_helper.dart';
import '../core/utils/helpers.dart';
import '../models/treasury.dart';

final treasuryProvider = AsyncNotifierProvider<TreasuryNotifier, List<TreasuryTransaction>>(TreasuryNotifier.new);

class TreasuryNotifier extends AsyncNotifier<List<TreasuryTransaction>> {
  final _db = DatabaseHelper();

  @override
  Future<List<TreasuryTransaction>> build() => _load();

  Future<List<TreasuryTransaction>> _load() async {
    final rows = await _db.query('treasury', orderBy: 'created_at DESC');
    return rows.map(TreasuryTransaction.fromMap).toList();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<void> add(TreasuryTransaction t) async {
    await _db.insert('treasury', t.toMap());
    await refresh();
  }

  double get totalBalance {
    final all = state.valueOrNull ?? [];
    double b = 0;
    for (final t in all) {
      b += t.isIncome ? t.amount : -t.amount;
    }
    return b;
  }

  double get totalIncome => state.valueOrNull?.where((t) => t.isIncome).fold<double>(0.0, (s, t) => s + t.amount) ?? 0;
  double get totalExpense => state.valueOrNull?.where((t) => !t.isIncome).fold<double>(0.0, (s, t) => s + t.amount) ?? 0;
}
