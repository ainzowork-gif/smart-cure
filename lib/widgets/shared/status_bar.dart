import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_theme.dart';

class StatusBar extends StatelessWidget {
  const StatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 22,
      color: AppColors.blue900,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          _StatusItem(
            child: Row(children: [
              Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.green500, shape: BoxShape.circle)),
              const SizedBox(width: 5),
              Text('Connected · Branch: Main Pharmacy', style: AppTheme.sans(size: 10.5, color: const Color(0x80FFFFFF))),
            ]),
          ),
          const SizedBox(width: 20),
          _StatusItem(child: Text('DB: SmartCureDB · 2 ms', style: AppTheme.sans(size: 10.5, color: const Color(0x80FFFFFF)))),
          const SizedBox(width: 20),
          _StatusItem(child: Text('Last backup: Today 06:00 AM', style: AppTheme.sans(size: 10.5, color: const Color(0x80FFFFFF)))),
          const Spacer(),
          Text('Licensed to: Al-Shifa Pharmacy · License valid until 31 Dec 2026',
              style: AppTheme.sans(size: 10.5, color: const Color(0x80FFFFFF))),
        ],
      ),
    );
  }
}

class _StatusItem extends StatelessWidget {
  final Widget child;
  const _StatusItem({required this.child});

  @override
  Widget build(BuildContext context) => child;
}
