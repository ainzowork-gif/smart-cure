import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_theme.dart';
import '../core/utils/helpers.dart';
import '../providers/inventory_provider.dart';
import '../widgets/shared/sc_badge.dart';
import '../widgets/shared/sc_button.dart';
import '../widgets/shared/sc_panel.dart';
import '../widgets/shared/topbar.dart';

class ExpiryAlertsScreen extends ConsumerWidget {
  const ExpiryAlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final all = ref.watch(inventoryProvider).valueOrNull ?? [];
    final expired = all.where((m) => m.isExpired).toList();
    final critical = all.where((m) => !m.isExpired && daysUntilExpiry(m.expiryDate) <= 7).toList();
    final nearExpiry = all.where((m) => m.isNearExpiry && daysUntilExpiry(m.expiryDate) > 7).toList();

    return Column(
      children: [
        const Topbar(title: 'Expiry Alerts', breadcrumb: 'Home › Expiry Alerts'),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                // Summary
                Row(children: [
                  _SummaryCard('Expired', expired.length, AppColors.red500, AppColors.red100),
                  const SizedBox(width: 14),
                  _SummaryCard('Critical (≤7 days)', critical.length, AppColors.amber600, AppColors.amber100),
                  const SizedBox(width: 14),
                  _SummaryCard('Near Expiry (≤30 days)', nearExpiry.length, AppColors.amber500, const Color(0xFFFFF7ED)),
                ]),
                const SizedBox(height: 18),
                if (expired.isNotEmpty) ...[
                  _AlertTable(title: 'Expired Medicines', icon: '🔴', items: expired, type: BadgeType.danger, badgeLabel: 'Expired'),
                  const SizedBox(height: 16),
                ],
                if (critical.isNotEmpty) ...[
                  _AlertTable(title: 'Critical — Expiring in ≤7 Days', icon: '⚠️', items: critical, type: BadgeType.danger, badgeLabel: 'Critical'),
                  const SizedBox(height: 16),
                ],
                if (nearExpiry.isNotEmpty)
                  _AlertTable(title: 'Expiring Within 30 Days', icon: '🗓', items: nearExpiry, type: BadgeType.warning, badgeLabel: 'Near Exp.'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color, bg;
  const _SummaryCard(this.label, this.count, this.color, this.bg);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: color.withOpacity(.3)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(color: color.withOpacity(.15), borderRadius: BorderRadius.circular(10)),
              child: Center(child: Text('$count', style: AppTheme.sans(size: 22, weight: FontWeight.w700, color: color))),
            ),
            const SizedBox(width: 12),
            Text(label, style: AppTheme.sans(size: 13, weight: FontWeight.w600, color: AppColors.gray700)),
          ],
        ),
      ),
    );
  }
}

class _AlertTable extends StatelessWidget {
  final String title, icon, badgeLabel;
  final List items;
  final BadgeType type;
  const _AlertTable({required this.title, required this.icon, required this.items, required this.type, required this.badgeLabel});

  @override
  Widget build(BuildContext context) {
    return ScPanel(
      title: title,
      icon: Text(icon, style: const TextStyle(fontSize: 14)),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowHeight: 34,
          dataRowMinHeight: 40,
          dataRowMaxHeight: 40,
          horizontalMargin: 14,
          columnSpacing: 16,
          headingRowColor: WidgetStateProperty.all(AppColors.gray50),
          border: const TableBorder(horizontalInside: BorderSide(color: AppColors.gray100), top: BorderSide(color: AppColors.gray200)),
          columns: const [
            DataColumn(label: Text('Medicine')),
            DataColumn(label: Text('Category')),
            DataColumn(label: Text('Batch')),
            DataColumn(label: Text('Expiry Date')),
            DataColumn(label: Text('Days Left')),
            DataColumn(label: Text('Qty')),
            DataColumn(label: Text('Value')),
            DataColumn(label: Text('Status')),
          ],
          rows: items.map((m) {
            final days = daysUntilExpiry(m.expiryDate);
            return DataRow(cells: [
              DataCell(Text(m.name, style: AppTheme.sans(size: 12, weight: FontWeight.w600, color: AppColors.gray900))),
              DataCell(Text(m.category ?? '—', style: AppTheme.sans(size: 12))),
              DataCell(Text(m.batchNo ?? '—', style: AppTheme.mono(size: 11.5))),
              DataCell(Text(formatDate(m.expiryDate), style: AppTheme.sans(size: 12, weight: FontWeight.w600, color: type == BadgeType.danger ? AppColors.red500 : AppColors.amber500))),
              DataCell(Text(days < 0 ? 'EXPIRED' : '$days days', style: AppTheme.mono(size: 11.5, color: days < 0 ? AppColors.red500 : AppColors.amber600))),
              DataCell(Text('${m.quantity}', style: AppTheme.mono(size: 12))),
              DataCell(Text(formatCurrency(m.salePrice * m.quantity), style: AppTheme.mono(size: 12))),
              DataCell(ScBadge(badgeLabel, type: type)),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}
