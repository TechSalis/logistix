import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final shouldValidateProvider = AutoDisposeStateProvider.family<bool, Object>(
  (ref, key) => false,
);

class FormValidatorNotifier
    extends AutoDisposeFamilyNotifier<String?, TextEditingController> {
  final String? Function(String value) validator;

  FormValidatorNotifier({required this.validator});

  @override
  String? build(TextEditingController controller) {
    ref.listen<bool>(shouldValidateProvider(controller), (_, shouldValidate) {
      if (shouldValidate) state = validator(controller.text);
    });
    return null;
  }
}

class FormValidators {
  static String? required(String value) {
    if (value.isEmpty) return 'This field is required';
    return null;
  }
}

class FormValidationData {
  final TextEditingController controller;
  final ProviderListenable<String?> provider;

  FormValidationData(this.controller, this.provider);
}

class FormValidatorGroup {
  final WidgetRef ref;
  final List<FormValidationData> fields;

  FormValidatorGroup(this.ref, this.fields);

  void validateAll() {
    for (final f in fields) {
      ref.refresh(shouldValidateProvider(f.controller).notifier).state = true;
    }
  }

  bool get isValid => fields.every((f) => ref.read(f.provider) == null);

  bool validateAndCheck() {
    validateAll();
    return isValid;
  }
}
