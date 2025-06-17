import 'package:flutter/material.dart';
import 'package:logistix/features/map/presentation/pages/location_picker_page.dart';

class LocationTextField extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final tf = TextFormField(
      controller: controller,
      onTapOutside: (event) => FocusScope.of(context).unfocus(),
      decoration: decoration,
    );
    if (!showLocationPicker) return tf;
    return Row(
      children: [
        Expanded(child: tf),
        SizedBox(width: 4),
        IconButton(
          onPressed: () async {
            final result = await Navigator.of(context).push<String>(
              MaterialPageRoute(builder: (context) => LocationPickerPage()),
            );
            if (result != null) controller.text = result;
          },
          icon: Icon(Icons.add_location_alt),
        ),
      ],
    );
  }
}
