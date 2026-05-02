import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppScreen {
  dashboard,
  inventory,
  sales,
  purchases,
  customers,
  suppliers,
  employees,
  reports,
  treasury,
  expiryAlerts,
  barcode,
  accounting,
  alternatives,
  permissions,
  settings,
}

final activeScreenProvider = StateProvider<AppScreen>((ref) => AppScreen.dashboard);

final searchQueryProvider = StateProvider<String>((ref) => '');
