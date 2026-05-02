import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_theme.dart';
import '../../providers/app_provider.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/sales_provider.dart';

class Sidebar extends ConsumerWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screen = ref.watch(activeScreenProvider);
    final inventory = ref.watch(inventoryProvider).valueOrNull ?? [];
    final lowStockCount = inventory.where((m) => m.isLowStock).length;
    final expiryCount = inventory.where((m) => m.isExpired || m.isNearExpiry).length;
    final sales = ref.watch(salesProvider).valueOrNull ?? [];
    final pendingSales = sales.where((s) => s.status == 'pending').length;

    return SizedBox(
      width: 220,
      child: Container(
        color: AppColors.blue900,
        child: Column(
          children: [
            _Logo(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _NavLabel('Main'),
                    _NavItem('Dashboard', '⊞', AppScreen.dashboard, screen, ref),
                    _NavItem('Sales', '🧾', AppScreen.sales, screen, ref, badge: pendingSales > 0 ? '$pendingSales' : null),
                    _NavItem('Purchases', '📦', AppScreen.purchases, screen, ref),
                    _NavItem('Inventory', '🗂', AppScreen.inventory, screen, ref, badge: lowStockCount > 0 ? '$lowStockCount' : null),
                    _NavLabel('Contacts'),
                    _NavItem('Customers', '👥', AppScreen.customers, screen, ref),
                    _NavItem('Suppliers', '🏭', AppScreen.suppliers, screen, ref),
                    _NavItem('Employees', '👤', AppScreen.employees, screen, ref),
                    _NavLabel('Finance'),
                    _NavItem('Treasury', '💰', AppScreen.treasury, screen, ref),
                    _NavItem('Accounting', '📑', AppScreen.accounting, screen, ref),
                    _NavLabel('Tools'),
                    _NavItem('Reports', '📊', AppScreen.reports, screen, ref),
                    _NavItem('Expiry Alerts', '📅', AppScreen.expiryAlerts, screen, ref, badge: expiryCount > 0 ? '$expiryCount' : null),
                    _NavItem('Barcode Print', '🔖', AppScreen.barcode, screen, ref),
                    _NavItem('Alternatives', '🔄', AppScreen.alternatives, screen, ref),
                    _NavLabel('System'),
                    _NavItem('Permissions', '🔐', AppScreen.permissions, screen, ref),
                    _NavItem('Settings', '⚙', AppScreen.settings, screen, ref),
                  ],
                ),
              ),
            ),
            _Footer(),
          ],
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0x14FFFFFF))),
      ),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.blue500, AppColors.green500],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text('Rx', style: AppTheme.sans(size: 15, weight: FontWeight.w700, color: AppColors.white)),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Smart Cure', style: AppTheme.sans(size: 14, weight: FontWeight.w700, color: AppColors.white)),
              Text('PHARMACY SYSTEM', style: AppTheme.sans(size: 9.5, color: const Color(0x66FFFFFF), weight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}

class _NavLabel extends StatelessWidget {
  final String label;
  const _NavLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 4),
      child: Text(
        label.toUpperCase(),
        style: AppTheme.sans(size: 9, weight: FontWeight.w600, color: const Color(0x4DFFFFFF)),
      ),
    );
  }
}

class _NavItem extends ConsumerWidget {
  final String label;
  final String icon;
  final AppScreen target;
  final AppScreen current;
  final WidgetRef ref;
  final String? badge;
  const _NavItem(this.label, this.icon, this.target, this.current, this.ref, {this.badge});

  @override
  Widget build(BuildContext context, WidgetRef _) {
    final active = current == target;
    return GestureDetector(
      onTap: () => ref.read(activeScreenProvider.notifier).state = target,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: active ? const Color(0x2E3B82F6) : Colors.transparent,
          border: Border(left: BorderSide(color: active ? AppColors.blue500 : Colors.transparent, width: 3)),
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 15)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: AppTheme.sans(
                  size: 13, weight: FontWeight.w500,
                  color: active ? AppColors.white : const Color(0x99FFFFFF),
                ),
              ),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(color: AppColors.red500, borderRadius: BorderRadius.circular(8)),
                child: Text(badge!, style: AppTheme.sans(size: 9, weight: FontWeight.w700, color: AppColors.white)),
              ),
          ],
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0x14FFFFFF)))),
      child: Row(
        children: [
          Container(
            width: 30, height: 30,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [AppColors.blue500, AppColors.green500]),
            ),
            child: Center(child: Text('AM', style: AppTheme.sans(size: 11, weight: FontWeight.w700, color: AppColors.white))),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ahmed M.', style: AppTheme.sans(size: 12, weight: FontWeight.w600, color: AppColors.white)),
                Text('Pharmacist', style: AppTheme.sans(size: 10, color: const Color(0x66FFFFFF))),
              ],
            ),
          ),
          Icon(Icons.logout_outlined, size: 16, color: const Color(0x4DFFFFFF)),
        ],
      ),
    );
  }
}
