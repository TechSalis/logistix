import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logistix/core/constants/global_instances.dart';
import 'package:logistix/core/theme/colors.dart';
import 'package:logistix/core/theme/extensions/context_extension.dart';
import 'package:logistix/core/utils/router.dart';
import 'package:logistix/features/location_core/domain/entities/address.dart';

class LocationTextField extends ConsumerWidget {
  const LocationTextField({
    super.key,
    required this.controller,
    required this.decoration,
    this.showLocationPicker = true,
  });

  final TextEditingController controller;
  final InputDecoration decoration;
  final bool showLocationPicker;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget textField = TextField(
      controller: controller,
      decoration: decoration,
      inputFormatters: [LengthLimitingTextInputFormatter(255)],
      onTapOutside: (_) => FocusScope.of(context).unfocus(),
    );

    if (showLocationPicker) {
      Future<void> openLocationPicker() async {
        final result = await const LocationPickerPageRoute().push<Address>(
          context,
        );
        if (result != null) controller.text = result.formatted;
      }

      textField = Row(
        children: [
          Expanded(child: textField),
          IconButton(
            onPressed: openLocationPicker,
            icon: const Icon(Icons.add_location_alt),
          ),
        ],
      );
    }
    return textField;
  }
}

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
        TextInputFormatter.withFunction((oldValue, newValue) {
          return newValue.copyWith(
            text: currencyFormatter.format(newValue.text),
          );
        }),
        // CurrencyInputFormatter(
        //   thousandSeparator: ThousandSeparator.Comma,
        //   mantissaLength: 0,
        // ),
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
              color:
                  context.isDarkTheme ? AppColors.blueGreyMaterial[200] : null,
            ),
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      ),
    );
  }
}
