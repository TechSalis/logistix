import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logistix_ux/src/theme/extensions/theme_extensions.dart';
import 'package:logistix_ux/src/tokens/colors.dart';

class LogistixTextField extends StatelessWidget {
  const LogistixTextField({
    required this.label,
    required this.icon,
    this.lineCount = 1,
    this.initialValue,
    this.onChanged,
    this.hintText,
    this.inputFormatters = const [],
    this.keyboardType,
    this.suffixIcon,
    this.controller,
    this.validator,
    this.obscureText = false,
    this.textCapitalization = TextCapitalization.none,
    super.key,
  });

  final String label;
  final int lineCount;
  final String? initialValue;
  final String? hintText;
  final IconData icon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter> inputFormatters;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.textTheme.labelSmall?.bold.copyWith(
            color: LogistixColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          initialValue: controller == null ? initialValue : null,
          onChanged: onChanged,
          validator: validator,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          obscureText: obscureText,
          textCapitalization: textCapitalization,
          style: context.textTheme.bodyMedium?.semiBold,
          minLines: lineCount,
          maxLines: lineCount,
          decoration: InputDecoration(
            filled: true,
            isDense: true,
            hintText: hintText ?? label,
            hintStyle: context.textTheme.bodyMedium?.copyWith(
              color: LogistixColors.textSecondary,
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 40,
              minHeight: 48,
            ),
            prefixIcon: Icon(
              icon,
              size: 18,
              color: LogistixColors.textTertiary,
            ),
            suffixIcon: suffixIcon,
            fillColor: LogistixColors.background,
          ),
        ),
      ],
    );
  }
}
