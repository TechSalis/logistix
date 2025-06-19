import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final shouldValidateProvider = StateProvider.autoDispose.family<bool, Object>(
  (ref, key) => false,
);

final class FormValidatorNotifier
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

abstract class FormValidators {
  static String? required(String value) {
    if (value.isEmpty) return 'This field is required';
    return null;
  }
}

final class FormValidationData {
  final TextEditingController controller;
  final ProviderListenable<String?> provider;

  FormValidationData(this.controller, this.provider);
}

final class FormValidatorGroup {
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
