import 'package:logistix/features/form_validator/application/form_validator_rp.dart';


final requiredValidatorProvider = FormValidatorProviderFamily(
  () => FormValidatorNotifier(validator: FormValidators.required),
);

abstract final class FormValidators {
  static String? required(String value) {
    if (value.isEmpty) return 'This field is required';
    return null;
  }
}
