import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_theme.dart';
import '../core/utils/helpers.dart';
import '../models/treasury.dart';
import '../providers/treasury_provider.dart';
import '../widgets/shared/sc_badge.dart';
import '../widgets/shared/sc_button.dart';
import '../widgets/shared/sc_panel.dart';
import '../widgets/shared/sc_text_field.dart';
import '../widgets/shared/topbar.dart';

final _txTypeFilterProvider = StateProvider<String>((ref) => 'All');

class TreasuryScreen extends ConsumerWidget {
  const TreasuryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txAsync = ref.watch(treasuryProvider);
    final typeFilter = ref.watch(_txTypeFilterProvider);

    var txList = txAsync.valueOrNull ?? [];
    if (typeFilter != 'All') {
      txList = txList.where((t) => t.type == typeFilter.toLowerCase()).toList();
    }

    final all = txAsync.valueOrNull ?? [];
    final totalIncome = all.where((t) => t.isIncome).fold<double>(0, (s, t) => s + t.amount);
    final totalExpense = all.where((t) => !t.isIncome).fold<double>(0, (s, t) => s + t.amount);
    final balance = totalIncome - totalExpense;

    return Column(
      children: [
        Topbar(
          title: 'Treasury',
          breadcrumb: 'Home › Treasury',
          actions: [
            ScButton('Add Income', onTap: () => _showDialog(context, ref, 'income'), variant: BtnVariant.success),
            const SizedBox(width: 8),
            ScButton('Add Expense', onTap: () => _showDialog(context, ref, 'expense'), variant: BtnVariant.danger),
          ],
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Row(children: [
                  _StatCard('Current Balance', formatCurrency(balance), balance >= 0 ? AppColors.green600 : AppColors.red500),
                  const SizedBox(width: 14),
                  _StatCard('Total Income', formatCurrency(totalIncome), AppColors.green600),
                  const SizedBox(width: 14),
                  _StatCard('Total Expense', formatCurrency(totalExpense), AppColors.red500),
                  const SizedBox(width: 14),
                  _StatCard('Transactions', '${all.length}', AppColors.blue600),
                ]),
                const SizedBox(height: 16),
                Row(
                  children: ['All', 'Income', 'Expense'].map((s) {
                    final active = typeFilter == s;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => ref.read(_txTypeFilterProvider.notifier).state = s,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: active ? AppColors.blue600 : AppColors.white,
                            border: Border.all(color: active ? AppColors.blue600 : AppColors.gray200),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(s, style: AppTheme.sans(size: 12, weight: FontWeight.w600, color: active ? AppColors.white : AppColors.gray600)),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                ScPanel(
                  title: 'Transactions (${txList.length})',
                  icon: const Text('💰', style: TextStyle(fontSize: 14)),
                  body: txList.isEmpty
                      ? const Padding(padding: EdgeInsets.all(32), child: Center(child: Text('No transactions found')))
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowHeight: 34,
                            dataRowMinHeight: 44,
                            dataRowMaxHeight: 44,
                            horizontalMargin: 14,
                            columnSpacing: 16,
                            headingRowColor: WidgetStateProperty.all(AppColors.gray50),
                            border: const TableBorder(
                              horizontalInside: BorderSide(color: AppColors.gray100),
                              top: BorderSide(color: AppColors.gray200),
                            ),
                            columns: const [
                              DataColumn(label: Text('Type')),
                              DataColumn(label: Text('Category')),
                              DataColumn(label: Text('Description')),
                              DataColumn(label: Text('Amount'), numeric: true),
                              DataColumn(label: Text('Balance After'), numeric: true),
                              DataColumn(label: Text('Date')),
                            ],
                            rows: txList.map((t) => DataRow(cells: [
                              DataCell(ScBadge(t.isIncome ? 'Income' : 'Expense',
                                type: t.isIncome ? BadgeType.success : BadgeType.danger)),
                              DataCell(Text(t.category ?? '—', style: AppTheme.sans(size: 12))),
                              DataCell(Text(t.description, style: AppTheme.sans(size: 12))),
                              DataCell(Text(
                                '${t.isIncome ? '+' : '-'}${formatCurrency(t.amount)}',
                                style: AppTheme.mono(size: 12, weight: FontWeight.w600,
                                  color: t.isIncome ? AppColors.green600 : AppColors.red500),
                              )),
                              DataCell(Text(
                                t.balanceAfter != null ? formatCurrency(t.balanceAfter!) : '—',
                                style: AppTheme.mono(size: 12),
                              )),
                              DataCell(Text(t.createdAt != null ? formatDateTime(t.createdAt!) : '—', style: AppTheme.mono(size: 11))),
                            ])).toList(),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showDialog(BuildContext context, WidgetRef ref, String type) {
    showDialog(context: context, builder: (_) => _TxDialog(ref: ref, type: type));
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatCard(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.white, border: Border.all(color: AppColors.borderColor), borderRadius: BorderRadius.circular(10)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: AppTheme.sans(size: 11.5, color: AppColors.gray500)),
          const SizedBox(height: 4),
          Text(value, style: AppTheme.mono(size: 18, weight: FontWeight.w700, color: color)),
        ]),
      ),
    );
  }
}

// ── Transaction Dialog ────────────────────────────────────────────────────────

class _TxDialog extends ConsumerStatefulWidget {
  final WidgetRef ref;
  final String type;
  const _TxDialog({required this.ref, required this.type});

  @override
  ConsumerState<_TxDialog> createState() => _TxDialogState();
}

class _TxDialogState extends ConsumerState<_TxDialog> {
  final _descCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final isIncome = widget.type == 'income';
    return AlertDialog(
      title: Text('Add ${isIncome ? 'Income' : 'Expense'}', style: AppTheme.sans(size: 15, weight: FontWeight.w700)),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScTextField(label: 'Description *', controller: _descCtrl),
            const SizedBox(height: 10),
            ScTextField(label: 'Category (e.g. Sales, Rent)', controller: _categoryCtrl),
            const SizedBox(height: 10),
            ScTextField(label: 'Amount *', controller: _amountCtrl, keyboardType: TextInputType.number),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isIncome ? AppColors.green600 : AppColors.red500,
          ),
          onPressed: _loading || _descCtrl.text.trim().isEmpty || _amountCtrl.text.trim().isEmpty ? null : () async {
            setState(() => _loading = true);
            try {
              final amount = double.tryParse(_amountCtrl.text) ?? 0;
              if (amount <= 0) return;

              final allTx = widget.ref.read(treasuryProvider).valueOrNull ?? [];
              final lastBalance = allTx.isNotEmpty ? (allTx.last.balanceAfter ?? 0) : 0.0;
              final newBalance = isIncome ? lastBalance + amount : lastBalance - amount;

              final tx = TreasuryTransaction(
                id: generateId(),
                type: widget.type,
                category: _categoryCtrl.text.trim().isEmpty ? null : _categoryCtrl.text.trim(),
                description: _descCtrl.text.trim(),
                amount: amount,
                balanceAfter: newBalance,
                createdAt: nowIso(),
              );
              await ref.read(treasuryProvider.notifier).add(tx);
              if (mounted) Navigator.pop(context);
            } finally {
              if (mounted) setState(() => _loading = false);
            }
          },
          child: _loading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Save'),
        ),
      ],
    );
  }
}
