import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef FormValidatorProvider =
    AutoDisposeFamilyNotifierProvider<
      FormValidatorNotifier,
      String?,
      TextEditingController
    >;

typedef FormValidatorProviderFamily =
    AutoDisposeNotifierProviderFamily<
      FormValidatorNotifier,
      String?,
      TextEditingController
    >;

final class FormValidatorNotifier
    extends AutoDisposeFamilyNotifier<String?, TextEditingController> {
  final String? Function(String value) validator;

  FormValidatorNotifier({required this.validator});

  @override
  String? build(TextEditingController controller) => null;

  void validate() => state = validator(arg.text);
}

mixin FormValidatorGroupLogic {
  Set<FormValidatorProvider> get fields;
  WidgetRef get ref;

  void validateAll() {
    for (final f in fields) {
      ref.read(f.notifier).validate();
    }
  }

  bool get currentValidationState => fields.every((f) => ref.read(f) == null);

  bool validateAndCheck() {
    validateAll();
    return currentValidationState;
  }
}
