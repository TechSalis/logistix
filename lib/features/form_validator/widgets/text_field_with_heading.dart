import 'package:flutter/material.dart';
import 'package:logistix/features/form_validator/application/form_validator_rp.dart';
import 'package:logistix/features/form_validator/widgets/text_validator_provider_forn.dart';

class TextFieldLabelAndErrorDisplayWidget extends StatelessWidget {
  final TextEditingController controller;
  final FormValidatorProviderFamily validatorProvider;
  final Widget label;
  final Widget child;

  const TextFieldLabelAndErrorDisplayWidget({
    super.key,
    required this.controller,
    required this.validatorProvider,
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: DefaultTextStyle(
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold),
                child: label,
              ),
            ),
            const SizedBox(width: 12),
            FormValidatorErrorWidget(
              controller: controller,
              validatorProvider: validatorProvider,
            ),
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
