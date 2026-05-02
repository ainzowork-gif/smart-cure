import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_theme.dart';
import '../core/utils/helpers.dart';
import '../providers/purchases_provider.dart';
import '../providers/sales_provider.dart';
import '../providers/treasury_provider.dart';
import '../widgets/shared/sc_badge.dart';
import '../widgets/shared/sc_panel.dart';
import '../widgets/shared/topbar.dart';

class AccountingScreen extends ConsumerWidget {
  const AccountingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sales = ref.watch(salesProvider).valueOrNull ?? [];
    final purchases = ref.watch(purchasesProvider).valueOrNull ?? [];
    final treasury = ref.watch(treasuryProvider).valueOrNull ?? [];

    final totalRevenue = sales.fold<double>(0, (s, i) => s + i.total);
    final totalPaid = sales.fold<double>(0, (s, i) => s + i.paid);
    final totalReceivable = totalRevenue - totalPaid;
    final totalCOGS = purchases.fold<double>(0, (s, p) => s + p.total);
    final totalPurchPaid = purchases.fold<double>(0, (s, p) => s + p.paid);
    final totalPayable = totalCOGS - totalPurchPaid;
    final cashIn = treasury.where((t) => t.isIncome).fold<double>(0, (s, t) => s + t.amount);
    final cashOut = treasury.where((t) => !t.isIncome).fold<double>(0, (s, t) => s + t.amount);
    final netCash = cashIn - cashOut;

    return Column(
      children: [
        const Topbar(title: 'Accounting', breadcrumb: 'Home › Accounting'),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                // Summary cards
                Row(children: [
                  _Card('Total Revenue', formatCurrency(totalRevenue), AppColors.green600, '📈'),
                  const SizedBox(width: 14),
                  _Card('Total COGS', formatCurrency(totalCOGS), AppColors.red500, '🛒'),
                  const SizedBox(width: 14),
                  _Card('Net Profit', formatCurrency(totalRevenue - totalCOGS), (totalRevenue - totalCOGS) >= 0 ? AppColors.green600 : AppColors.red500, '💹'),
                  const SizedBox(width: 14),
                  _Card('Net Cash', formatCurrency(netCash), netCash >= 0 ? AppColors.blue600 : AppColors.red500, '💰'),
                ]),
                const SizedBox(height: 14),
                Row(children: [
                  _Card('Accounts Receivable', formatCurrency(totalReceivable), AppColors.amber500, '📤'),
                  const SizedBox(width: 14),
                  _Card('Accounts Payable', formatCurrency(totalPayable), AppColors.amber600, '📥'),
                  const SizedBox(width: 14),
                  _Card('Cash In', formatCurrency(cashIn), AppColors.green600, '⬆'),
                  const SizedBox(width: 14),
                  _Card('Cash Out', formatCurrency(cashOut), AppColors.red500, '⬇'),
                ]),
                const SizedBox(height: 18),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Accounts Receivable
                    Expanded(
                      child: ScPanel(
                        title: 'Accounts Receivable (Unpaid Invoices)',
                        icon: const Text('📤', style: TextStyle(fontSize: 14)),
                        body: _buildTable(
                          columns: const ['Invoice #', 'Customer', 'Total', 'Paid', 'Balance', 'Status'],
                          rows: sales.where((s) => s.balance > 0).map((s) => [
                            '#${s.invoiceNo}',
                            s.customerName,
                            formatCurrency(s.total),
                            formatCurrency(s.paid),
                            formatCurrency(s.balance),
                            s.status,
                          ]).toList(),
                          emptyMsg: 'All invoices fully paid',
                          colorCol: 5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Accounts Payable
                    Expanded(
                      child: ScPanel(
                        title: 'Accounts Payable (Unpaid POs)',
                        icon: const Text('📥', style: TextStyle(fontSize: 14)),
                        body: _buildTable(
                          columns: const ['PO #', 'Supplier', 'Total', 'Paid', 'Balance', 'Status'],
                          rows: purchases.where((p) => p.balance > 0).map((p) => [
                            '#${p.poNo}',
                            p.supplierName,
                            formatCurrency(p.total),
                            formatCurrency(p.paid),
                            formatCurrency(p.balance),
                            p.status,
                          ]).toList(),
                          emptyMsg: 'All purchase orders fully paid',
                          colorCol: 5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ScPanel(
                  title: 'Profit & Loss Statement',
                  icon: const Text('📋', style: TextStyle(fontSize: 14)),
                  bodyPadding: const EdgeInsets.all(16),
                  body: Column(
                    children: [
                      _PLRow('Revenue', formatCurrency(totalRevenue), AppColors.green700, bold: true),
                      _PLRow('Cost of Goods Sold (COGS)', '- ${formatCurrency(totalCOGS)}', AppColors.red500),
                      const Divider(height: 20),
                      _PLRow('Gross Profit', formatCurrency(totalRevenue - totalCOGS),
                        (totalRevenue - totalCOGS) >= 0 ? AppColors.green700 : AppColors.red500, bold: true),
                      const SizedBox(height: 8),
                      _PLRow('Operating Expenses (Cash Out)', '- ${formatCurrency(cashOut)}', AppColors.red500),
                      const Divider(height: 20),
                      _PLRow('Net Income', formatCurrency(totalRevenue - totalCOGS - cashOut),
                        (totalRevenue - totalCOGS - cashOut) >= 0 ? AppColors.green700 : AppColors.red500, bold: true, large: true),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTable({
    required List<String> columns,
    required List<List<String>> rows,
    required String emptyMsg,
    int colorCol = -1,
  }) {
    if (rows.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(child: Text(emptyMsg, style: const TextStyle(color: AppColors.gray400))),
      );
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowHeight: 34,
        dataRowMinHeight: 38,
        dataRowMaxHeight: 38,
        horizontalMargin: 14,
        columnSpacing: 14,
        headingRowColor: WidgetStateProperty.all(AppColors.gray50),
        border: const TableBorder(
          horizontalInside: BorderSide(color: AppColors.gray100),
          top: BorderSide(color: AppColors.gray200),
        ),
        columns: columns.map((c) => DataColumn(label: Text(c))).toList(),
        rows: rows.map((r) => DataRow(
          cells: r.asMap().entries.map((e) {
            if (e.key == colorCol) {
              BadgeType bt;
              switch (e.value) {
                case 'paid': bt = BadgeType.success; break;
                case 'pending': bt = BadgeType.warning; break;
                case 'received': bt = BadgeType.success; break;
                default: bt = BadgeType.info;
              }
              return DataCell(ScBadge(e.value, type: bt));
            }
            return DataCell(Text(e.value, style: AppTheme.mono(size: 12)));
          }).toList(),
        )).toList(),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final String label, value, icon;
  final Color color;
  const _Card(this.label, this.value, this.color, this.icon);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.white, border: Border.all(color: AppColors.borderColor), borderRadius: BorderRadius.circular(10)),
        child: Row(children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: AppTheme.sans(size: 10.5, color: AppColors.gray500)),
            const SizedBox(height: 2),
            Text(value, style: AppTheme.mono(size: 14, weight: FontWeight.w700, color: color)),
          ]),
        ]),
      ),
    );
  }
}

class _PLRow extends StatelessWidget {
  final String label, value;
  final Color color;
  final bool bold, large;
  const _PLRow(this.label, this.value, this.color, {this.bold = false, this.large = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: AppTheme.sans(size: large ? 14 : 12, weight: bold ? FontWeight.w700 : FontWeight.w500)),
        Text(value, style: AppTheme.mono(size: large ? 16 : 13, weight: bold ? FontWeight.w700 : FontWeight.w600, color: color)),
      ]),
    );
  }
}
