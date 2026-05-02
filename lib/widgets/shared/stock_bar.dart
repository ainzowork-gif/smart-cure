import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_theme.dart';

class StockBar extends StatelessWidget {
  final int quantity;
  final int maxQuantity;

  const StockBar({super.key, required this.quantity, required this.maxQuantity});

  @override
  Widget build(BuildContext context) {
    final pct = maxQuantity == 0 ? 0.0 : (quantity / maxQuantity).clamp(0.0, 1.0);
    final color = pct < 0.15 ? AppColors.red500 : pct < 0.4 ? AppColors.amber500 : AppColors.green500;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$quantity units', style: AppTheme.sans(size: 10.5, color: AppColors.gray500)),
        const SizedBox(height: 3),
        Container(
          width: 90, height: 5,
          decoration: BoxDecoration(color: AppColors.gray200, borderRadius: BorderRadius.circular(3)),
          child: FractionallySizedBox(
            widthFactor: pct,
            alignment: Alignment.centerLeft,
            child: Container(decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
          ),
        ),
      ],
    );
  }
}
