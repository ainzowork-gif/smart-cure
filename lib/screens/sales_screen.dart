import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_theme.dart';
import '../core/utils/helpers.dart';
import '../models/medicine.dart';
import '../models/sale.dart';
import '../providers/inventory_provider.dart';
import '../providers/sales_provider.dart';
import '../widgets/shared/sc_badge.dart';
import '../widgets/shared/sc_button.dart';
import '../widgets/shared/sc_panel.dart';
import '../widgets/shared/sc_text_field.dart';
import '../widgets/shared/topbar.dart';

final _saleStatusFilterProvider = StateProvider<String>((ref) => 'All');

class SalesScreen extends ConsumerWidget {
  const SalesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final salesAsync = ref.watch(salesProvider);
    final statusFilter = ref.watch(_saleStatusFilterProvider);

    var sales = salesAsync.valueOrNull ?? [];
    if (statusFilter != 'All') {
      sales = sales.where((s) => s.status == statusFilter.toLowerCase()).toList();
    }

    final todayTotal = ref.watch(salesProvider.notifier).todayTotal();
    final todaySales = ref.watch(salesProvider.notifier).todaySales();
    final pending = (salesAsync.valueOrNull ?? []).where((s) => s.status == 'pending').length;
    final returned = (salesAsync.valueOrNull ?? []).where((s) => s.status == 'returned').length;

    return Column(
      children: [
        Topbar(
          title: 'Sales',
          breadcrumb: 'Home › Sales',
          actions: [ScButton('New Invoice', onTap: () => _showNewInvoiceDialog(context, ref), variant: BtnVariant.success)],
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                // Stats
                Row(children: [
                  _StatCard("Today's Sales", formatCurrency(todayTotal), AppColors.blue600),
                  const SizedBox(width: 14),
                  _StatCard('Total Invoices', '${salesAsync.valueOrNull?.length ?? 0}', AppColors.green600),
                  const SizedBox(width: 14),
                  _StatCard('Pending', '$pending', AppColors.amber500),
                  const SizedBox(width: 14),
                  _StatCard('Returns', '$returned', AppColors.red500),
                ]),
                const SizedBox(height: 16),
                // Filter
                _FilterRow(ref: ref, current: statusFilter),
                const SizedBox(height: 16),
                ScPanel(
                  title: 'Invoices (${sales.length})',
                  icon: const Text('🧾', style: TextStyle(fontSize: 14)),
                  body: sales.isEmpty
                      ? const Padding(padding: EdgeInsets.all(32), child: Center(child: Text('No invoices found')))
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowHeight: 34,
                            dataRowMinHeight: 40,
                            dataRowMaxHeight: 40,
                            horizontalMargin: 14,
                            columnSpacing: 14,
                            headingRowColor: WidgetStateProperty.all(AppColors.gray50),
                            border: const TableBorder(horizontalInside: BorderSide(color: AppColors.gray100), top: BorderSide(color: AppColors.gray200)),
                            columns: const [
                              DataColumn(label: Text('Invoice #')),
                              DataColumn(label: Text('Customer')),
                              DataColumn(label: Text('Total'), numeric: true),
                              DataColumn(label: Text('Paid'), numeric: true),
                              DataColumn(label: Text('Balance'), numeric: true),
                              DataColumn(label: Text('Payment')),
                              DataColumn(label: Text('Status')),
                              DataColumn(label: Text('Date')),
                            ],
                            rows: sales.map((s) {
                              BadgeType bt;
                              switch (s.status) {
                                case 'paid': bt = BadgeType.success; break;
                                case 'pending': bt = BadgeType.warning; break;
                                case 'returned': bt = BadgeType.danger; break;
                                default: bt = BadgeType.info;
                              }
                              return DataRow(cells: [
                                DataCell(Text('#${s.invoiceNo}', style: AppTheme.mono(size: 12, color: AppColors.blue800, weight: FontWeight.w600))),
                                DataCell(Text(s.customerName, style: AppTheme.sans(size: 12, weight: FontWeight.w600))),
                                DataCell(Text(formatCurrency(s.total), style: AppTheme.mono(size: 12))),
                                DataCell(Text(formatCurrency(s.paid), style: AppTheme.mono(size: 12, color: AppColors.green700))),
                                DataCell(Text(formatCurrency(s.balance), style: AppTheme.mono(size: 12, color: s.balance > 0 ? AppColors.red500 : AppColors.gray500))),
                                DataCell(Text(s.paymentMethod, style: AppTheme.sans(size: 12))),
                                DataCell(ScBadge(s.status, type: bt)),
                                DataCell(Text(s.createdAt != null ? formatDateTime(s.createdAt!) : '—', style: AppTheme.mono(size: 11))),
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

  void _showNewInvoiceDialog(BuildContext context, WidgetRef ref) {
    showDialog(context: context, builder: (_) => _NewInvoiceDialog(ref: ref));
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

class _FilterRow extends StatelessWidget {
  final WidgetRef ref;
  final String current;
  const _FilterRow({required this.ref, required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: ['All', 'Paid', 'Pending', 'Returned', 'Insurance'].map((s) {
        final active = current == s;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => ref.read(_saleStatusFilterProvider.notifier).state = s,
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

// ── New Invoice Dialog ────────────────────────────────────────────────────────

class _NewInvoiceDialog extends ConsumerStatefulWidget {
  final WidgetRef ref;
  const _NewInvoiceDialog({required this.ref});

  @override
  ConsumerState<_NewInvoiceDialog> createState() => _NewInvoiceDialogState();
}

class _NewInvoiceDialogState extends ConsumerState<_NewInvoiceDialog> {
  final _customerCtrl = TextEditingController(text: 'Walk-in');
  final _discountCtrl = TextEditingController(text: '0');
  final _searchCtrl = TextEditingController();
  String _payment = 'cash';
  bool _loading = false;
  final List<_CartItem> _cart = [];

  double get _subtotal => _cart.fold(0, (s, i) => s + i.qty * i.price);
  double get _discount => double.tryParse(_discountCtrl.text) ?? 0;
  double get _total => _subtotal - _discount;

  @override
  Widget build(BuildContext context) {
    final meds = (widget.ref.watch(inventoryProvider).valueOrNull ?? [])
        .where((m) {
          final q = _searchCtrl.text.toLowerCase();
          return q.isEmpty || m.name.toLowerCase().contains(q) || (m.barcode?.contains(q) ?? false);
        }).toList();

    return AlertDialog(
      title: Text('New Invoice', style: AppTheme.sans(size: 15, weight: FontWeight.w700)),
      content: SizedBox(
        width: 700,
        height: 500,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left: medicine search
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
                          subtitle: Text('Stock: ${m.quantity} · ${formatCurrency(m.salePrice)}', style: AppTheme.mono(size: 11)),
                          trailing: IconButton(
                            icon: const Icon(Icons.add_circle_outline, color: AppColors.green600),
                            onPressed: () => setState(() {
                              final idx = _cart.indexWhere((c) => c.medicineId == m.id);
                              if (idx >= 0) {
                                _cart[idx].qty++;
                              } else {
                                _cart.add(_CartItem(medicineId: m.id, name: m.name, price: m.salePrice, batchNo: m.batchNo, expiryDate: m.expiryDate));
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
            // Right: cart
            SizedBox(
              width: 280,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ScTextField(label: 'Customer', controller: _customerCtrl),
                  const SizedBox(height: 10),
                  Expanded(
                    child: _cart.isEmpty
                        ? const Center(child: Text('Add items', style: TextStyle(color: AppColors.gray400)))
                        : ListView.builder(
                            itemCount: _cart.length,
                            itemBuilder: (_, i) {
                              final item = _cart[i];
                              return Row(
                                children: [
                                  Expanded(child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item.name, style: AppTheme.sans(size: 12, weight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                                      Text(formatCurrency(item.price * item.qty), style: AppTheme.mono(size: 11)),
                                    ],
                                  )),
                                  Row(mainAxisSize: MainAxisSize.min, children: [
                                    IconButton(icon: const Icon(Icons.remove, size: 14), padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                                      onPressed: () => setState(() { item.qty = (item.qty - 1).clamp(1, 999); })),
                                    Text('${item.qty}', style: AppTheme.mono(size: 12)),
                                    IconButton(icon: const Icon(Icons.add, size: 14), padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                                      onPressed: () => setState(() { item.qty++; })),
                                    IconButton(icon: const Icon(Icons.close, size: 14, color: AppColors.red500), padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                                      onPressed: () => setState(() { _cart.removeAt(i); })),
                                  ]),
                                ],
                              );
                            },
                          ),
                  ),
                  const Divider(),
                  ScTextField(label: 'Discount', controller: _discountCtrl,
                    keyboardType: TextInputType.number, onChanged: (_) => setState(() {})),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _payment,
                    decoration: const InputDecoration(labelText: 'Payment', isDense: true),
                    items: const [
                      DropdownMenuItem(value: 'cash', child: Text('Cash')),
                      DropdownMenuItem(value: 'card', child: Text('Card')),
                      DropdownMenuItem(value: 'credit', child: Text('Credit')),
                      DropdownMenuItem(value: 'insurance', child: Text('Insurance')),
                    ],
                    onChanged: (v) => setState(() => _payment = v!),
                  ),
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
              final items = _cart.map((c) => SaleItem(
                id: generateId(), saleId: '', medicineId: c.medicineId,
                medicineName: c.name, batchNo: c.batchNo, expiryDate: c.expiryDate,
                quantity: c.qty, unitPrice: c.price,
              )).toList();
              await ref.read(salesProvider.notifier).createSale(
                customerName: _customerCtrl.text.trim(),
                items: items,
                discount: _discount,
                paymentMethod: _payment,
              );
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invoice created successfully'), backgroundColor: AppColors.green600),
                );
              }
            } finally {
              if (mounted) setState(() => _loading = false);
            }
          },
          child: _loading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Create Invoice'),
        ),
      ],
    );
  }
}

class _CartItem {
  final String medicineId, name;
  final String? batchNo, expiryDate;
  double price;
  int qty;
  _CartItem({required this.medicineId, required this.name, required this.price, this.batchNo, this.expiryDate, this.qty = 1});
}
