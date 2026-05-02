import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_theme.dart';
import '../models/employee.dart';
import '../providers/employees_provider.dart';
import '../widgets/shared/sc_badge.dart';
import '../widgets/shared/sc_button.dart';
import '../widgets/shared/sc_panel.dart';
import '../widgets/shared/topbar.dart';

const _allModules = [
  'Dashboard', 'Inventory', 'Sales', 'Purchases',
  'Customers', 'Suppliers', 'Employees', 'Treasury',
  'Reports', 'Expiry Alerts', 'Barcode', 'Accounting',
  'Alternatives', 'Settings',
];

class PermissionsScreen extends ConsumerStatefulWidget {
  const PermissionsScreen({super.key});

  @override
  ConsumerState<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends ConsumerState<PermissionsScreen> {
  String? _selectedEmployeeId;
  Set<String> _perms = {};
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final employees = ref.watch(employeesProvider).valueOrNull ?? [];
    final selected = employees.where((e) => e.id == _selectedEmployeeId).firstOrNull;

    return Column(
      children: [
        Topbar(
          title: 'Permissions',
          breadcrumb: 'Home › Permissions',
          actions: selected == null ? [] : [
            ScButton('Save Permissions', variant: BtnVariant.success,
              onTap: _saving ? null : () async {
                setState(() => _saving = true);
                final updated = selected.copyWith(permissions: _perms.join(','));
                await ref.read(employeesProvider.notifier).save(updated);
                if (mounted) {
                  setState(() => _saving = false);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Permissions saved'),
                    backgroundColor: AppColors.green600,
                  ));
                }
              }),
          ],
        ),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Employee list
              SizedBox(
                width: 280,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(18),
                  child: ScPanel(
                    title: 'Staff',
                    icon: const Text('👥', style: TextStyle(fontSize: 14)),
                    bodyPadding: const EdgeInsets.all(8),
                    body: employees.isEmpty
                        ? const Padding(padding: EdgeInsets.all(20), child: Text('No employees found'))
                        : Column(
                            children: employees.map((e) => GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedEmployeeId = e.id;
                                  _perms = e.permissions != null && e.permissions!.isNotEmpty
                                      ? e.permissions!.split(',').toSet()
                                      : Set.from(_allModules);
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 4),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: _selectedEmployeeId == e.id ? AppColors.blue50 : Colors.transparent,
                                  border: Border.all(color: _selectedEmployeeId == e.id ? AppColors.blue500 : Colors.transparent),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(children: [
                                  Container(
                                    width: 34, height: 34,
                                    decoration: BoxDecoration(color: AppColors.blue600.withOpacity(.1), borderRadius: BorderRadius.circular(17)),
                                    child: Center(child: Text(e.initials, style: AppTheme.sans(size: 11, weight: FontWeight.w700, color: AppColors.blue700))),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(e.name, style: AppTheme.sans(size: 12, weight: FontWeight.w600)),
                                      Text(e.role ?? 'Staff', style: AppTheme.sans(size: 11, color: AppColors.gray500)),
                                    ],
                                  )),
                                  ScBadge(e.active ? 'Active' : 'Off', type: e.active ? BadgeType.success : BadgeType.gray),
                                ]),
                              ),
                            )).toList(),
                          ),
                  ),
                ),
              ),
              // Permissions grid
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(0, 18, 18, 18),
                  child: ScPanel(
                    title: selected == null ? 'Module Permissions' : 'Permissions for ${selected.name}',
                    icon: const Text('🔐', style: TextStyle(fontSize: 14)),
                    actions: selected == null ? [] : [
                      ScButton('Grant All', small: true, variant: BtnVariant.success,
                        onTap: () => setState(() => _perms = Set.from(_allModules))),
                      const SizedBox(width: 6),
                      ScButton('Revoke All', small: true, variant: BtnVariant.danger,
                        onTap: () => setState(() => _perms.clear())),
                    ],
                    bodyPadding: const EdgeInsets.all(16),
                    body: selected == null
                        ? const Padding(
                            padding: EdgeInsets.all(40),
                            child: Center(child: Text('Select an employee to manage their permissions', style: TextStyle(color: AppColors.gray400))),
                          )
                        : Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: _allModules.map((mod) {
                              final granted = _perms.contains(mod);
                              return GestureDetector(
                                onTap: () => setState(() {
                                  if (granted) _perms.remove(mod); else _perms.add(mod);
                                }),
                                child: Container(
                                  width: 180,
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: granted ? AppColors.green600.withOpacity(.07) : AppColors.gray50,
                                    border: Border.all(color: granted ? AppColors.green600.withOpacity(.3) : AppColors.gray200),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(children: [
                                    Icon(granted ? Icons.check_circle : Icons.radio_button_unchecked,
                                      size: 18, color: granted ? AppColors.green600 : AppColors.gray300),
                                    const SizedBox(width: 8),
                                    Text(mod, style: AppTheme.sans(size: 12, weight: FontWeight.w600,
                                      color: granted ? AppColors.gray900 : AppColors.gray400)),
                                  ]),
                                ),
                              );
                            }).toList(),
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

