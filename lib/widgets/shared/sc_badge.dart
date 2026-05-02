import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_theme.dart';

enum BadgeType { success, warning, danger, info, gray }

class ScBadge extends StatelessWidget {
  final String label;
  final BadgeType type;

  const ScBadge(this.label, {super.key, this.type = BadgeType.info});

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (type) {
      BadgeType.success => (AppColors.green100, AppColors.green700),
      BadgeType.warning => (AppColors.amber100, const Color(0xFFB45309)),
      BadgeType.danger  => (AppColors.red100,   const Color(0xFFB91C1C)),
      BadgeType.info    => (AppColors.blue100,  AppColors.blue800),
      BadgeType.gray    => (AppColors.gray100,  AppColors.gray600),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
      child: Text(
        label.toUpperCase(),
        style: AppTheme.sans(size: 10, weight: FontWeight.w700, color: fg),
      ),
    );
  }
}
