import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logistix/core/constants/colors.dart';
import 'package:logistix/core/utils/extensions/context_extension.dart';

class PriceSelectorField extends StatefulWidget {
  final ValueChanged<int> onChanged;
  final int? initialValue;

  const PriceSelectorField({
    super.key,
    required this.onChanged,
    this.initialValue,
  });

  @override
  State<PriceSelectorField> createState() => _PriceSelectorFieldState();
}

class _PriceSelectorFieldState extends State<PriceSelectorField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialValue?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onManualInput(String value) {
    final parsed = int.tryParse(value);
    if (parsed != null) widget.onChanged(parsed);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Price (₦)*', style: Theme.of(context).textTheme.titleMedium),
        SizedBox(height: 8),
        TextFormField(
          controller: _controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onTapOutside: (event) => FocusScope.of(context).unfocus(),
          decoration: InputDecoration(
            hintText: 'E.g. 5000',
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
          onChanged: _onManualInput,
        ),
      ],
    );
  }
}
