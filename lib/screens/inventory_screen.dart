import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_theme.dart';
import '../core/utils/helpers.dart';
import '../models/medicine.dart';
import '../providers/app_provider.dart';
import '../providers/inventory_provider.dart';
import '../widgets/shared/sc_badge.dart';
import '../widgets/shared/sc_button.dart';
import '../widgets/shared/sc_panel.dart';
import '../widgets/shared/sc_text_field.dart';
import '../widgets/shared/stock_bar.dart';
import '../widgets/shared/topbar.dart';

final _filterProvider = StateProvider<String>((ref) => 'all');
final _catFilterProvider = StateProvider<String>((ref) => 'All');

class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final all = ref.watch(inventoryProvider).valueOrNull ?? [];
    final search = ref.watch(searchQueryProvider).toLowerCase();
    final filter = ref.watch(_filterProvider);
    final cat = ref.watch(_catFilterProvider);

    var items = all;
    if (search.isNotEmpty) {
      items = items.where((m) =>
        m.name.toLowerCase().contains(search) ||
        (m.category?.toLowerCase().contains(search) ?? false) ||
        (m.barcode?.contains(search) ?? false) ||
        (m.batchNo?.toLowerCase().contains(search) ?? false)
      ).toList();
    }
    switch (filter) {
      case 'low': items = items.where((m) => m.isLowStock).toList(); break;
      case 'expired': items = items.where((m) => m.isExpired).toList(); break;
      case 'near': items = items.where((m) => m.isNearExpiry).toList(); break;
    }
    if (cat != 'All') items = items.where((m) => m.category == cat).toList();

    final categories = ['All', ...{...all.map((m) => m.category ?? 'Other')}];

    return Column(
      children: [
        Topbar(
          title: 'Inventory',
          breadcrumb: 'Home › Inventory',
          actions: [
            ScButton('+ Add Medicine', onTap: () => _showMedicineDialog(context, ref), variant: BtnVariant.success),
          ],
        ),
        // Summary bar
        _SummaryBar(all: all),
        // Filter bar
        _FilterBar(filter: filter, cat: cat, categories: categories, ref: ref),
        Expanded(
          child: Container(
            color: AppColors.contentBg,
            child: ref.watch(inventoryProvider).when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (_) => _InventoryTable(items: items, ref: ref),
            ),
          ),
        ),
      ],
    );
  }

  void _showMedicineDialog(BuildContext context, WidgetRef ref, [Medicine? existing]) {
    final nameCtrl = TextEditingController(text: existing?.name);
    final sciCtrl = TextEditingController(text: existing?.scientificName);
    final catCtrl = TextEditingController(text: existing?.category);
    final barcodeCtrl = TextEditingController(text: existing?.barcode);
    final batchCtrl = TextEditingController(text: existing?.batchNo);
    final expiryCtrl = TextEditingController(text: existing?.expiryDate);
    final purchCtrl = TextEditingController(text: existing?.purchasePrice.toString() ?? '0');
    final saleCtrl = TextEditingController(text: existing?.salePrice.toString() ?? '0');
    final qtyCtrl = TextEditingController(text: existing?.quantity.toString() ?? '0');
    final minCtrl = TextEditingController(text: existing?.minQuantity.toString() ?? '10');
    final ingCtrl = TextEditingController(text: existing?.activeIngredient);
    final key = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing == null ? 'Add New Medicine' : 'Edit Medicine',
          style: AppTheme.sans(size: 15, weight: FontWeight.w700, color: AppColors.gray900)),
        content: SizedBox(
          width: 600,
          child: Form(
            key: key,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _Row2Fields(
                    ScTextField(label: 'Medicine Name *', controller: nameCtrl,
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null),
                    ScTextField(label: 'Scientific Name', controller: sciCtrl),
                  ),
                  const SizedBox(height: 12),
                  _Row2Fields(
                    ScTextField(label: 'Category', controller: catCtrl),
                    ScTextField(label: 'Barcode', controller: barcodeCtrl),
                  ),
                  const SizedBox(height: 12),
                  _Row2Fields(
                    ScTextField(label: 'Batch No', controller: batchCtrl),
                    ScTextField(label: 'Expiry Date (YYYY-MM-DD)', controller: expiryCtrl),
                  ),
                  const SizedBox(height: 12),
                  _Row2Fields(
                    ScTextField(label: 'Purchase Price', controller: purchCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))]),
                    ScTextField(label: 'Sale Price', controller: saleCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))]),
                  ),
                  const SizedBox(height: 12),
                  _Row2Fields(
                    ScTextField(label: 'Quantity', controller: qtyCtrl, keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
                    ScTextField(label: 'Min Quantity', controller: minCtrl, keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
                  ),
                  const SizedBox(height: 12),
                  ScTextField(label: 'Active Ingredient', controller: ingCtrl),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (!key.currentState!.validate()) return;
              final now = nowIso();
              final m = Medicine(
                id: existing?.id ?? generateId(),
                name: nameCtrl.text.trim(),
                scientificName: sciCtrl.text.trim().isEmpty ? null : sciCtrl.text.trim(),
                category: catCtrl.text.trim().isEmpty ? null : catCtrl.text.trim(),
                barcode: barcodeCtrl.text.trim().isEmpty ? null : barcodeCtrl.text.trim(),
                batchNo: batchCtrl.text.trim().isEmpty ? null : batchCtrl.text.trim(),
                expiryDate: expiryCtrl.text.trim().isEmpty ? null : expiryCtrl.text.trim(),
                purchasePrice: double.tryParse(purchCtrl.text) ?? 0,
                salePrice: double.tryParse(saleCtrl.text) ?? 0,
                quantity: int.tryParse(qtyCtrl.text) ?? 0,
                minQuantity: int.tryParse(minCtrl.text) ?? 10,
                activeIngredient: ingCtrl.text.trim().isEmpty ? null : ingCtrl.text.trim(),
                createdAt: existing?.createdAt ?? now,
                updatedAt: now,
              );
              if (existing == null) {
                ref.read(inventoryProvider.notifier).add(m);
              } else {
                ref.read(inventoryProvider.notifier).save(m);
              }
              Navigator.pop(ctx);
            },
            child: Text(existing == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
  }
}

class _SummaryBar extends StatelessWidget {
  final List<Medicine> all;
  const _SummaryBar({required this.all});

  @override
  Widget build(BuildContext context) {
    final total = all.length;
    final low = all.where((m) => m.isLowStock).length;
    final expired = all.where((m) => m.isExpired).length;
    final near = all.where((m) => m.isNearExpiry).length;
    final value = all.fold<double>(0, (s, m) => s + m.salePrice * m.quantity);

    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          _StatChip('Total Items', '$total', AppColors.blue600),
          const SizedBox(width: 14),
          _StatChip('Low Stock', '$low', AppColors.amber500),
          const SizedBox(width: 14),
          _StatChip('Expired', '$expired', AppColors.red500),
          const SizedBox(width: 14),
          _StatChip('Near Expiry', '$near', AppColors.amber600),
          const SizedBox(width: 14),
          _StatChip('Stock Value', formatCurrency(value), AppColors.green600),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatChip(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(.06),
        border: Border.all(color: color.withOpacity(.2)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: AppTheme.sans(size: 11.5, color: AppColors.gray600)),
          const SizedBox(width: 8),
          Text(value, style: AppTheme.sans(size: 13, weight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  final String filter, cat;
  final List<String> categories;
  final WidgetRef ref;
  const _FilterBar({required this.filter, required this.cat, required this.categories, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: const BoxDecoration(color: AppColors.white, border: Border(bottom: BorderSide(color: AppColors.gray200))),
      child: Row(
        children: [
          _FilterBtn('All', 'all', filter, ref),
          const SizedBox(width: 8),
          _FilterBtn('Low Stock', 'low', filter, ref),
          const SizedBox(width: 8),
          _FilterBtn('Expired', 'expired', filter, ref),
          const SizedBox(width: 8),
          _FilterBtn('Near Expiry', 'near', filter, ref),
          const SizedBox(width: 16),
          Container(height: 24, width: 1, color: AppColors.gray200),
          const SizedBox(width: 16),
          Text('Category:', style: AppTheme.sans(size: 12, color: AppColors.gray600)),
          const SizedBox(width: 8),
          DropdownButton<String>(
            value: cat,
            isDense: true,
            underline: const SizedBox(),
            style: AppTheme.sans(size: 12, color: AppColors.gray900),
            items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (v) { if (v != null) ref.read(_catFilterProvider.notifier).state = v; },
          ),
        ],
      ),
    );
  }
}

class _FilterBtn extends StatelessWidget {
  final String label, value, current;
  final WidgetRef ref;
  const _FilterBtn(this.label, this.value, this.current, this.ref);

  @override
  Widget build(BuildContext context) {
    final active = current == value;
    return GestureDetector(
      onTap: () => ref.read(_filterProvider.notifier).state = value,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppColors.blue600 : AppColors.white,
          border: Border.all(color: active ? AppColors.blue600 : AppColors.gray200),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(label, style: AppTheme.sans(size: 11, weight: FontWeight.w600, color: active ? AppColors.white : AppColors.gray600)),
      ),
    );
  }
}

class _InventoryTable extends ConsumerWidget {
  final List<Medicine> items;
  final WidgetRef ref;
  const _InventoryTable({required this.items, required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef _) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: ScPanel(
        title: 'Medicines (${items.length})',
        icon: const Text('💊', style: TextStyle(fontSize: 14)),
        body: items.isEmpty
            ? const Padding(padding: EdgeInsets.all(32), child: Center(child: Text('No items found')))
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowHeight: 34,
                  dataRowMinHeight: 44,
                  dataRowMaxHeight: 54,
                  horizontalMargin: 14,
                  columnSpacing: 14,
                  headingRowColor: WidgetStateProperty.all(AppColors.gray50),
                  border: const TableBorder(
                    horizontalInside: BorderSide(color: AppColors.gray100),
                    top: BorderSide(color: AppColors.gray200),
                  ),
                  columns: _cols(),
                  rows: items.map((m) => _row(context, m)).toList(),
                ),
              ),
      ),
    );
  }

  List<DataColumn> _cols() => const [
    DataColumn(label: Text('#')),
    DataColumn(label: Text('Medicine Name')),
    DataColumn(label: Text('Category')),
    DataColumn(label: Text('Batch')),
    DataColumn(label: Text('Expiry')),
    DataColumn(label: Text('Purchase')),
    DataColumn(label: Text('Sale Price')),
    DataColumn(label: Text('Stock')),
    DataColumn(label: Text('Min')),
    DataColumn(label: Text('Ingredient')),
    DataColumn(label: Text('Status')),
    DataColumn(label: Text('Actions')),
  ];

  DataRow _row(BuildContext context, Medicine m) {
    BadgeType bt; String bl;
    if (m.isExpired) { bt = BadgeType.danger; bl = 'Expired'; }
    else if (m.isNearExpiry) { bt = BadgeType.warning; bl = 'Near Exp.'; }
    else if (m.isLowStock) { bt = BadgeType.warning; bl = 'Low Stock'; }
    else { bt = BadgeType.success; bl = 'In Stock'; }

    Color expiryColor = AppColors.gray700;
    if (m.isExpired) expiryColor = AppColors.red500;
    else if (m.isNearExpiry) expiryColor = AppColors.amber500;

    return DataRow(cells: [
      DataCell(Text(m.id.substring(0, m.id.length.clamp(0, 8)), style: AppTheme.mono(size: 11))),
      DataCell(Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(m.name, style: AppTheme.sans(size: 12, weight: FontWeight.w600, color: AppColors.gray900)),
          if (m.scientificName != null)
            Text(m.scientificName!, style: AppTheme.sans(size: 10, color: AppColors.gray400)),
        ],
      )),
      DataCell(Text(m.category ?? '—', style: AppTheme.sans(size: 12))),
      DataCell(Text(m.batchNo ?? '—', style: AppTheme.mono(size: 11.5))),
      DataCell(Text(formatDate(m.expiryDate), style: AppTheme.sans(size: 12, color: expiryColor, weight: m.isExpired || m.isNearExpiry ? FontWeight.w600 : FontWeight.w400))),
      DataCell(Text(formatCurrency(m.purchasePrice), style: AppTheme.mono(size: 11.5))),
      DataCell(Text(formatCurrency(m.salePrice), style: AppTheme.mono(size: 12, weight: FontWeight.w700, color: AppColors.blue800))),
      DataCell(StockBar(quantity: m.quantity, maxQuantity: 500)),
      DataCell(Text('${m.minQuantity}', style: AppTheme.mono(size: 11.5))),
      DataCell(SizedBox(width: 100, child: Text(m.activeIngredient ?? '—', style: AppTheme.sans(size: 11), overflow: TextOverflow.ellipsis))),
      DataCell(ScBadge(bl, type: bt)),
      DataCell(Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 16),
            color: AppColors.blue600,
            tooltip: 'Edit',
            onPressed: () => (context.findAncestorWidgetOfExactType<InventoryScreen>() != null
              ? InventoryScreen()
              : const InventoryScreen())._showMedicineDialog(context, ref, m),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 16),
            color: AppColors.red500,
            tooltip: 'Delete',
            onPressed: () => _confirmDelete(context, m),
          ),
        ],
      )),
    ]);
  }

  void _confirmDelete(BuildContext context, Medicine m) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Medicine'),
        content: Text('Delete "${m.name}"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.red500),
            onPressed: () {
              ref.read(inventoryProvider.notifier).delete(m.id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _Row2Fields extends StatelessWidget {
  final Widget left, right;
  const _Row2Fields(this.left, this.right);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        const SizedBox(width: 12),
        Expanded(child: right),
      ],
    );
  }
}
