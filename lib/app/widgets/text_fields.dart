import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logistix/app/router/app_router.dart';
import 'package:logistix/core/constants/objects.dart';
import 'package:logistix/core/theme/colors.dart';
import 'package:logistix/core/utils/extensions/widget_extensions.dart';
import 'package:logistix/features/location_core/domain/entities/address.dart';
import 'package:logistix/features/location_picker/presentation/pages/location_picker_params.dart';

class AddressTextField extends ConsumerStatefulWidget {
  const AddressTextField({
    super.key,
    required this.decoration,
    this.showLocationPicker = true,
    this.enabled = true,
    this.heroTag,
    this.address,
    required this.onAddressChanged,
  });

  final String? heroTag;
  final Address? address;
  final InputDecoration decoration;
  final bool showLocationPicker, enabled;
  final void Function(Address value) onAddressChanged;

  @override
  ConsumerState<AddressTextField> createState() => _AddressTextFieldState();
}

class _AddressTextFieldState extends ConsumerState<AddressTextField> {
  final controller = TextEditingController();
  Address? address;

  @override
  void initState() {
    _updateAddress();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant AddressTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.address != oldWidget.address) _updateAddress();
  }

  void _updateAddress() {
    address = widget.address;
    controller.text = address?.name ?? '';
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget textField = TextFormField(
      enabled: widget.enabled,
      decoration: widget.decoration,
      controller: controller,
      onChanged: (value) {
        value = value.trim();
        widget.onAddressChanged(
          address?.copyWith(name: value) ?? Address(value),
        );
      },
      inputFormatters: [LengthLimitingTextInputFormatter(255)],
      onTapOutside: (_) => FocusScope.of(context).unfocus(),
    );

    if (widget.showLocationPicker) {
      Future<void> openLocationPicker() async {
        final result = await LocationPickerPageRoute(
          LocationPickerPageParams(heroTag: widget.heroTag),
        ).push<Address>(context);
        if (result != null) {
          widget.onAddressChanged(result);
          controller.text = result.name;
        }
      }

      textField = Row(
        children: [
          Expanded(child: textField),
          IconButton(
            visualDensity: const VisualDensity(horizontal: -1),
            icon:
                widget.heroTag == null
                    ? const Icon(Icons.add_location_alt)
                    : Hero(
                      tag: widget.heroTag!,
                      child: const Icon(Icons.add_location_alt),
                    ),
            onPressed: widget.enabled ? openLocationPicker : null,
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
              color: context.isDarkTheme ? AppColors.blueGreyMat[200] : null,
            ),
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      ),
    );
  }
}
