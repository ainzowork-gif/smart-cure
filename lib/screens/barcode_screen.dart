import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_theme.dart';
import '../core/utils/helpers.dart';
import '../models/medicine.dart';
import '../providers/inventory_provider.dart';
import '../widgets/shared/sc_button.dart';
import '../widgets/shared/sc_panel.dart';
import '../widgets/shared/topbar.dart';

class BarcodeScreen extends ConsumerStatefulWidget {
  const BarcodeScreen({super.key});

  @override
  ConsumerState<BarcodeScreen> createState() => _BarcodeScreenState();
}

class _BarcodeScreenState extends ConsumerState<BarcodeScreen> {
  final _search = TextEditingController();
  final Set<String> _selected = {};
  int _copies = 1;
  String _size = 'Standard (5×3 cm)';

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(inventoryProvider).valueOrNull ?? [];
    final query = _search.text.toLowerCase();
    final filtered = query.isEmpty ? all : all.where((m) =>
      m.name.toLowerCase().contains(query) || (m.barcode?.contains(query) ?? false)
    ).toList();

    return Column(
      children: [
        const Topbar(title: 'Barcode Printing', breadcrumb: 'Home › Barcode Print'),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: medicine list
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(18),
                  child: ScPanel(
                    title: 'Select Medicines',
                    icon: const Text('🔖', style: TextStyle(fontSize: 14)),
                    actions: [
                      ScButton('Select All', onTap: () => setState(() => _selected.addAll(all.map((m) => m.id))), small: true),
                      ScButton('Clear', onTap: () => setState(() => _selected.clear()), small: true),
                    ],
                    body: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: TextField(
                            controller: _search,
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              hintText: 'Search medicine or barcode…',
                              prefixIcon: const Icon(Icons.search, size: 18),
                              isDense: true,
                              filled: true,
                              fillColor: AppColors.gray50,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppColors.gray200)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppColors.gray200)),
                            ),
                          ),
                        ),
                        ...filtered.map((m) => CheckboxListTile(
                          dense: true,
                          title: Text(m.name, style: AppTheme.sans(size: 13, weight: FontWeight.w600, color: AppColors.gray900)),
                          subtitle: Text('${m.barcode ?? "No barcode"} · ${formatCurrency(m.salePrice)}', style: AppTheme.mono(size: 11)),
                          value: _selected.contains(m.id),
                          onChanged: (v) => setState(() {
                            if (v == true) _selected.add(m.id); else _selected.remove(m.id);
                          }),
                          activeColor: AppColors.blue600,
                        )),
                      ],
                    ),
                  ),
                ),
              ),
              // Right: print settings + preview
              SizedBox(
                width: 340,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(0, 18, 18, 18),
                  child: Column(
                    children: [
                      ScPanel(
                        title: 'Print Settings',
                        icon: const Text('⚙', style: TextStyle(fontSize: 14)),
                        bodyPadding: const EdgeInsets.all(16),
                        body: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Label Size', style: AppTheme.sans(size: 12, weight: FontWeight.w600, color: AppColors.gray700)),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              value: _size,
                              items: ['Standard (5×3 cm)', 'Small (3×2 cm)', 'Large (7×4 cm)'].map((s) => DropdownMenuItem(value: s, child: Text(s, style: AppTheme.sans(size: 12)))).toList(),
                              onChanged: (v) => setState(() => _size = v!),
                              decoration: InputDecoration(isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), border: OutlineInputBorder(borderRadius: BorderRadius.circular(6))),
                            ),
                            const SizedBox(height: 14),
                            Text('Copies per Label', style: AppTheme.sans(size: 12, weight: FontWeight.w600, color: AppColors.gray700)),
                            const SizedBox(height: 6),
                            Row(children: [
                              IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: () => setState(() => _copies = (_copies - 1).clamp(1, 100))),
                              Text('$_copies', style: AppTheme.sans(size: 15, weight: FontWeight.w700)),
                              IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () => setState(() => _copies = (_copies + 1).clamp(1, 100))),
                            ]),
                            const SizedBox(height: 14),
                            Text('Selected: ${_selected.length} medicines × $_copies = ${_selected.length * _copies} labels',
                              style: AppTheme.sans(size: 12, color: AppColors.gray600)),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _selected.isEmpty ? null : () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Printing ${_selected.length * _copies} labels…'), backgroundColor: AppColors.green600),
                                  );
                                },
                                icon: const Icon(Icons.print),
                                label: const Text('Print Labels'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Preview
                      ScPanel(
                        title: 'Label Preview',
                        icon: const Text('👁', style: TextStyle(fontSize: 14)),
                        bodyPadding: const EdgeInsets.all(16),
                        body: _selected.isEmpty
                          ? const Text('Select medicines to preview labels', style: TextStyle(color: AppColors.gray400))
                          : _LabelPreview(med: all.firstWhere((m) => m.id == _selected.first)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LabelPreview extends StatelessWidget {
  final Medicine med;
  const _LabelPreview({required this.med});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.gray300),
        borderRadius: BorderRadius.circular(6),
        color: AppColors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(med.name, style: AppTheme.sans(size: 14, weight: FontWeight.w700, color: AppColors.gray900)),
          const SizedBox(height: 4),
          Row(children: [
            Container(width: 80, height: 30, color: AppColors.gray200,
              child: const Center(child: Text('|||||||||||', style: TextStyle(fontSize: 8, letterSpacing: 1)))),
            const SizedBox(width: 8),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(med.barcode ?? '000000000', style: AppTheme.mono(size: 9)),
              Text('Exp: ${formatDate(med.expiryDate)}', style: AppTheme.sans(size: 9, color: AppColors.gray500)),
            ]),
          ]),
          const SizedBox(height: 4),
          Text('Price: ${formatCurrency(med.salePrice)}', style: AppTheme.sans(size: 11, weight: FontWeight.w600, color: AppColors.blue800)),
        ],
      ),
    );
  }
}
