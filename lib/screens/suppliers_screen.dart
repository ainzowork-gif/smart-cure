import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_theme.dart';
import '../core/utils/helpers.dart';
import '../models/supplier.dart';
import '../providers/suppliers_provider.dart';
import '../widgets/shared/sc_badge.dart';
import '../widgets/shared/sc_button.dart';
import '../widgets/shared/sc_panel.dart';
import '../widgets/shared/sc_text_field.dart';
import '../widgets/shared/topbar.dart';

class SuppliersScreen extends ConsumerStatefulWidget {
  const SuppliersScreen({super.key});

  @override
  ConsumerState<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends ConsumerState<SuppliersScreen> {
  final _search = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(suppliersProvider).valueOrNull ?? [];
    final q = _search.text.toLowerCase();
    final filtered = q.isEmpty ? all : all.where((s) =>
      s.name.toLowerCase().contains(q) || (s.contactPerson?.toLowerCase().contains(q) ?? false) || (s.phone?.contains(q) ?? false)
    ).toList();

    final totalBalance = all.fold<double>(0, (s, sup) => s + sup.balance);

    return Column(
      children: [
        Topbar(
          title: 'Suppliers',
          breadcrumb: 'Home › Suppliers',
          actions: [ScButton('Add Supplier', onTap: () => _showDialog(context), variant: BtnVariant.success)],
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Row(children: [
                  _StatCard('Total Suppliers', '${all.length}', AppColors.blue600),
                  const SizedBox(width: 14),
                  _StatCard('Outstanding Balance', formatCurrency(totalBalance), AppColors.red500),
                  const SizedBox(width: 14),
                  _StatCard('Active', '${all.length}', AppColors.green600),
                ]),
                const SizedBox(height: 16),
                ScPanel(
                  title: 'Suppliers (${filtered.length})',
                  icon: const Text('🏭', style: TextStyle(fontSize: 14)),
                  actions: [
                    SizedBox(
                      width: 220,
                      child: TextField(
                        controller: _search,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Search suppliers…',
                          hintStyle: AppTheme.sans(size: 12, color: AppColors.gray400),
                          prefixIcon: const Icon(Icons.search, size: 16, color: AppColors.gray400),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 8),
                          filled: true,
                          fillColor: AppColors.gray50,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppColors.gray200)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppColors.gray200)),
                        ),
                      ),
                    ),
                  ],
                  body: filtered.isEmpty
                      ? const Padding(padding: EdgeInsets.all(32), child: Center(child: Text('No suppliers found')))
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
                              DataColumn(label: Text('Company')),
                              DataColumn(label: Text('Contact')),
                              DataColumn(label: Text('Phone')),
                              DataColumn(label: Text('Email')),
                              DataColumn(label: Text('Balance'), numeric: true),
                              DataColumn(label: Text('Status')),
                              DataColumn(label: Text('Actions')),
                            ],
                            rows: filtered.map((s) => DataRow(cells: [
                              DataCell(Text(s.name, style: AppTheme.sans(size: 12, weight: FontWeight.w600))),
                              DataCell(Text(s.contactPerson ?? '—', style: AppTheme.sans(size: 12))),
                              DataCell(Text(s.phone ?? '—', style: AppTheme.mono(size: 12))),
                              DataCell(Text(s.email ?? '—', style: AppTheme.sans(size: 12))),
                              DataCell(Text(formatCurrency(s.balance),
                                style: AppTheme.mono(size: 12, color: s.balance > 0 ? AppColors.red500 : AppColors.green700, weight: FontWeight.w600))),
                              DataCell(ScBadge(s.balance > 0 ? 'Owed' : 'Clear', type: s.balance > 0 ? BadgeType.warning : BadgeType.success)),
                              DataCell(Row(mainAxisSize: MainAxisSize.min, children: [
                                ScButton('Edit', small: true, onTap: () => _showDialog(context, supplier: s)),
                                const SizedBox(width: 6),
                                ScButton('Delete', small: true, variant: BtnVariant.danger, onTap: () => _delete(context, s.id)),
                              ])),
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

  void _showDialog(BuildContext context, {Supplier? supplier}) {
    showDialog(context: context, builder: (_) => _SupplierDialog(supplier: supplier));
  }

  Future<void> _delete(BuildContext context, String id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Supplier'),
        content: const Text('Are you sure you want to delete this supplier?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.red500), onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(suppliersProvider.notifier).delete(id);
    }
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

// ── Supplier Dialog ───────────────────────────────────────────────────────────

class _SupplierDialog extends ConsumerStatefulWidget {
  final Supplier? supplier;
  const _SupplierDialog({this.supplier});

  @override
  ConsumerState<_SupplierDialog> createState() => _SupplierDialogState();
}

class _SupplierDialogState extends ConsumerState<_SupplierDialog> {
  late final _nameCtrl = TextEditingController(text: widget.supplier?.name ?? '');
  late final _contactCtrl = TextEditingController(text: widget.supplier?.contactPerson ?? '');
  late final _phoneCtrl = TextEditingController(text: widget.supplier?.phone ?? '');
  late final _emailCtrl = TextEditingController(text: widget.supplier?.email ?? '');
  late final _addressCtrl = TextEditingController(text: widget.supplier?.address ?? '');
  late final _balanceCtrl = TextEditingController(text: widget.supplier?.balance.toString() ?? '0');
  late final _notesCtrl = TextEditingController(text: widget.supplier?.notes ?? '');
  bool _loading = false;

  bool get _isEdit => widget.supplier != null;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEdit ? 'Edit Supplier' : 'Add Supplier', style: AppTheme.sans(size: 15, weight: FontWeight.w700)),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScTextField(label: 'Company Name *', controller: _nameCtrl),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: ScTextField(label: 'Contact Person', controller: _contactCtrl)),
              const SizedBox(width: 10),
              Expanded(child: ScTextField(label: 'Phone', controller: _phoneCtrl)),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: ScTextField(label: 'Email', controller: _emailCtrl)),
              const SizedBox(width: 10),
              Expanded(child: ScTextField(label: 'Balance Owed', controller: _balanceCtrl, keyboardType: TextInputType.number)),
            ]),
            const SizedBox(height: 10),
            ScTextField(label: 'Address', controller: _addressCtrl),
            const SizedBox(height: 10),
            ScTextField(label: 'Notes', controller: _notesCtrl),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: _loading || _nameCtrl.text.trim().isEmpty ? null : () async {
            setState(() => _loading = true);
            try {
              final s = Supplier(
                id: widget.supplier?.id ?? generateId(),
                name: _nameCtrl.text.trim(),
                contactPerson: _contactCtrl.text.trim().isEmpty ? null : _contactCtrl.text.trim(),
                phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
                email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
                address: _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
                balance: double.tryParse(_balanceCtrl.text) ?? 0,
                notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
                createdAt: widget.supplier?.createdAt ?? nowIso(),
              );
              if (_isEdit) {
                await ref.read(suppliersProvider.notifier).save(s);
              } else {
                await ref.read(suppliersProvider.notifier).add(s);
              }
              if (mounted) Navigator.pop(context);
            } finally {
              if (mounted) setState(() => _loading = false);
            }
          },
          child: _loading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : Text(_isEdit ? 'Update' : 'Add Supplier'),
        ),
      ],
    );
  }
}
