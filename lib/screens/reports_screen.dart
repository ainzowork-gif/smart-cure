import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_theme.dart';
import '../core/database/database_helper.dart';
import '../core/utils/helpers.dart';
import '../providers/inventory_provider.dart';
import '../providers/purchases_provider.dart';
import '../providers/sales_provider.dart';
import '../providers/treasury_provider.dart';
import '../widgets/shared/sc_panel.dart';
import '../widgets/shared/topbar.dart';

final _topMedicinesProvider = FutureProvider<List<MapEntry<String, double>>>((ref) async {
  final db = DatabaseHelper();
  final rows = await db.rawQuery(
    'SELECT medicine_name, SUM(quantity * unit_price) as revenue FROM sale_items GROUP BY medicine_name ORDER BY revenue DESC LIMIT 8',
  );
  return rows.map((r) => MapEntry(r['medicine_name'] as String, (r['revenue'] as num).toDouble())).toList();
});

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sales = ref.watch(salesProvider).valueOrNull ?? [];
    final purchases = ref.watch(purchasesProvider).valueOrNull ?? [];
    final inventory = ref.watch(inventoryProvider).valueOrNull ?? [];
    final treasury = ref.watch(treasuryProvider).valueOrNull ?? [];

    final totalRevenue = sales.fold<double>(0, (s, inv) => s + inv.total);
    final totalCOGS = purchases.fold<double>(0, (s, p) => s + p.total);
    final grossProfit = totalRevenue - totalCOGS;
    final totalItems = inventory.fold<int>(0, (s, m) => s + m.quantity);
    final inventoryValue = inventory.fold<double>(0, (s, m) => s + m.purchasePrice * m.quantity);
    final lowStock = inventory.where((m) => m.isLowStock).length;
    final expired = inventory.where((m) => m.isExpired).length;

    // Sales by payment method
    final Map<String, double> byPayment = {};
    for (final s in sales) {
      byPayment[s.paymentMethod] = (byPayment[s.paymentMethod] ?? 0) + s.total;
    }

    final topMeds = ref.watch(_topMedicinesProvider).valueOrNull ?? [];

    // Monthly sales (last 6 months)
    final now = DateTime.now();
    final monthlyData = <String, double>{};
    for (var i = 5; i >= 0; i--) {
      final d = DateTime(now.year, now.month - i, 1);
      final key = '${d.month}/${d.year}';
      monthlyData[key] = 0;
    }
    for (final s in sales) {
      if (s.createdAt != null) {
        final d = DateTime.tryParse(s.createdAt!);
        if (d != null) {
          final key = '${d.month}/${d.year}';
          if (monthlyData.containsKey(key)) {
            monthlyData[key] = (monthlyData[key] ?? 0) + s.total;
          }
        }
      }
    }

    return Column(
      children: [
        const Topbar(title: 'Reports & Analytics', breadcrumb: 'Home › Reports'),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                // KPI Row
                Row(children: [
                  _KpiCard('Total Revenue', formatCurrency(totalRevenue), AppColors.blue600, '📈'),
                  const SizedBox(width: 14),
                  _KpiCard('Gross Profit', formatCurrency(grossProfit), grossProfit >= 0 ? AppColors.green600 : AppColors.red500, '💹'),
                  const SizedBox(width: 14),
                  _KpiCard('Inventory Value', formatCurrency(inventoryValue), AppColors.amber500, '📦'),
                  const SizedBox(width: 14),
                  _KpiCard('Total Orders', '${sales.length}', AppColors.blue600, '🧾'),
                ]),
                const SizedBox(height: 14),
                Row(children: [
                  _KpiCard('Total Items', '$totalItems units', AppColors.gray700, '💊'),
                  const SizedBox(width: 14),
                  _KpiCard('Low Stock', '$lowStock items', AppColors.amber500, '⚠️'),
                  const SizedBox(width: 14),
                  _KpiCard('Expired', '$expired items', AppColors.red500, '🔴'),
                  const SizedBox(width: 14),
                  _KpiCard('Total Purchases', formatCurrency(totalCOGS), AppColors.gray700, '🛒'),
                ]),
                const SizedBox(height: 18),

                // Charts row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Monthly sales bar chart
                    Expanded(
                      flex: 3,
                      child: ScPanel(
                        title: 'Monthly Sales (Last 6 Months)',
                        icon: const Text('📊', style: TextStyle(fontSize: 14)),
                        bodyPadding: const EdgeInsets.all(16),
                        body: SizedBox(
                          height: 220,
                          child: monthlyData.values.every((v) => v == 0)
                              ? const Center(child: Text('No sales data', style: TextStyle(color: AppColors.gray400)))
                              : BarChart(
                                  BarChartData(
                                    alignment: BarChartAlignment.spaceAround,
                                    barGroups: monthlyData.entries.toList().asMap().entries.map((e) {
                                      return BarChartGroupData(x: e.key, barRods: [
                                        BarChartRodData(
                                          toY: e.value.value,
                                          color: AppColors.blue600,
                                          width: 28,
                                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                                        ),
                                      ]);
                                    }).toList(),
                                    titlesData: FlTitlesData(
                                      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 52,
                                        getTitlesWidget: (v, _) => Text(formatCurrency(v).replaceAll(',000', 'K'), style: AppTheme.mono(size: 9)))),
                                      bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true,
                                        getTitlesWidget: (v, _) {
                                          final keys = monthlyData.keys.toList();
                                          final idx = v.toInt();
                                          if (idx < keys.length) return Padding(padding: const EdgeInsets.only(top: 6), child: Text(keys[idx], style: AppTheme.sans(size: 9)));
                                          return const SizedBox.shrink();
                                        })),
                                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    ),
                                    gridData: FlGridData(drawVerticalLine: false,
                                      getDrawingHorizontalLine: (_) => const FlLine(color: AppColors.gray100, strokeWidth: 1)),
                                    borderData: FlBorderData(show: false),
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Payment methods pie
                    Expanded(
                      flex: 2,
                      child: ScPanel(
                        title: 'Sales by Payment Method',
                        icon: const Text('🥧', style: TextStyle(fontSize: 14)),
                        bodyPadding: const EdgeInsets.all(16),
                        body: SizedBox(
                          height: 220,
                          child: byPayment.isEmpty
                              ? const Center(child: Text('No data', style: TextStyle(color: AppColors.gray400)))
                              : Row(
                                  children: [
                                    Expanded(
                                      child: PieChart(PieChartData(
                                        sectionsSpace: 2,
                                        centerSpaceRadius: 32,
                                        sections: _pieSlices(byPayment),
                                      )),
                                    ),
                                    const SizedBox(width: 8),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: byPayment.entries.map((e) => Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 3),
                                        child: Row(children: [
                                          Container(width: 10, height: 10, decoration: BoxDecoration(
                                            color: _pieColor(e.key), borderRadius: BorderRadius.circular(2))),
                                          const SizedBox(width: 6),
                                          Text('${e.key[0].toUpperCase()}${e.key.substring(1)}', style: AppTheme.sans(size: 11)),
                                        ]),
                                      )).toList(),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Top Medicines & Treasury
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ScPanel(
                        title: 'Top Selling Medicines',
                        icon: const Text('🏆', style: TextStyle(fontSize: 14)),
                        body: topMeds.isEmpty
                            ? const Padding(padding: EdgeInsets.all(20), child: Text('No sales yet', style: TextStyle(color: AppColors.gray400)))
                            : Column(
                                children: topMeds.take(8).toList().asMap().entries.map((e) {
                                  final pct = totalRevenue > 0 ? (e.value.value / totalRevenue * 100) : 0.0;
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                    child: Row(children: [
                                      Container(
                                        width: 22, height: 22,
                                        decoration: BoxDecoration(color: AppColors.blue50, borderRadius: BorderRadius.circular(4)),
                                        child: Center(child: Text('${e.key + 1}', style: AppTheme.mono(size: 10, weight: FontWeight.w700, color: AppColors.blue700))),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(e.value.key, style: AppTheme.sans(size: 12, weight: FontWeight.w600)),
                                          const SizedBox(height: 2),
                                          LinearProgressIndicator(
                                            value: pct / 100,
                                            backgroundColor: AppColors.gray100,
                                            valueColor: const AlwaysStoppedAnimation(AppColors.blue500),
                                            minHeight: 4,
                                          ),
                                        ],
                                      )),
                                      const SizedBox(width: 10),
                                      Text(formatCurrency(e.value.value), style: AppTheme.mono(size: 12, weight: FontWeight.w600, color: AppColors.blue800)),
                                    ]),
                                  );
                                }).toList(),
                              ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: ScPanel(
                        title: 'Financial Summary',
                        icon: const Text('💼', style: TextStyle(fontSize: 14)),
                        bodyPadding: const EdgeInsets.all(16),
                        body: Column(
                          children: [
                            _SummaryRow('Total Revenue', formatCurrency(totalRevenue), AppColors.green700),
                            _SummaryRow('Total Purchases (COGS)', formatCurrency(totalCOGS), AppColors.red500),
                            const Divider(height: 20),
                            _SummaryRow('Gross Profit', formatCurrency(grossProfit), grossProfit >= 0 ? AppColors.green700 : AppColors.red500, bold: true),
                            _SummaryRow('Inventory Value', formatCurrency(inventoryValue), AppColors.blue700),
                            const Divider(height: 20),
                            _SummaryRow('Cash In', formatCurrency(treasury.where((t) => t.isIncome).fold(0, (s, t) => s + t.amount)), AppColors.green700),
                            _SummaryRow('Cash Out', formatCurrency(treasury.where((t) => !t.isIncome).fold(0, (s, t) => s + t.amount)), AppColors.red500),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> _pieSlices(Map<String, double> data) {
    final total = data.values.fold<double>(0, (s, v) => s + v);
    final colors = [AppColors.blue600, AppColors.green600, AppColors.amber500, AppColors.red500, AppColors.gray500];
    return data.entries.toList().asMap().entries.map((e) {
      final pct = total > 0 ? e.value.value / total * 100 : 0.0;
      return PieChartSectionData(
        value: e.value.value,
        title: '${pct.toStringAsFixed(0)}%',
        titleStyle: AppTheme.sans(size: 10, weight: FontWeight.w700, color: Colors.white),
        color: colors[e.key % colors.length],
        radius: 55,
      );
    }).toList();
  }

  Color _pieColor(String method) {
    switch (method) {
      case 'cash': return AppColors.blue600;
      case 'card': return AppColors.green600;
      case 'credit': return AppColors.amber500;
      case 'insurance': return AppColors.red500;
      default: return AppColors.gray500;
    }
  }
}

class _KpiCard extends StatelessWidget {
  final String label, value, icon;
  final Color color;
  const _KpiCard(this.label, this.value, this.color, this.icon);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.white, border: Border.all(color: AppColors.borderColor), borderRadius: BorderRadius.circular(10)),
        child: Row(children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: AppTheme.sans(size: 11, color: AppColors.gray500)),
            const SizedBox(height: 2),
            Text(value, style: AppTheme.mono(size: 14, weight: FontWeight.w700, color: color)),
          ]),
        ]),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label, value;
  final Color color;
  final bool bold;
  const _SummaryRow(this.label, this.value, this.color, {this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: AppTheme.sans(size: 12, weight: bold ? FontWeight.w700 : FontWeight.w500, color: AppColors.gray700)),
        Text(value, style: AppTheme.mono(size: 13, weight: bold ? FontWeight.w700 : FontWeight.w600, color: color)),
      ]),
    );
  }
}
