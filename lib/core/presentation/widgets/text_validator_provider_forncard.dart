import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logistix/features/form_validator/application/form_validator_rp.dart';
import 'package:logistix/features/quick_actions/presentation/widgets/form_card.dart';

mixin TextValidatorProviderFornCardBuilder {
  Widget textValidatorProviderFornCardBuilder({
    required FormValidatorProvider? validatorProvider,
    required Widget child,
    required String title,
  }) {
    return Consumer(
      builder: (context, ref, child) {
        return FormCard(
          title: title,
          error:
              validatorProvider != null ? ref.watch(validatorProvider) : null,
          child: child!,
        );
      },
      child: child,
    );
  }
}
