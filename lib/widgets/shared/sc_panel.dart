import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_theme.dart';

class ScPanel extends StatelessWidget {
  final String title;
  final Widget? icon;
  final List<Widget>? actions;
  final Widget body;
  final EdgeInsets? bodyPadding;

  const ScPanel({
    super.key,
    required this.title,
    this.icon,
    this.actions,
    required this.body,
    this.bodyPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.panelBg,
        border: Border.all(color: AppColors.borderColor),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 4, offset: const Offset(0, 1))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bounded = constraints.hasBoundedHeight;
            final bodyWidget = bodyPadding != null
                ? Padding(padding: bodyPadding!, child: body)
                : body;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Header(title: title, icon: icon, actions: actions),
                bounded ? Expanded(child: bodyWidget) : bodyWidget,
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final Widget? icon;
  final List<Widget>? actions;
  const _Header({required this.title, this.icon, this.actions});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.gray100)),
      ),
      child: Row(
        children: [
          if (icon != null) ...[icon!, const SizedBox(width: 7)],
          Text(title, style: AppTheme.sans(size: 13, weight: FontWeight.w700, color: AppColors.gray900)),
          const Spacer(),
          if (actions != null && actions!.isNotEmpty)
            Row(mainAxisSize: MainAxisSize.min, children: actions!.expand((w) => [w, const SizedBox(width: 8)]).toList()..removeLast()),
        ],
      ),
    );
  }
}
