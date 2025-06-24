import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/formatters/currency_input_formatter.dart';
import 'package:flutter_multi_formatter/formatters/money_input_enums.dart';
import 'package:logistix/core/constants/colors.dart';
import 'package:logistix/core/utils/extensions/context_extension.dart';
import 'dart:core';

class PriceSelectorField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;

  const PriceSelectorField({
    super.key,
    required this.controller,
    this.hintText = 'How much does it cost?',
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [
        CurrencyInputFormatter(
          thousandSeparator: ThousandSeparator.Comma,
          mantissaLength: 0,
        ),
      ],
      onTapOutside: (event) => FocusScope.of(context).unfocus(),
      decoration: InputDecoration(
        hintText: hintText,
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
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      ),
    );
  }
}
