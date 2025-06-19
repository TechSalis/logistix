import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logistix/features/map/domain/entities/address.dart';
import 'package:logistix/features/map/presentation/pages/location_picker_page.dart';
import 'package:logistix/features/permission/presentation/logic/permission_rp.dart';
import 'package:logistix/features/permission/presentation/widgets/permission_dialog.dart';

class LocationTextField extends ConsumerWidget {
  const LocationTextField({
    super.key,
    required this.decoration,
    required this.controller,
    this.showLocationPicker = true,
  });

  final TextEditingController controller;
  final InputDecoration decoration;
  final bool showLocationPicker;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tf = TextFormField(
      controller: controller,
      decoration: decoration,
      onTapOutside: (event) => FocusScope.of(context).unfocus(),
      inputFormatters: [LengthLimitingTextInputFormatter(255)],
    );
    if (showLocationPicker &&
        (ref
                .watch(permissionProvider(PermissionData.location))
                .value
                ?.isGranted ??
            true)) {
      return Row(
        children: [
          Expanded(child: tf),
          SizedBox(width: 4),
          IconButton(
            onPressed: () async {
              final result = await Navigator.of(context).push<Address>(
                MaterialPageRoute(builder: (context) => LocationPickerPage()),
              );
              if (result != null) controller.text = result.formatted;
            },
            icon: Icon(Icons.add_location_alt),
          ),
        ],
      );
    }
    return tf;
  }
}
