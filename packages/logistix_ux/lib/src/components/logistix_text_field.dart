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
    this.suffix,
    this.suffixIcon,
    this.controller,
    this.validator,
    this.onTap,
    this.readOnly = false,
    this.autofocus = false,
    this.obscureText = false,
    this.textCapitalization = TextCapitalization.none,
    super.key,
  });

  final String label;
  final bool autofocus;
  final int lineCount;
  final String? initialValue;
  final String? hintText;
  final IconData icon;
  final Widget? suffix;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter> inputFormatters;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final VoidCallback? onTap;
  final bool readOnly;
  final bool obscureText;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label,
            style: context.textTheme.labelSmall?.bold.copyWith(
              color: LogistixColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
        ],
        TextFormField(
          controller: controller,
          initialValue: controller == null ? initialValue : null,
          onChanged: onChanged,
          validator: validator,
          onTap: onTap,
          readOnly: readOnly,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          obscureText: obscureText,
          textCapitalization: textCapitalization,
          style: context.textTheme.bodyMedium?.semiBold,
          minLines: lineCount,
          maxLines: lineCount,
          autofocus: autofocus,
          decoration: InputDecoration(
            isDense: true,
            hintText: hintText ?? label,
            prefixIcon: Icon(
              icon,
              size: 18,
              color: LogistixColors.textTertiary,
            ),
            suffix: suffix,
            suffixIcon: suffixIcon,
            // Use standard border and design from theme
          ),
        ),
      ],
    );
  }
}
