
import 'package:flutter/material.dart';

class AddressSuggestionsList extends StatelessWidget {
  const AddressSuggestionsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (index) => ListTile(
          leading: Icon(Icons.location_pin),
          title: Text('Suggested Address ${index + 1}'),
          onTap: () {},
        ),
      ),
    );
  }
}
