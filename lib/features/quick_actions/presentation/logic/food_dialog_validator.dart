import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logistix/core/presentation/logic/form_validator_rp.dart';

final descriptionValidatorProvider = AutoDisposeNotifierProviderFamily<
  FormValidatorNotifier,
  String?,
  TextEditingController
>(() => FormValidatorNotifier(validator: FormValidators.required));

final dropoffValidatorProvider = AutoDisposeNotifierProviderFamily<
  FormValidatorNotifier,
  String?,
  TextEditingController
>(() => FormValidatorNotifier(validator: FormValidators.required));

