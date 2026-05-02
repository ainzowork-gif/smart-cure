import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_theme.dart';

class KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  final String? delta;
  final bool deltaUp;
  final Color accentColor;
  final Color iconBg;
  final String emoji;

  const KpiCard({
    super.key,
    required this.label,
    required this.value,
    required this.sub,
    this.delta,
    this.deltaUp = true,
    required this.accentColor,
    required this.iconBg,
    required this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.borderColor),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 4, offset: const Offset(0, 1))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: [
            // Top accent bar
            Positioned(top: 0, left: 0, right: 0, child: Container(height: 3, color: accentColor)),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 19, 18, 16),
              child: Row(
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
                    child: Center(child: Text(emoji, style: const TextStyle(fontSize: 20))),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(label, style: AppTheme.sans(size: 11.5, weight: FontWeight.w500, color: AppColors.gray500)),
                        const SizedBox(height: 2),
                        Text(value, style: AppTheme.sans(size: 22, weight: FontWeight.w700, color: AppColors.gray900)),
                        const SizedBox(height: 1),
                        Text(sub, style: AppTheme.sans(size: 10.5, color: AppColors.gray400)),
                      ],
                    ),
                  ),
                  if (delta != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: deltaUp ? AppColors.green100 : AppColors.red100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        delta!,
                        style: AppTheme.sans(
                          size: 10.5, weight: FontWeight.w600,
                          color: deltaUp ? AppColors.green700 : AppColors.red500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
