import 'package:flutter/material.dart';
import 'package:logistix_ux/logistix_ux.dart';

class LogistixSearchField extends StatelessWidget {
  const LogistixSearchField({
    required this.onChanged,
    this.hintText = 'Search...',
    super.key,
  });

  final ValueChanged<String> onChanged;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return LogistixTextField(
      onChanged: onChanged,
      hintText: hintText,
      icon: Icons.search_rounded,
    );
  }
}
