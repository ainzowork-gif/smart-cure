import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_theme.dart';
import '../core/utils/helpers.dart';
import '../models/medicine.dart';
import '../models/purchase.dart';
import '../providers/inventory_provider.dart';
import '../providers/purchases_provider.dart';
import '../providers/suppliers_provider.dart';
import '../widgets/shared/sc_badge.dart';
import '../widgets/shared/sc_button.dart';
import '../widgets/shared/sc_panel.dart';
import '../widgets/shared/sc_text_field.dart';
import '../widgets/shared/topbar.dart';

final _poStatusFilterProvider = StateProvider<String>((ref) => 'All');

class PurchasesScreen extends ConsumerWidget {
  const PurchasesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final purchasesAsync = ref.watch(purchasesProvider);
    final statusFilter = ref.watch(_poStatusFilterProvider);

    var purchases = purchasesAsync.valueOrNull ?? [];
    if (statusFilter != 'All') {
      purchases = purchases.where((p) => p.status == statusFilter.toLowerCase()).toList();
    }

    final total = purchases.fold<double>(0, (s, p) => s + p.total);
    final pending = (purchasesAsync.valueOrNull ?? []).where((p) => p.status == 'pending').length;
    final received = (purchasesAsync.valueOrNull ?? []).where((p) => p.status == 'received').length;

    return Column(
      children: [
        Topbar(
          title: 'Purchases',
          breadcrumb: 'Home › Purchases',
          actions: [ScButton('New Purchase Order', onTap: () => _showNewPoDialog(context, ref), variant: BtnVariant.success)],
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Row(children: [
                  _StatCard('Total Orders', '${purchasesAsync.valueOrNull?.length ?? 0}', AppColors.blue600),
                  const SizedBox(width: 14),
                  _StatCard('Total Value', formatCurrency(total), AppColors.green600),
                  const SizedBox(width: 14),
                  _StatCard('Pending', '$pending', AppColors.amber500),
                  const SizedBox(width: 14),
                  _StatCard('Received', '$received', AppColors.green600),
                ]),
                const SizedBox(height: 16),
                _FilterRow(ref: ref, current: statusFilter),
                const SizedBox(height: 16),
                ScPanel(
                  title: 'Purchase Orders (${purchases.length})',
                  icon: const Text('📦', style: TextStyle(fontSize: 14)),
                  body: purchases.isEmpty
                      ? const Padding(padding: EdgeInsets.all(32), child: Center(child: Text('No purchase orders found')))
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowHeight: 34,
                            dataRowMinHeight: 40,
                            dataRowMaxHeight: 40,
                            horizontalMargin: 14,
                            columnSpacing: 14,
                            headingRowColor: WidgetStateProperty.all(AppColors.gray50),
                            border: const TableBorder(
                              horizontalInside: BorderSide(color: AppColors.gray100),
                              top: BorderSide(color: AppColors.gray200),
                            ),
                            columns: const [
                              DataColumn(label: Text('PO #')),
                              DataColumn(label: Text('Supplier')),
                              DataColumn(label: Text('Total'), numeric: true),
                              DataColumn(label: Text('Paid'), numeric: true),
                              DataColumn(label: Text('Balance'), numeric: true),
                              DataColumn(label: Text('Status')),
                              DataColumn(label: Text('Date')),
                              DataColumn(label: Text('Actions')),
                            ],
                            rows: purchases.map((p) {
                              BadgeType bt;
                              switch (p.status) {
                                case 'received': bt = BadgeType.success; break;
                                case 'pending': bt = BadgeType.warning; break;
                                case 'cancelled': bt = BadgeType.danger; break;
                                default: bt = BadgeType.info;
                              }
                              return DataRow(cells: [
                                DataCell(Text('#${p.poNo}', style: AppTheme.mono(size: 12, color: AppColors.blue800, weight: FontWeight.w600))),
                                DataCell(Text(p.supplierName, style: AppTheme.sans(size: 12, weight: FontWeight.w600))),
                                DataCell(Text(formatCurrency(p.total), style: AppTheme.mono(size: 12))),
                                DataCell(Text(formatCurrency(p.paid), style: AppTheme.mono(size: 12, color: AppColors.green700))),
                                DataCell(Text(formatCurrency(p.balance), style: AppTheme.mono(size: 12, color: p.balance > 0 ? AppColors.red500 : AppColors.gray500))),
                                DataCell(ScBadge(p.status, type: bt)),
                                DataCell(Text(p.createdAt != null ? formatDateTime(p.createdAt!) : '—', style: AppTheme.mono(size: 11))),
                                DataCell(p.status == 'pending'
                                    ? ScButton('Receive', small: true, variant: BtnVariant.success,
                                        onTap: () async {
                                          await ref.read(purchasesProvider.notifier).receivePurchase(p.id);
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                              content: Text('Purchase received & stock updated'),
                                              backgroundColor: AppColors.green600,
                                            ));
                                          }
                                        })
                                    : const Text('—', style: TextStyle(color: AppColors.gray400))),
                              ]);
                            }).toList(),
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

  void _showNewPoDialog(BuildContext context, WidgetRef ref) {
    showDialog(context: context, builder: (_) => _NewPoDialog(ref: ref));
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
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.borderColor),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: AppTheme.sans(size: 11.5, color: AppColors.gray500)),
          const SizedBox(height: 4),
          Text(value, style: AppTheme.mono(size: 18, weight: FontWeight.w700, color: color)),
        ]),
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  final WidgetRef ref;
  final String current;
  const _FilterRow({required this.ref, required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: ['All', 'Pending', 'Received', 'Cancelled'].map((s) {
        final active = current == s;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => ref.read(_poStatusFilterProvider.notifier).state = s,
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
    );
  }
}

// ── New PO Dialog ─────────────────────────────────────────────────────────────

class _NewPoDialog extends ConsumerStatefulWidget {
  final WidgetRef ref;
  const _NewPoDialog({required this.ref});

  @override
  ConsumerState<_NewPoDialog> createState() => _NewPoDialogState();
}

class _NewPoDialogState extends ConsumerState<_NewPoDialog> {
  final _supplierCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  bool _loading = false;
  final List<_PoItem> _cart = [];

  double get _total => _cart.fold(0, (s, i) => s + i.qty * i.cost);

  @override
  Widget build(BuildContext context) {
    final meds = (widget.ref.watch(inventoryProvider).valueOrNull ?? []).where((m) {
      final q = _searchCtrl.text.toLowerCase();
      return q.isEmpty || m.name.toLowerCase().contains(q);
    }).toList();

    final suppliers = widget.ref.watch(suppliersProvider).valueOrNull ?? [];

    return AlertDialog(
      title: Text('New Purchase Order', style: AppTheme.sans(size: 15, weight: FontWeight.w700)),
      content: SizedBox(
        width: 700,
        height: 500,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  ScTextField(hint: 'Search medicine…', controller: _searchCtrl, onChanged: (_) => setState(() {})),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: meds.length,
                      itemBuilder: (_, i) {
                        final m = meds[i];
                        return ListTile(
                          dense: true,
                          title: Text(m.name, style: AppTheme.sans(size: 12, weight: FontWeight.w600)),
                          subtitle: Text('Cost: ${formatCurrency(m.purchasePrice)} · Stock: ${m.quantity}', style: AppTheme.mono(size: 11)),
                          trailing: IconButton(
                            icon: const Icon(Icons.add_circle_outline, color: AppColors.green600),
                            onPressed: () => setState(() {
                              final idx = _cart.indexWhere((c) => c.medicineId == m.id);
                              if (idx >= 0) {
                                _cart[idx].qty++;
                              } else {
                                _cart.add(_PoItem(medicineId: m.id, name: m.name, cost: m.purchasePrice));
                              }
                            }),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 280,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Autocomplete<String>(
                    optionsBuilder: (v) => suppliers.map((s) => s.name).where((n) => n.toLowerCase().contains(v.text.toLowerCase())),
                    onSelected: (v) => _supplierCtrl.text = v,
                    fieldViewBuilder: (ctx, ctrl, fn, _) {
                      _supplierCtrl.text = ctrl.text;
                      return ScTextField(label: 'Supplier', controller: ctrl, focusNode: fn);
                    },
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: _cart.isEmpty
                        ? const Center(child: Text('Add items', style: TextStyle(color: AppColors.gray400)))
                        : ListView.builder(
                            itemCount: _cart.length,
                            itemBuilder: (_, i) {
                              final item = _cart[i];
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  children: [
                                    Expanded(child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(item.name, style: AppTheme.sans(size: 12, weight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                                        Text(formatCurrency(item.cost * item.qty), style: AppTheme.mono(size: 11)),
                                      ],
                                    )),
                                    Row(mainAxisSize: MainAxisSize.min, children: [
                                      IconButton(icon: const Icon(Icons.remove, size: 14), padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                                        onPressed: () => setState(() { item.qty = (item.qty - 1).clamp(1, 9999); })),
                                      Text('${item.qty}', style: AppTheme.mono(size: 12)),
                                      IconButton(icon: const Icon(Icons.add, size: 14), padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                                        onPressed: () => setState(() { item.qty++; })),
                                      IconButton(icon: const Icon(Icons.close, size: 14, color: AppColors.red500), padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                                        onPressed: () => setState(() { _cart.removeAt(i); })),
                                    ]),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                  const Divider(),
                  ScTextField(label: 'Notes', controller: _notesCtrl),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: AppColors.gray50, borderRadius: BorderRadius.circular(6), border: Border.all(color: AppColors.gray200)),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('Total', style: AppTheme.sans(size: 13, weight: FontWeight.w700)),
                      Text(formatCurrency(_total), style: AppTheme.mono(size: 16, weight: FontWeight.w700, color: AppColors.blue800)),
                    ]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: _loading || _cart.isEmpty ? null : () async {
            setState(() => _loading = true);
            try {
              final items = _cart.map((c) => PurchaseItem(
                id: generateId(), purchaseId: '', medicineId: c.medicineId,
                medicineName: c.name, quantity: c.qty, unitCost: c.cost,
              )).toList();
              final poNo = await ref.read(purchasesProvider.notifier).createPurchase(
                supplierName: _supplierCtrl.text.trim().isEmpty ? 'Unknown Supplier' : _supplierCtrl.text.trim(),
                items: items,
                notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
              );
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('PO $poNo created successfully'),
                  backgroundColor: AppColors.green600,
                ));
              }
            } finally {
              if (mounted) setState(() => _loading = false);
            }
          },
          child: _loading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Create PO'),
        ),
      ],
    );
  }
}

class _PoItem {
  final String medicineId, name;
  double cost;
  int qty;
  _PoItem({required this.medicineId, required this.name, required this.cost, this.qty = 1});
}
