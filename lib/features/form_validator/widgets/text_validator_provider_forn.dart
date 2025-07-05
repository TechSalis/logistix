import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logistix/features/form_validator/application/form_validator_rp.dart';

class _FormValidatorScope extends InheritedWidget {
  const _FormValidatorScope({
    required super.child,
    required FormValidatorGroupState state,
  }) : _state = state;

  final FormValidatorGroupState _state;

  @override
  bool updateShouldNotify(_FormValidatorScope old) {
    return old._state.fields != _state.fields;
  }
}

class FormValidatorGroupWidget extends ConsumerStatefulWidget {
  const FormValidatorGroupWidget({super.key, required this.child});
  final Widget child;

  static FormValidatorGroupState? maybeOf(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<_FormValidatorScope>();
    return scope?._state;
  }

  static FormValidatorGroupState of(BuildContext context) {
    return maybeOf(context)!;
  }

  @override
  ConsumerState<FormValidatorGroupWidget> createState() =>
      FormValidatorGroupState();
}

class FormValidatorGroupState extends ConsumerState<FormValidatorGroupWidget>
    with FormValidatorGroupLogic {
  final Set<FormValidatorProvider> _fields = {};

  @override
  Set<FormValidatorProvider> get fields => _fields;

  @override
  Widget build(BuildContext context) {
    return _FormValidatorScope(state: this, child: widget.child);
  }

  @override
  bool operator ==(Object other) {
    return other is FormValidatorGroupState && other._fields == _fields;
  }

  @override
  int get hashCode => _fields.hashCode;
}

class FormValidatorErrorWidget extends ConsumerStatefulWidget {
  const FormValidatorErrorWidget({
    super.key,
    required this.controller,
    required this.validatorProvider,
  });
  final TextEditingController controller;
  final FormValidatorProviderFamily validatorProvider;

  @override
  ConsumerState<FormValidatorErrorWidget> createState() =>
      _FormValidatorErrorWidgetState();
}

class _FormValidatorErrorWidgetState
    extends ConsumerState<FormValidatorErrorWidget> {
  @override
  void deactivate() {
    FormValidatorGroupWidget.maybeOf(
      context,
    )?._fields.remove(widget.validatorProvider(widget.controller));
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    final provider = widget.validatorProvider(widget.controller);
    FormValidatorGroupWidget.maybeOf(context)?._fields.add(provider);
    return Text(
      ref.watch(provider) ?? '',
      maxLines: 1,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: Theme.of(context).colorScheme.error,
      ),
    );
  }
}
