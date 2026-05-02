import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_theme.dart';

class ScTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final TextInputType? keyboardType;
  final bool obscure;
  final int? maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final bool readOnly;
  final Widget? suffix;
  final Widget? prefix;
  final FocusNode? focusNode;

  const ScTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.validator,
    this.onChanged,
    this.keyboardType,
    this.obscure = false,
    this.maxLines = 1,
    this.inputFormatters,
    this.readOnly = false,
    this.suffix,
    this.prefix,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(label!, style: AppTheme.sans(size: 12, weight: FontWeight.w600, color: AppColors.gray700)),
          const SizedBox(height: 5),
        ],
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          validator: validator,
          onChanged: onChanged,
          keyboardType: keyboardType,
          obscureText: obscure,
          maxLines: maxLines,
          inputFormatters: inputFormatters,
          readOnly: readOnly,
          style: AppTheme.sans(size: 13, color: AppColors.gray900),
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: suffix,
            prefixIcon: prefix,
            isDense: true,
          ),
        ),
      ],
    );
  }
}

class ScDropdown<T> extends StatelessWidget {
  final String? label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;

  const ScDropdown({super.key, this.label, this.value, required this.items, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(label!, style: AppTheme.sans(size: 12, weight: FontWeight.w600, color: AppColors.gray700)),
          const SizedBox(height: 5),
        ],
        DropdownButtonFormField<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          style: AppTheme.sans(size: 13, color: AppColors.gray900),
          decoration: const InputDecoration(isDense: true),
        ),
      ],
    );
  }
}
