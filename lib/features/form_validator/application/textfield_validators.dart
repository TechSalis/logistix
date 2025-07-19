import 'package:logistix/features/form_validator/application/form_validator_rp.dart';


// ignore: non_constant_identifier_names
final RequiredValidatorProvider = FormValidatorProviderFamily(
  () => FormValidatorNotifier(validator: FormValidators.required),
);

abstract final class FormValidators {
  static String? required(String value) {
    if (value.isEmpty) return 'Required';
    return null;
  }
}
