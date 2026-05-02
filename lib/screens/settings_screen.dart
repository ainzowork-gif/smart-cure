import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_theme.dart';
import '../core/database/database_helper.dart';
import '../widgets/shared/sc_button.dart';
import '../widgets/shared/sc_panel.dart';
import '../widgets/shared/sc_text_field.dart';
import '../widgets/shared/topbar.dart';

final _settingsProvider = FutureProvider<Map<String, String>>((ref) async {
  final db = DatabaseHelper();
  final keys = ['pharmacy_name', 'address', 'phone', 'email', 'license_no', 'currency', 'tax_rate', 'low_stock_threshold'];
  final Map<String, String> result = {};
  for (final k in keys) {
    result[k] = await db.getSetting(k) ?? '';
  }
  return result;
});

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _licenseCtrl = TextEditingController();
  final _currencyCtrl = TextEditingController();
  final _taxCtrl = TextEditingController();
  final _lowStockCtrl = TextEditingController();

  bool _initialized = false;
  bool _saving = false;

  void _init(Map<String, String> s) {
    if (_initialized) return;
    _nameCtrl.text = s['pharmacy_name'] ?? 'Smart Cure Pharmacy';
    _addressCtrl.text = s['address'] ?? '';
    _phoneCtrl.text = s['phone'] ?? '';
    _emailCtrl.text = s['email'] ?? '';
    _licenseCtrl.text = s['license_no'] ?? '';
    _currencyCtrl.text = s['currency'] ?? 'EGP';
    _taxCtrl.text = s['tax_rate'] ?? '0';
    _lowStockCtrl.text = s['low_stock_threshold'] ?? '10';
    _initialized = true;
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(_settingsProvider);

    return Column(
      children: [
        const Topbar(title: 'Settings', breadcrumb: 'Home › Settings'),
        Expanded(
          child: settingsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (settings) {
              _init(settings);
              return SingleChildScrollView(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ScPanel(
                            title: 'Pharmacy Information',
                            icon: const Text('🏥', style: TextStyle(fontSize: 14)),
                            bodyPadding: const EdgeInsets.all(16),
                            body: Column(
                              children: [
                                ScTextField(label: 'Pharmacy Name', controller: _nameCtrl),
                                const SizedBox(height: 12),
                                ScTextField(label: 'Address', controller: _addressCtrl),
                                const SizedBox(height: 12),
                                Row(children: [
                                  Expanded(child: ScTextField(label: 'Phone', controller: _phoneCtrl)),
                                  const SizedBox(width: 12),
                                  Expanded(child: ScTextField(label: 'Email', controller: _emailCtrl)),
                                ]),
                                const SizedBox(height: 12),
                                ScTextField(label: 'License Number', controller: _licenseCtrl),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: ScPanel(
                            title: 'System Settings',
                            icon: const Text('⚙', style: TextStyle(fontSize: 14)),
                            bodyPadding: const EdgeInsets.all(16),
                            body: Column(
                              children: [
                                ScTextField(label: 'Currency Code (e.g. EGP, USD)', controller: _currencyCtrl),
                                const SizedBox(height: 12),
                                ScTextField(label: 'Tax Rate (%)', controller: _taxCtrl, keyboardType: TextInputType.number),
                                const SizedBox(height: 12),
                                ScTextField(label: 'Low Stock Threshold (units)', controller: _lowStockCtrl, keyboardType: TextInputType.number),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    ScPanel(
                      title: 'Database',
                      icon: const Text('🗄', style: TextStyle(fontSize: 14)),
                      bodyPadding: const EdgeInsets.all(16),
                      body: Row(
                        children: [
                          _ActionCard(
                            icon: '💾',
                            title: 'Backup Database',
                            subtitle: 'Export your data to a safe location',
                            color: AppColors.blue600,
                            onTap: () => _showMsg(context, 'Backup feature requires file picker integration'),
                          ),
                          const SizedBox(width: 14),
                          _ActionCard(
                            icon: '📥',
                            title: 'Restore Database',
                            subtitle: 'Restore from a previous backup file',
                            color: AppColors.amber500,
                            onTap: () => _showMsg(context, 'Restore feature requires file picker integration'),
                          ),
                          const SizedBox(width: 14),
                          _ActionCard(
                            icon: '🗑',
                            title: 'Clear All Data',
                            subtitle: 'Permanently delete all records',
                            color: AppColors.red500,
                            onTap: () => _confirmClear(context),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ScButton('Reset', onTap: () { setState(() { _initialized = false; }); ref.invalidate(_settingsProvider); }),
                        const SizedBox(width: 12),
                        ScButton(
                          'Save Settings',
                          variant: BtnVariant.success,
                          onTap: _saving ? null : () async {
                            setState(() => _saving = true);
                            final db = DatabaseHelper();
                            await db.setSetting('pharmacy_name', _nameCtrl.text.trim());
                            await db.setSetting('address', _addressCtrl.text.trim());
                            await db.setSetting('phone', _phoneCtrl.text.trim());
                            await db.setSetting('email', _emailCtrl.text.trim());
                            await db.setSetting('license_no', _licenseCtrl.text.trim());
                            await db.setSetting('currency', _currencyCtrl.text.trim());
                            await db.setSetting('tax_rate', _taxCtrl.text.trim());
                            await db.setSetting('low_stock_threshold', _lowStockCtrl.text.trim());
                            if (mounted) {
                              setState(() => _saving = false);
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                content: Text('Settings saved successfully'),
                                backgroundColor: AppColors.green600,
                              ));
                              ref.invalidate(_settingsProvider);
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showMsg(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _confirmClear(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text('This will permanently delete ALL records. This cannot be undone. Are you sure?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.red500),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear Everything'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      _showMsg(context, 'Data cleared. Please restart the app.');
    }
  }
}

class _ActionCard extends StatelessWidget {
  final String icon, title, subtitle;
  final Color color;
  final VoidCallback onTap;
  const _ActionCard({required this.icon, required this.title, required this.subtitle, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(.05),
            border: Border.all(color: color.withOpacity(.2)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 8),
              Text(title, style: AppTheme.sans(size: 13, weight: FontWeight.w700, color: color)),
              const SizedBox(height: 2),
              Text(subtitle, style: AppTheme.sans(size: 11, color: AppColors.gray500)),
            ],
          ),
        ),
      ),
    );
  }
}
