import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:logistix/core/constants/colors.dart';
import 'package:logistix/core/utils/extensions/context_extension.dart';
import 'dart:core';

class PriceSelectorField extends StatelessWidget {
  final TextEditingController controller;

  const PriceSelectorField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [
        CurrencyTextInputFormatter.simpleCurrency(
          enableNegative: false,
          inputDirection: InputDirection.left,
        ),
      ],
      onTapOutside: (event) => FocusScope.of(context).unfocus(),
      decoration: InputDecoration(
        hintText: 'How much does it cost?',
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 16, right: 12),
          child: Text(
            "₦",
            style: TextStyle(
              fontSize: 20,
              color: context.isDarkTheme ? AppColors.blueGrey[200] : null,
            ),
          ),
        ),
        prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
      ),
    );
  }
}
