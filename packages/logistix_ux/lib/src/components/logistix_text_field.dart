import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logistix_ux/src/theme/extensions/theme_extensions.dart';
import 'package:logistix_ux/src/tokens/colors.dart';

class LogistixTextField extends StatelessWidget {
  const LogistixTextField({
    required this.icon,
    this.label,
    this.lineCount = 1,
    this.maxLines,
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
    this.onFieldSubmitted,
    this.textInputAction,
    this.readOnly = false,
    this.autofocus = false,
    this.obscureText = false,
    this.enableClear = false,
    this.textCapitalization = TextCapitalization.none,
    super.key,
  });

  final String? label;
  final bool autofocus;
  final int lineCount;
  final int? maxLines;
  final String? initialValue;
  final String? hintText;
  final IconData icon;
  final Widget? suffix;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter> inputFormatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final TextInputAction? textInputAction;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final VoidCallback? onTap;
  final bool readOnly;
  final bool obscureText;
  final bool enableClear;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
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
          onFieldSubmitted: onFieldSubmitted,
          textInputAction: textInputAction,
          validator: validator,
          onTap: onTap,
          readOnly: readOnly,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          obscureText: obscureText,
          textCapitalization: textCapitalization,
          style: context.textTheme.bodyMedium?.semiBold,
          minLines: lineCount,
          maxLines: maxLines ?? lineCount,
          autofocus: autofocus,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            hintText: hintText ?? label,
            prefixIcon: Icon(
              icon,
              size: 18,
              color: LogistixColors.textTertiary,
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 40,
            ),
            suffix: suffix,
            suffixIcon: suffixIcon ??
                (enableClear && controller != null
                    ? ListenableBuilder(
                        listenable: controller!,
                        builder: (context, _) {
                          if (controller!.text.isEmpty) return const SizedBox();
                          return IconButton(
                            icon: const Icon(
                              Icons.cancel_rounded,
                              size: 18,
                              color: LogistixColors.textTertiary,
                            ),
                            onPressed: controller!.clear,
                          );
                        },
                      )
                    : null),
          ),
        ),
      ],
    );
  }
}
