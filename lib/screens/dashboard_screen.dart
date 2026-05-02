import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_theme.dart';
import '../core/utils/helpers.dart';
import '../providers/inventory_provider.dart';
import '../providers/sales_provider.dart';
import '../providers/treasury_provider.dart';
import '../widgets/shared/kpi_card.dart';
import '../widgets/shared/sc_badge.dart';
import '../widgets/shared/sc_button.dart';
import '../widgets/shared/sc_panel.dart';
import '../widgets/shared/stock_bar.dart';
import '../widgets/shared/topbar.dart';
import '../providers/app_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        const Topbar(title: 'Dashboard', breadcrumb: 'Home › Dashboard'),
        Expanded(
          child: Container(
            color: AppColors.contentBg,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  _KpiRow(),
                  const SizedBox(height: 16),
                  _Row2(),
                  const SizedBox(height: 16),
                  _Row3(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── KPI Row ──────────────────────────────────────────────────────────────────

class _KpiRow extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sales = ref.watch(salesProvider);
    final inventory = ref.watch(inventoryProvider);
    final treasury = ref.watch(treasuryProvider);

    final todayTotal = sales.valueOrNull != null
        ? ref.read(salesProvider.notifier).todayTotal()
        : 0.0;
    final todayCount = sales.valueOrNull != null
        ? ref.read(salesProvider.notifier).todaySales().length
        : 0;
    final cashBalance = treasury.valueOrNull?.fold<double>(0, (s, t) => s + (t.isIncome ? t.amount : -t.amount)) ?? 0;
    final lowStock = inventory.valueOrNull?.where((m) => m.isLowStock).length ?? 0;
    final expiryAlerts = inventory.valueOrNull?.where((m) => m.isExpired || m.isNearExpiry).length ?? 0;

    return Row(
      children: [
        Expanded(child: KpiCard(
          label: "Today's Sales", value: formatCurrency(todayTotal),
          sub: '$todayCount transactions today', delta: '▲ 12%', deltaUp: true,
          accentColor: AppColors.blue600, iconBg: AppColors.blue50, emoji: '💰',
        )),
        const SizedBox(width: 14),
        Expanded(child: KpiCard(
          label: 'Cash Balance', value: formatCurrency(cashBalance),
          sub: 'Updated just now', delta: '▲ 4%', deltaUp: true,
          accentColor: AppColors.green600, iconBg: AppColors.green50, emoji: '💵',
        )),
        const SizedBox(width: 14),
        Expanded(child: KpiCard(
          label: 'Low Stock Alerts', value: '$lowStock',
          sub: 'Items below threshold', delta: '▼ 5 items', deltaUp: false,
          accentColor: AppColors.amber500, iconBg: AppColors.amber100, emoji: '⚠️',
        )),
        const SizedBox(width: 14),
        Expanded(child: KpiCard(
          label: 'Expiry Alerts', value: '$expiryAlerts',
          sub: 'Expiring within 30 days', delta: '▼ Critical: 2', deltaUp: false,
          accentColor: AppColors.red500, iconBg: AppColors.red100, emoji: '🗓',
        )),
      ],
    );
  }
}

// ── Row 2: Chart + Alerts ────────────────────────────────────────────────────

class _Row2 extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 320,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(flex: 3, child: _SalesChartPanel()),
          const SizedBox(width: 16),
          SizedBox(width: 340, child: _AlertsPanel()),
        ],
      ),
    );
  }
}

class _SalesChartPanel extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final barData = [
      ('Mon', 48.0 / 90, AppColors.blue100),
      ('Tue', 65.0 / 90, AppColors.blue100),
      ('Wed', 42.0 / 90, AppColors.blue100),
      ('Thu', 78.0 / 90, AppColors.blue600),
      ('Fri', 56.0 / 90, AppColors.blue100),
      ('Sat', 88.0 / 90, AppColors.blue600),
      ('Today', 90.0 / 90, AppColors.green500),
    ];

    return ScPanel(
      title: 'Weekly Sales Overview',
      icon: const Text('📈', style: TextStyle(fontSize: 14)),
      actions: [
        ScButton('This Week', onTap: () {}, small: true),
        ScButton('Month', onTap: () {}, small: true),
        ScButton('Export', onTap: () {}, variant: BtnVariant.primary, small: true),
      ],
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 13, 16, 10),
            child: SizedBox(
              height: 110,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: barData.map((d) {
                  final (label, pct, color) = d;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: FractionallySizedBox(
                                heightFactor: pct,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: color,
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            label,
                            style: AppTheme.sans(
                              size: 9, color: label == 'Today' ? AppColors.gray700 : AppColors.gray400,
                              weight: label == 'Today' ? FontWeight.w700 : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            color: AppColors.gray100,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('\$0', style: AppTheme.sans(size: 10, color: AppColors.gray400)),
                Text('\$2,500', style: AppTheme.sans(size: 10, color: AppColors.gray400)),
                Text('\$5,000', style: AppTheme.sans(size: 10, color: AppColors.gray400)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                _MiniStat('Weekly Total', '\$24,610', 'vs \$21,200 last week'),
                const SizedBox(width: 10),
                _MiniStat('Avg per Day', '\$3,515', 'Mon–Sun'),
                const SizedBox(width: 10),
                _MiniStat('Invoices', '214', 'This week'),
                const SizedBox(width: 10),
                _MiniStat('Returns', '\$320', '4 items returned'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label, value, sub;
  const _MiniStat(this.label, this.value, this.sub);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.gray50,
          border: Border.all(color: AppColors.gray200),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label.toUpperCase(), style: AppTheme.sans(size: 10, color: AppColors.gray400, weight: FontWeight.w500)),
          const SizedBox(height: 2),
          Text(value, style: AppTheme.sans(size: 17, weight: FontWeight.w700, color: AppColors.gray900)),
          const SizedBox(height: 1),
          Text(sub, style: AppTheme.sans(size: 10, color: AppColors.gray400)),
        ]),
      ),
    );
  }
}

class _AlertsPanel extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventory = ref.watch(inventoryProvider).valueOrNull ?? [];
    final sales = ref.watch(salesProvider).valueOrNull ?? [];

    final alerts = <_Alert>[
      ...inventory.where((m) => m.isExpired).map((m) => _Alert(
            title: '${m.name} — EXPIRED',
            sub: 'Exp: ${formatDate(m.expiryDate)} · Batch #${m.batchNo} · Qty: ${m.quantity}',
            color: AppColors.red500,
          )),
      ...inventory.where((m) => m.isNearExpiry).map((m) {
        final days = daysUntilExpiry(m.expiryDate);
        return _Alert(
          title: '${m.name} — $days days left',
          sub: 'Exp: ${formatDate(m.expiryDate)} · Batch #${m.batchNo} · Qty: ${m.quantity}',
          color: AppColors.red500,
        );
      }),
      ...inventory.where((m) => m.isLowStock && !m.isExpired).map((m) => _Alert(
            title: '${m.name} — Low Stock',
            sub: 'Only ${m.quantity} units remaining · Min threshold: ${m.minQuantity}',
            color: AppColors.amber500,
          )),
      ...sales.where((s) => s.status == 'pending').take(3).map((s) => _Alert(
            title: 'Invoice #${s.invoiceNo} Pending',
            sub: 'Balance: ${formatCurrency(s.balance)} · Customer: ${s.customerName}',
            color: AppColors.blue500,
          )),
    ];

    return ScPanel(
      title: 'Active Alerts',
      icon: const Text('🔔', style: TextStyle(fontSize: 14)),
      actions: [ScButton('View All', onTap: () {}, small: true)],
      body: alerts.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: Text('No alerts', style: TextStyle(color: AppColors.gray400))),
            )
          : SingleChildScrollView(
              child: Column(
                children: alerts
                    .take(8)
                    .map((a) => _AlertRow(a))
                    .toList(),
              ),
            ),
    );
  }
}

class _Alert {
  final String title, sub;
  final Color color;
  const _Alert({required this.title, required this.sub, required this.color});
}

class _AlertRow extends StatelessWidget {
  final _Alert alert;
  const _AlertRow(this.alert);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.gray100))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8, height: 8,
            margin: const EdgeInsets.only(top: 3),
            decoration: BoxDecoration(color: alert.color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(alert.title, style: AppTheme.sans(size: 12.5, weight: FontWeight.w600, color: AppColors.gray900)),
              const SizedBox(height: 1),
              Text(alert.sub, style: AppTheme.sans(size: 11, color: AppColors.gray500)),
            ]),
          ),
        ],
      ),
    );
  }
}

// ── Row 3: Inventory Table + Invoices ───────────────────────────────────────

class _Row3 extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 440,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(flex: 3, child: _InventoryTablePanel()),
          const SizedBox(width: 16),
          SizedBox(width: 340, child: _RecentInvoicesPanel()),
        ],
      ),
    );
  }
}

class _InventoryTablePanel extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meds = ref.watch(inventoryProvider).valueOrNull ?? [];
    final displayed = meds.take(8).toList();

    return ScPanel(
      title: 'Medicine Inventory',
      icon: const Text('💊', style: TextStyle(fontSize: 14)),
      actions: [
        ScButton('Filter', onTap: () {}, small: true),
        ScButton('+ Add Item', onTap: () => ref.read(activeScreenProvider.notifier).state = AppScreen.inventory, variant: BtnVariant.success, small: true),
      ],
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowHeight: 34,
          dataRowMinHeight: 40,
          dataRowMaxHeight: 50,
          horizontalMargin: 14,
          columnSpacing: 16,
          headingRowColor: WidgetStateProperty.all(AppColors.gray50),
          border: const TableBorder(
            horizontalInside: BorderSide(color: AppColors.gray100),
            top: BorderSide(color: AppColors.gray200),
          ),
          columns: const [
            DataColumn(label: Text('#')),
            DataColumn(label: Text('Medicine Name')),
            DataColumn(label: Text('Category')),
            DataColumn(label: Text('Batch')),
            DataColumn(label: Text('Expiry')),
            DataColumn(label: Text('Stock')),
            DataColumn(label: Text('Price')),
            DataColumn(label: Text('Status')),
          ],
          rows: displayed.asMap().entries.map((e) {
            final m = e.value;
            final idx = e.key;
            BadgeType badgeType;
            String badgeLabel;
            if (m.isExpired) { badgeType = BadgeType.danger; badgeLabel = 'Expired'; }
            else if (m.isNearExpiry) { badgeType = BadgeType.warning; badgeLabel = 'Near Exp.'; }
            else if (m.isLowStock) { badgeType = BadgeType.warning; badgeLabel = 'Low Stock'; }
            else { badgeType = BadgeType.success; badgeLabel = 'In Stock'; }

            Color expiryColor = AppColors.gray700;
            if (m.isExpired) expiryColor = AppColors.red500;
            else if (m.isNearExpiry) expiryColor = AppColors.amber500;

            return DataRow(cells: [
              DataCell(Text('${(idx + 41).toString().padLeft(4, '0')}', style: AppTheme.mono(size: 11.5))),
              DataCell(Text(m.name, style: AppTheme.sans(size: 12, weight: FontWeight.w600, color: AppColors.gray900))),
              DataCell(Text(m.category ?? '—', style: AppTheme.sans(size: 12))),
              DataCell(Text(m.batchNo ?? '—', style: AppTheme.mono(size: 11.5))),
              DataCell(Text(formatDate(m.expiryDate), style: AppTheme.sans(size: 12, color: expiryColor, weight: m.isExpired || m.isNearExpiry ? FontWeight.w600 : FontWeight.w400))),
              DataCell(StockBar(quantity: m.quantity, maxQuantity: 500)),
              DataCell(Text(formatCurrency(m.salePrice), style: AppTheme.mono(size: 12))),
              DataCell(ScBadge(badgeLabel, type: badgeType)),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}

class _RecentInvoicesPanel extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sales = ref.watch(salesProvider).valueOrNull ?? [];
    final recent = sales.take(8).toList();

    return ScPanel(
      title: 'Recent Invoices',
      icon: const Text('🧾', style: TextStyle(fontSize: 14)),
      actions: [
        ScButton('New Invoice', onTap: () => ref.read(activeScreenProvider.notifier).state = AppScreen.sales, variant: BtnVariant.primary, small: true),
      ],
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowHeight: 34,
          dataRowMinHeight: 40,
          dataRowMaxHeight: 40,
          horizontalMargin: 14,
          columnSpacing: 16,
          headingRowColor: WidgetStateProperty.all(AppColors.gray50),
          border: const TableBorder(
            horizontalInside: BorderSide(color: AppColors.gray100),
            top: BorderSide(color: AppColors.gray200),
          ),
          columns: const [
            DataColumn(label: Text('Inv #')),
            DataColumn(label: Text('Customer')),
            DataColumn(label: Text('Amount')),
            DataColumn(label: Text('Status')),
          ],
          rows: recent.map((s) {
            BadgeType bt;
            switch (s.status) {
              case 'paid': bt = BadgeType.success; break;
              case 'pending': bt = BadgeType.warning; break;
              case 'returned': bt = BadgeType.danger; break;
              default: bt = BadgeType.info;
            }
            return DataRow(cells: [
              DataCell(Text('#${s.invoiceNo}', style: AppTheme.mono(size: 11.5, color: AppColors.blue800))),
              DataCell(Text(s.customerName, style: AppTheme.sans(size: 12, weight: FontWeight.w600))),
              DataCell(Text(formatCurrency(s.total), style: AppTheme.mono(size: 12, weight: FontWeight.w700, color: AppColors.blue800))),
              DataCell(ScBadge(s.status, type: bt)),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}
