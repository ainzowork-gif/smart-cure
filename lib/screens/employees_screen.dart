import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_theme.dart';
import '../core/utils/helpers.dart';
import '../models/employee.dart';
import '../providers/employees_provider.dart';
import '../widgets/shared/sc_badge.dart';
import '../widgets/shared/sc_button.dart';
import '../widgets/shared/sc_panel.dart';
import '../widgets/shared/sc_text_field.dart';
import '../widgets/shared/topbar.dart';

class EmployeesScreen extends ConsumerStatefulWidget {
  const EmployeesScreen({super.key});

  @override
  ConsumerState<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends ConsumerState<EmployeesScreen> {
  final _search = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(employeesProvider).valueOrNull ?? [];
    final q = _search.text.toLowerCase();
    final filtered = q.isEmpty ? all : all.where((e) =>
      e.name.toLowerCase().contains(q) || (e.role?.toLowerCase().contains(q) ?? false)
    ).toList();

    final activeCount = all.where((e) => e.active).length;
    final totalSalary = all.where((e) => e.active).fold<double>(0, (s, e) => s + e.salary);

    return Column(
      children: [
        Topbar(
          title: 'Employees',
          breadcrumb: 'Home › Employees',
          actions: [ScButton('Add Employee', onTap: () => _showDialog(context), variant: BtnVariant.success)],
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Row(children: [
                  _StatCard('Total Staff', '${all.length}', AppColors.blue600),
                  const SizedBox(width: 14),
                  _StatCard('Active', '$activeCount', AppColors.green600),
                  const SizedBox(width: 14),
                  _StatCard('Monthly Payroll', formatCurrency(totalSalary), AppColors.amber500),
                ]),
                const SizedBox(height: 16),
                ScPanel(
                  title: 'Staff (${filtered.length})',
                  icon: const Text('👥', style: TextStyle(fontSize: 14)),
                  actions: [
                    SizedBox(
                      width: 220,
                      child: TextField(
                        controller: _search,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Search employees…',
                          hintStyle: AppTheme.sans(size: 12, color: AppColors.gray400),
                          prefixIcon: const Icon(Icons.search, size: 16, color: AppColors.gray400),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 8),
                          filled: true,
                          fillColor: AppColors.gray50,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppColors.gray200)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppColors.gray200)),
                        ),
                      ),
                    ),
                  ],
                  body: filtered.isEmpty
                      ? const Padding(padding: EdgeInsets.all(32), child: Center(child: Text('No employees found')))
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowHeight: 34,
                            dataRowMinHeight: 52,
                            dataRowMaxHeight: 52,
                            horizontalMargin: 14,
                            columnSpacing: 16,
                            headingRowColor: WidgetStateProperty.all(AppColors.gray50),
                            border: const TableBorder(
                              horizontalInside: BorderSide(color: AppColors.gray100),
                              top: BorderSide(color: AppColors.gray200),
                            ),
                            columns: const [
                              DataColumn(label: Text('Employee')),
                              DataColumn(label: Text('Role')),
                              DataColumn(label: Text('Phone')),
                              DataColumn(label: Text('Salary'), numeric: true),
                              DataColumn(label: Text('Join Date')),
                              DataColumn(label: Text('Status')),
                              DataColumn(label: Text('Actions')),
                            ],
                            rows: filtered.map((e) => DataRow(cells: [
                              DataCell(Row(children: [
                                Container(
                                  width: 36, height: 36,
                                  decoration: BoxDecoration(
                                    color: AppColors.blue600.withOpacity(.1),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Center(child: Text(e.initials, style: AppTheme.sans(size: 12, weight: FontWeight.w700, color: AppColors.blue700))),
                                ),
                                const SizedBox(width: 8),
                                Text(e.name, style: AppTheme.sans(size: 12, weight: FontWeight.w600)),
                              ])),
                              DataCell(Text(e.role ?? '—', style: AppTheme.sans(size: 12))),
                              DataCell(Text(e.phone ?? '—', style: AppTheme.mono(size: 12))),
                              DataCell(Text(formatCurrency(e.salary), style: AppTheme.mono(size: 12, weight: FontWeight.w600))),
                              DataCell(Text(e.joinDate != null ? formatDate(e.joinDate!) : '—', style: AppTheme.mono(size: 11))),
                              DataCell(ScBadge(e.active ? 'Active' : 'Inactive', type: e.active ? BadgeType.success : BadgeType.gray)),
                              DataCell(Row(mainAxisSize: MainAxisSize.min, children: [
                                ScButton('Edit', small: true, onTap: () => _showDialog(context, employee: e)),
                                const SizedBox(width: 6),
                                ScButton('Delete', small: true, variant: BtnVariant.danger, onTap: () => _delete(context, e.id)),
                              ])),
                            ])).toList(),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showDialog(BuildContext context, {Employee? employee}) {
    showDialog(context: context, builder: (_) => _EmployeeDialog(employee: employee));
  }

  Future<void> _delete(BuildContext context, String id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Employee'),
        content: const Text('Are you sure you want to remove this employee?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.red500), onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(employeesProvider.notifier).delete(id);
    }
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatCard(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.white, border: Border.all(color: AppColors.borderColor), borderRadius: BorderRadius.circular(10)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: AppTheme.sans(size: 11.5, color: AppColors.gray500)),
          const SizedBox(height: 4),
          Text(value, style: AppTheme.mono(size: 18, weight: FontWeight.w700, color: color)),
        ]),
      ),
    );
  }
}

// ── Employee Dialog ───────────────────────────────────────────────────────────

class _EmployeeDialog extends ConsumerStatefulWidget {
  final Employee? employee;
  const _EmployeeDialog({this.employee});

  @override
  ConsumerState<_EmployeeDialog> createState() => _EmployeeDialogState();
}

class _EmployeeDialogState extends ConsumerState<_EmployeeDialog> {
  late final _nameCtrl = TextEditingController(text: widget.employee?.name ?? '');
  late final _roleCtrl = TextEditingController(text: widget.employee?.role ?? '');
  late final _phoneCtrl = TextEditingController(text: widget.employee?.phone ?? '');
  late final _emailCtrl = TextEditingController(text: widget.employee?.email ?? '');
  late final _salaryCtrl = TextEditingController(text: widget.employee?.salary.toString() ?? '0');
  late final _joinDateCtrl = TextEditingController(text: widget.employee?.joinDate ?? '');
  late bool _active = widget.employee?.active ?? true;
  bool _loading = false;

  bool get _isEdit => widget.employee != null;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEdit ? 'Edit Employee' : 'Add Employee', style: AppTheme.sans(size: 15, weight: FontWeight.w700)),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScTextField(label: 'Full Name *', controller: _nameCtrl),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: ScTextField(label: 'Role / Position', controller: _roleCtrl)),
              const SizedBox(width: 10),
              Expanded(child: ScTextField(label: 'Phone', controller: _phoneCtrl)),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: ScTextField(label: 'Email', controller: _emailCtrl)),
              const SizedBox(width: 10),
              Expanded(child: ScTextField(label: 'Monthly Salary', controller: _salaryCtrl, keyboardType: TextInputType.number)),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: ScTextField(label: 'Join Date (YYYY-MM-DD)', controller: _joinDateCtrl)),
              const SizedBox(width: 10),
              Expanded(
                child: Row(children: [
                  Checkbox(value: _active, onChanged: (v) => setState(() => _active = v ?? true), activeColor: AppColors.green600),
                  Text('Active', style: AppTheme.sans(size: 13, weight: FontWeight.w600)),
                ]),
              ),
            ]),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: _loading || _nameCtrl.text.trim().isEmpty ? null : () async {
            setState(() => _loading = true);
            try {
              final e = Employee(
                id: widget.employee?.id ?? generateId(),
                name: _nameCtrl.text.trim(),
                role: _roleCtrl.text.trim().isEmpty ? null : _roleCtrl.text.trim(),
                phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
                email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
                salary: double.tryParse(_salaryCtrl.text) ?? 0,
                joinDate: _joinDateCtrl.text.trim().isEmpty ? null : _joinDateCtrl.text.trim(),
                active: _active,
                createdAt: widget.employee?.createdAt ?? nowIso(),
              );
              if (_isEdit) {
                await ref.read(employeesProvider.notifier).save(e);
              } else {
                await ref.read(employeesProvider.notifier).add(e);
              }
              if (mounted) Navigator.pop(context);
            } finally {
              if (mounted) setState(() => _loading = false);
            }
          },
          child: _loading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : Text(_isEdit ? 'Update' : 'Add Employee'),
        ),
      ],
    );
  }
}
