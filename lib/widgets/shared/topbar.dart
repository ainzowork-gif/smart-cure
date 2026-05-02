import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_theme.dart';
import '../../providers/app_provider.dart';
import '../../providers/inventory_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Topbar extends ConsumerStatefulWidget {
  final String title;
  final String breadcrumb;
  final List<Widget>? actions;

  const Topbar({super.key, required this.title, required this.breadcrumb, this.actions});

  @override
  ConsumerState<Topbar> createState() => _TopbarState();
}

class _TopbarState extends ConsumerState<Topbar> {
  late Timer _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final expiryCount = (ref.watch(inventoryProvider).valueOrNull ?? []).where((m) => m.isExpired || m.isNearExpiry).length;

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: AppColors.topbarBg,
        border: Border(bottom: BorderSide(color: AppColors.gray200)),
        boxShadow: [BoxShadow(color: Color(0x0A000000), blurRadius: 3, offset: Offset(0, 1))],
      ),
      child: Row(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.title, style: AppTheme.sans(size: 16, weight: FontWeight.w700, color: AppColors.gray900)),
              Text(widget.breadcrumb, style: AppTheme.sans(size: 11.5, color: AppColors.gray400)),
            ],
          ),
          const Spacer(),
          if (widget.actions != null) ...widget.actions!,
          const SizedBox(width: 16),
          // Search
          _SearchBox(),
          const SizedBox(width: 16),
          // Notification bell
          Stack(
            children: [
              Container(
                width: 34, height: 34,
                decoration: BoxDecoration(color: AppColors.gray100, border: Border.all(color: AppColors.gray200), borderRadius: BorderRadius.circular(6)),
                child: const Center(child: Text('🔔', style: TextStyle(fontSize: 15))),
              ),
              if (expiryCount > 0)
                Positioned(
                  top: 5, right: 5,
                  child: Container(
                    width: 7, height: 7,
                    decoration: BoxDecoration(
                      color: AppColors.red500,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.white, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
          // Clipboard
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(color: AppColors.gray100, border: Border.all(color: AppColors.gray200), borderRadius: BorderRadius.circular(6)),
            child: const Center(child: Text('📋', style: TextStyle(fontSize: 15))),
          ),
          const SizedBox(width: 16),
          // Clock
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                DateFormat('HH:mm:ss').format(_now),
                style: AppTheme.mono(size: 14, weight: FontWeight.w700, color: AppColors.blue800),
              ),
              Text(
                DateFormat('EEEE, d MMMM yyyy').format(_now),
                style: AppTheme.sans(size: 10.5, color: AppColors.gray500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SearchBox extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: 210,
      height: 34,
      decoration: BoxDecoration(
        color: AppColors.gray100,
        border: Border.all(color: AppColors.gray200),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          const SizedBox(width: 10),
          const Text('🔍', style: TextStyle(fontSize: 13)),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              onChanged: (v) => ref.read(searchQueryProvider.notifier).state = v,
              style: AppTheme.sans(size: 12.5, color: AppColors.gray700),
              decoration: InputDecoration.collapsed(
                hintText: 'Search medicines, invoices…',
                hintStyle: AppTheme.sans(size: 12.5, color: AppColors.gray400),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
