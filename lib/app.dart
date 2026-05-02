import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_colors.dart';
import 'providers/app_provider.dart';
import 'screens/accounting_screen.dart';
import 'screens/alternatives_screen.dart';
import 'screens/barcode_screen.dart';
import 'screens/customers_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/employees_screen.dart';
import 'screens/expiry_alerts_screen.dart';
import 'screens/inventory_screen.dart';
import 'screens/permissions_screen.dart';
import 'screens/purchases_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/sales_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/suppliers_screen.dart';
import 'screens/treasury_screen.dart';
import 'widgets/shared/sidebar.dart';
import 'widgets/shared/status_bar.dart';

class SmartCureApp extends StatelessWidget {
  const SmartCureApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Cure',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.blue600),
        useMaterial3: true,
        fontFamily: 'DM Sans',
        scaffoldBackgroundColor: AppColors.contentBg,
      ),
      home: const _AppShell(),
    );
  }
}

class _AppShell extends ConsumerWidget {
  const _AppShell();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screen = ref.watch(activeScreenProvider);

    return Scaffold(
      backgroundColor: AppColors.contentBg,
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                const Sidebar(),
                Expanded(
                  child: _ScreenSwitcher(screen: screen),
                ),
              ],
            ),
          ),
          const StatusBar(),
        ],
      ),
    );
  }
}

class _ScreenSwitcher extends StatelessWidget {
  final AppScreen screen;
  const _ScreenSwitcher({required this.screen});

  @override
  Widget build(BuildContext context) {
    return switch (screen) {
      AppScreen.dashboard    => const DashboardScreen(),
      AppScreen.inventory    => const InventoryScreen(),
      AppScreen.sales        => const SalesScreen(),
      AppScreen.purchases    => const PurchasesScreen(),
      AppScreen.customers    => const CustomersScreen(),
      AppScreen.suppliers    => const SuppliersScreen(),
      AppScreen.employees    => const EmployeesScreen(),
      AppScreen.reports      => const ReportsScreen(),
      AppScreen.treasury     => const TreasuryScreen(),
      AppScreen.expiryAlerts => const ExpiryAlertsScreen(),
      AppScreen.barcode      => const BarcodeScreen(),
      AppScreen.accounting   => const AccountingScreen(),
      AppScreen.alternatives => const AlternativesScreen(),
      AppScreen.permissions  => const PermissionsScreen(),
      AppScreen.settings     => const SettingsScreen(),
    };
  }
}
