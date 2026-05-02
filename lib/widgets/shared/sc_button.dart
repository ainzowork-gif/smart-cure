import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_theme.dart';

enum BtnVariant { primary, secondary, success, danger, ghost }

class ScButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final BtnVariant variant;
  final Widget? icon;
  final bool small;

  const ScButton(
    this.label, {
    super.key,
    required this.onTap,
    this.variant = BtnVariant.secondary,
    this.icon,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    final (bg, fg, border) = switch (variant) {
      BtnVariant.primary  => (AppColors.blue600, AppColors.white, AppColors.blue600),
      BtnVariant.success  => (AppColors.green600, AppColors.white, AppColors.green600),
      BtnVariant.danger   => (AppColors.red500, AppColors.white, AppColors.red500),
      BtnVariant.secondary=> (AppColors.white, AppColors.gray700, AppColors.gray200),
      BtnVariant.ghost    => (Colors.transparent, AppColors.gray600, Colors.transparent),
    };
    final px = small ? 11.0 : 14.0;
    final py = small ? 5.0 : 8.0;
    final fontSize = small ? 11.0 : 13.0;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: EdgeInsets.symmetric(horizontal: px, vertical: py),
        decoration: BoxDecoration(
          color: onTap == null ? AppColors.gray100 : bg,
          border: Border.all(color: onTap == null ? AppColors.gray200 : border),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[icon!, const SizedBox(width: 6)],
            Text(
              label,
              style: AppTheme.sans(
                size: fontSize,
                weight: FontWeight.w600,
                color: onTap == null ? AppColors.gray400 : fg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
