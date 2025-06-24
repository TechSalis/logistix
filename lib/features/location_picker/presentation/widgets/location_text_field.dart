import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logistix/features/location/domain/entities/address.dart';
import 'package:logistix/features/map/application/user_location_rp.dart';
import 'package:logistix/features/location_picker/presentation/pages/location_picker_page.dart';
import 'package:logistix/features/permission/application/permission_rp.dart';
import 'package:logistix/features/permission/presentation/widgets/permission_dialog.dart';

class LocationTextField extends ConsumerWidget {
  const LocationTextField({
    super.key,
    required this.controller,
    required this.decoration,
    this.onAddressPicked,
    this.onChanged,
    this.showLocationPicker = true,
    this.showUseYourLocationButton = false,
  });

  final TextEditingController controller;
  final InputDecoration decoration;
  final bool showLocationPicker;
  final bool showUseYourLocationButton;

  final void Function(Address address)? onAddressPicked;
  final void Function(String value)? onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> openLocationPicker() async {
      final result = await Navigator.of(context).push<Address>(
        MaterialPageRoute(builder: (_) => const LocationPickerPage()),
      );

      if (result != null) {
        controller.text = result.formatted;
        onAddressPicked?.call(result);
      }
    }

    Future<void> useCurrentLocation() async {
      final result = await ref.watch(locationProvider.notifier).getUserAddress();
      if (result != null) {
        controller.text = result.formatted;
        onAddressPicked?.call(result);
      }
    }

    final permissionState = ref.watch(
      permissionProvider(PermissionData.location),
    );
    final permissionGranted = permissionState.value?.isGranted ?? true;

    Widget textField = TextFormField(
      controller: controller,
      decoration: decoration,
      onChanged: onChanged,
      inputFormatters: [LengthLimitingTextInputFormatter(255)],
      onTapOutside: (_) => FocusScope.of(context).unfocus(),
    );

    if (showLocationPicker && permissionGranted) {
      textField = Row(
        children: [
          Expanded(child: textField),
          const SizedBox(width: 4),
          IconButton(
            onPressed: openLocationPicker,
            icon: const Icon(Icons.add_location_alt),
            tooltip: 'Pick location from map',
          ),
        ],
      );
    }
    final permission =
        ref.watch(permissionProvider(PermissionData.location)).value!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        textField,
        if (showUseYourLocationButton && permission.isGranted)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: SizedBox(
              height: 24,
              child: TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  foregroundColor: Theme.of(context).colorScheme.tertiary,
                ),
                onPressed: useCurrentLocation,
                child: const Text('Use your location'),
              ),
            ),
          ),
      ],
    );
  }
}
