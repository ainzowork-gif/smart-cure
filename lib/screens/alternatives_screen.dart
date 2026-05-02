import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_theme.dart';
import '../core/utils/helpers.dart';
import '../models/medicine.dart';
import '../providers/inventory_provider.dart';
import '../widgets/shared/sc_panel.dart';
import '../widgets/shared/sc_text_field.dart';
import '../widgets/shared/topbar.dart';

class AlternativesScreen extends ConsumerStatefulWidget {
  const AlternativesScreen({super.key});

  @override
  ConsumerState<AlternativesScreen> createState() => _AlternativesScreenState();
}

class _AlternativesScreenState extends ConsumerState<AlternativesScreen> {
  final _search = TextEditingController();
  Medicine? _selected;

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(inventoryProvider).valueOrNull ?? [];
    final q = _search.text.toLowerCase();
    final filtered = q.isEmpty ? all : all.where((m) =>
      m.name.toLowerCase().contains(q) ||
      (m.activeIngredient?.toLowerCase().contains(q) ?? false)
    ).toList();

    List<Medicine> alternatives = [];
    if (_selected != null && _selected!.activeIngredient != null && _selected!.activeIngredient!.isNotEmpty) {
      alternatives = all.where((m) =>
        m.id != _selected!.id &&
        m.activeIngredient != null &&
        m.activeIngredient!.toLowerCase() == _selected!.activeIngredient!.toLowerCase()
      ).toList();
    }

    return Column(
      children: [
        const Topbar(title: 'Medicine Alternatives', breadcrumb: 'Home › Alternatives'),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: search & select
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(18),
                  child: ScPanel(
                    title: 'Find Medicine',
                    icon: const Text('🔍', style: TextStyle(fontSize: 14)),
                    bodyPadding: const EdgeInsets.all(12),
                    body: Column(
                      children: [
                        ScTextField(
                          hint: 'Search by name or active ingredient…',
                          controller: _search,
                          onChanged: (_) => setState(() { _selected = null; }),
                        ),
                        const SizedBox(height: 10),
                        ...filtered.map((m) => GestureDetector(
                          onTap: () => setState(() => _selected = m),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: _selected?.id == m.id ? AppColors.blue50 : AppColors.white,
                              border: Border.all(color: _selected?.id == m.id ? AppColors.blue500 : AppColors.gray200),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(children: [
                              Expanded(child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(m.name, style: AppTheme.sans(size: 12, weight: FontWeight.w600, color: AppColors.gray900)),
                                  if (m.activeIngredient != null && m.activeIngredient!.isNotEmpty)
                                    Text('Active: ${m.activeIngredient}', style: AppTheme.sans(size: 11, color: AppColors.gray500)),
                                ],
                              )),
                              Text(formatCurrency(m.salePrice), style: AppTheme.mono(size: 12, weight: FontWeight.w600, color: AppColors.blue700)),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: m.quantity > 0 ? AppColors.green100 : AppColors.red100,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text('Qty: ${m.quantity}', style: AppTheme.mono(size: 10, color: m.quantity > 0 ? AppColors.green700 : AppColors.red500)),
                              ),
                            ]),
                          ),
                        )),
                      ],
                    ),
                  ),
                ),
              ),
              // Right: alternatives
              SizedBox(
                width: 380,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(0, 18, 18, 18),
                  child: ScPanel(
                    title: _selected == null ? 'Alternatives' : 'Alternatives for "${_selected!.name}"',
                    icon: const Text('💊', style: TextStyle(fontSize: 14)),
                    bodyPadding: const EdgeInsets.all(12),
                    body: _selected == null
                        ? const Padding(
                            padding: EdgeInsets.all(32),
                            child: Center(child: Text('Select a medicine to see alternatives', style: TextStyle(color: AppColors.gray400))),
                          )
                        : _selected!.activeIngredient == null || _selected!.activeIngredient!.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(children: [
                                  const Text('⚠️', style: TextStyle(fontSize: 32)),
                                  const SizedBox(height: 8),
                                  Text('No active ingredient set for this medicine.', style: AppTheme.sans(size: 12, color: AppColors.gray500), textAlign: TextAlign.center),
                                  const SizedBox(height: 4),
                                  Text('Edit the medicine and add its active ingredient to find alternatives.', style: AppTheme.sans(size: 11, color: AppColors.gray400), textAlign: TextAlign.center),
                                ]),
                              )
                            : alternatives.isEmpty
                                ? Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(children: [
                                      const Text('🔍', style: TextStyle(fontSize: 32)),
                                      const SizedBox(height: 8),
                                      Text('No alternatives found for "${_selected!.activeIngredient}"', style: AppTheme.sans(size: 12, color: AppColors.gray500), textAlign: TextAlign.center),
                                    ]),
                                  )
                                : Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(color: AppColors.blue50, borderRadius: BorderRadius.circular(6), border: Border.all(color: AppColors.blue200)),
                                        child: Row(children: [
                                          const Icon(Icons.info_outline, size: 14, color: AppColors.blue600),
                                          const SizedBox(width: 6),
                                          Expanded(child: Text(
                                            'Active ingredient: ${_selected!.activeIngredient} · ${alternatives.length} alternative(s) found',
                                            style: AppTheme.sans(size: 11, color: AppColors.blue700),
                                          )),
                                        ]),
                                      ),
                                      const SizedBox(height: 10),
                                      ...alternatives.map((m) => Container(
                                        margin: const EdgeInsets.only(bottom: 8),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: AppColors.white,
                                          border: Border.all(color: AppColors.gray200),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                              Expanded(child: Text(m.name, style: AppTheme.sans(size: 13, weight: FontWeight.w700, color: AppColors.gray900))),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                decoration: BoxDecoration(color: m.quantity > 0 ? AppColors.green100 : AppColors.red100, borderRadius: BorderRadius.circular(4)),
                                                child: Text(m.quantity > 0 ? 'In Stock' : 'Out', style: AppTheme.sans(size: 10, weight: FontWeight.w600, color: m.quantity > 0 ? AppColors.green700 : AppColors.red500)),
                                              ),
                                            ]),
                                            const SizedBox(height: 4),
                                            Row(children: [
                                              Text('Category: ${m.category ?? "—"}', style: AppTheme.sans(size: 11, color: AppColors.gray500)),
                                              const SizedBox(width: 12),
                                              Text('Qty: ${m.quantity}', style: AppTheme.mono(size: 11, color: AppColors.gray600)),
                                            ]),
                                            const SizedBox(height: 6),
                                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                              Text('Price: ${formatCurrency(m.salePrice)}', style: AppTheme.mono(size: 12, weight: FontWeight.w600, color: AppColors.blue700)),
                                              if (_selected != null)
                                                Text(
                                                  m.salePrice < _selected!.salePrice ? '✓ Cheaper' : m.salePrice > _selected!.salePrice ? '↑ More exp.' : '= Same price',
                                                  style: AppTheme.sans(size: 11, color: m.salePrice < _selected!.salePrice ? AppColors.green600 : m.salePrice > _selected!.salePrice ? AppColors.red500 : AppColors.gray500),
                                                ),
                                            ]),
                                          ],
                                        ),
                                      )),
                                    ],
                                  ),
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
