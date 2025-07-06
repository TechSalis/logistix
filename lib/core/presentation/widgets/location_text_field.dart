import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logistix/core/utils/router.dart';
import 'package:logistix/features/location_core/domain/entities/address.dart';
import 'package:logistix/features/permission/application/permission_rp.dart';
import 'package:logistix/features/permission/presentation/widgets/permission_dialog.dart';

class LocationTextField extends ConsumerWidget {
  const LocationTextField({
    super.key,
    required this.controller,
    required this.decoration,
    this.showLocationPicker = true,
    this.onAddressPicked,
    this.onChanged,
  });

  final TextEditingController controller;
  final InputDecoration decoration;
  final bool showLocationPicker;

  final void Function(Address address)? onAddressPicked;
  final void Function(String value)? onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget textField = TextField(
      controller: controller,
      decoration: decoration,
      onChanged: onChanged,
      inputFormatters: [LengthLimitingTextInputFormatter(255)],
      onTapOutside: (_) => FocusScope.of(context).unfocus(),
    );

    if (showLocationPicker) {
      final permissionState = ref.watch(
        permissionProvider(PermissionData.location),
      );
      if (permissionState.value?.isGranted ?? false) {
        Future<void> openLocationPicker() async {
          final result = await const LocationPickerPageRoute().push<Address>(
            context,
          );
          
          if (result != null) {
            controller.text = result.formatted;
            onAddressPicked?.call(result);
          }
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
    }
    return textField;
  }
}
