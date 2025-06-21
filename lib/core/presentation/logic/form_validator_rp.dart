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

  void validate() {
    state = validator(arg.text);
  }
}

final class FormValidatorGroup {
  final WidgetRef ref;
  final List<FormValidatorProvider> fields;

  FormValidatorGroup(this.ref, this.fields);

  void validateAll() {
    for (final f in fields) {
      ref.read(f.notifier).validate();
    }
  }

  bool get isValid => fields.every((f) => ref.read(f) == null);

  bool validateAndCheck() {
    validateAll();
    return isValid;
  }
}
