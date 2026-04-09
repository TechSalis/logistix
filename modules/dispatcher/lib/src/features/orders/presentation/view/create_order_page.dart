import 'package:bootstrap/interfaces/toast/toast_service.dart';
import 'package:bootstrap/interfaces/toast/toast_service_provider.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:dispatcher/src/data/dtos/order_create_input.dart';
import 'package:dispatcher/src/features/orders/presentation/cubit/create_order_cubit.dart';
import 'package:dispatcher/src/features/riders/presentation/widgets/rider_dropdown_search.dart';
import 'package:dispatcher/src/presentation/router/dispatcher_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:logistix_ux/logistix_ux.dart';
import 'package:shared/shared.dart';

class CreateOrderPage extends StatefulWidget {
  const CreateOrderPage({super.key});

  @override
  State<CreateOrderPage> createState() => _CreateOrderPageState();
}

class _CreateOrderPageState extends State<CreateOrderPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final createOrderCubit = context.read<CreateOrderCubit>();
    return BlocConsumer<CreateOrderCubit, CreateOrderState>(
      listener: (context, orderState) {
        if (orderState.success) {
          createOrderCubit.reset();
          context.pop();
        } else if (orderState.error != null) {
          context.toast.showToast(orderState.error!, type: ToastType.error);
        }
      },
      builder: (context, orderState) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Create Orders'),
            actions: [
              if (orderState.orders.isNotEmpty && !orderState.isLoading)
                LogistixButton(
                  label: 'Clear',
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    LogistixDialog.show<void>(
                      context: context,
                      title: 'Clear all orders?',
                      content: 'This will remove all orders you have prepared.',
                      primaryActionText: 'Clear All',
                      type: LogistixDialogType.destructive,
                      onPrimaryAction: (context) {
                        createOrderCubit.reset();
                        Navigator.pop(context);
                      },
                      secondaryActionText: 'Cancel',
                    );
                  },
                  type: LogistixButtonType.text,
                ),
            ],
          ),
          body: Form(
            key: _formKey,
            child: ListView.builder(
              key: ValueKey(orderState.formKeyVersion),
              padding: const EdgeInsets.symmetric(
                horizontal: LogistixSpacing.lg,
                vertical: LogistixSpacing.xs,
              ),
              itemCount: orderState.orders.length + 2,
              // +1 for banner, +1 for add button
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _AIPromptBanner(
                    onTap: () => context.push(DispatcherRoutes.parseText),
                  );
                }

                final orderIndex = index - 1;
                if (orderIndex == orderState.orders.length) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: LogistixSpacing.lg,
                    ),
                    child: LogistixButton(
                      onPressed: createOrderCubit.addOrder,
                      icon: Icons.add_rounded,
                      label: 'Add Another Order',
                      type: LogistixButtonType.outline,
                      height: 52,
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.only(top: LogistixSpacing.lg),
                  child: _OrderInputCard(
                    index: orderIndex,
                    input: orderState.orders[orderIndex],
                    onRemoved: orderIndex == 0
                        ? null
                        : () => createOrderCubit.removeOrder(orderIndex),
                    onDuplicated: () =>
                        createOrderCubit.duplicateOrder(orderIndex),
                    onUpdated: (newInput) {
                      createOrderCubit.updateOrder(orderIndex, newInput);
                    },
                  ),
                );
              },
            ),
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: LogistixSpacing.lg,
              vertical: LogistixSpacing.sm,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: LogistixColors.border)),
            ),
            child: LogistixButton(
              onPressed: () {
                if (_formKey.currentState?.validate() != true) return;
                createOrderCubit.submitOrders();
              },
              isLoading: orderState.isLoading,
              label: orderState.orders.length > 1
                  ? 'Submit ${orderState.orders.length} Orders'
                  : 'Submit Order',
            ),
          ),
        );
      },
    );
  }
}

class _OrderInputCard extends StatefulWidget {
  const _OrderInputCard({
    required this.index,
    required this.input,
    required this.onUpdated,
    required this.onDuplicated,
    this.onRemoved,
  });

  final int index;
  final OrderCreateInput input;
  final VoidCallback? onRemoved;
  final VoidCallback onDuplicated;
  final ValueChanged<OrderCreateInput> onUpdated;

  @override
  State<_OrderInputCard> createState() => _OrderInputCardState();
}

class _OrderInputCardState extends State<_OrderInputCard> {
  late bool _isExpanded;

  bool _hasAdditionalDetails() =>
      (widget.input.pickupAddress?.isNotEmpty ?? false) ||
      (widget.input.pickupPhone?.isNotEmpty ?? false) ||
      widget.input.scheduledAt != null;

  @override
  void initState() {
    super.initState();
    _isExpanded = _hasAdditionalDetails();
  }

  @override
  void didUpdateWidget(_OrderInputCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the input changed significantly (e.g. via AI parse), re-evaluate expansion
    if (widget.input != oldWidget.input) {
      if (!_isExpanded) {
        _isExpanded = _hasAdditionalDetails();
      }
    }
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: widget.input.scheduledAt ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          widget.input.scheduledAt ?? DateTime.now(),
        ),
      );

      if (time != null && mounted) {
        widget.onUpdated(
          widget.input.copyWith(
            scheduledAt: DateTime(
              date.year,
              date.month,
              date.day,
              time.hour,
              time.minute,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LogistixCard(
      padding: const EdgeInsets.symmetric(
        horizontal: LogistixSpacing.lg,
        vertical: LogistixSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: LogistixSpacing.sm,
                  vertical: LogistixSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: LogistixColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(LogistixRadii.sm),
                ),
                child: Text(
                  'Order #${widget.index + 1}',
                  style: context.textTheme.labelLarge?.bold.copyWith(
                    color: LogistixColors.primary,
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: widget.onDuplicated,
                color: LogistixColors.primary,
                icon: const Icon(Icons.copy_rounded, size: 20),
                tooltip: 'Duplicate order',
                visualDensity: VisualDensity.compact,
              ),
              if (widget.onRemoved != null)
                IconButton(
                  onPressed: widget.onRemoved,
                  color: LogistixColors.error,
                  icon: const Icon(Icons.delete_outline_rounded, size: 20),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
          const SizedBox(height: LogistixSpacing.sm),
          LogistixAddressPicker(
            labelText: 'Drop-off Address',
            hintText: 'Search drop-off address...',
            address: widget.input.dropOffAddress,
            placeId: widget.input.dropOffPlaceId,
            icon: Icons.flag_rounded,
            isRequired: true,
            validator: FormBuilderValidators.required(),
            onChanged: (address) {
              widget.onUpdated(
                widget.input.copyWith(
                  dropOffAddress: address?.address ?? '',
                  dropOffPlaceId: address?.placeId,
                ),
              );
            },
          ),
          const SizedBox(height: LogistixSpacing.md),
          Row(
            children: [
              Expanded(
                flex: 4,
                child: LogistixTextField(
                  label: 'Drop-off Phone',
                  initialValue: widget.input.dropOffPhone ?? '',
                  hintText: 'Enter phone number',
                  icon: Icons.phone_rounded,
                  keyboardType: TextInputType.phone,
                  onChanged: (val) {
                    widget.onUpdated(widget.input.copyWith(dropOffPhone: val));
                  },
                ),
              ),
              const SizedBox(width: LogistixSpacing.sm),
              Expanded(
                flex: 3,
                child: LogistixTextField(
                  label: 'COD Amount',
                  initialValue: widget.input.codAmount?.toString() ?? '',
                  hintText: '₦ 0.00',
                  icon: Icons.payments_rounded,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    CurrencyTextInputFormatter.simpleCurrency(
                      name: 'NGN',
                      enableNegative: false,
                      decimalDigits: 0,
                    ),
                  ],
                  onChanged: (val) {
                    final stripped = val.replaceAll(RegExp('[^0-9]'), '');
                    widget.onUpdated(
                      widget.input.copyWith(
                        codAmount: double.tryParse(stripped),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: LogistixSpacing.md),
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: LogistixSpacing.xs),
              child: Row(
                children: [
                  Icon(
                    _isExpanded
                        ? Icons.remove_circle_outline_rounded
                        : Icons.add_circle_outline_rounded,
                    size: 18,
                    color: LogistixColors.primary,
                  ),
                  const SizedBox(width: LogistixSpacing.xs),
                  Text(
                    _isExpanded ? 'Show less' : 'Pickup & Schedule',
                    style: context.textTheme.labelMedium?.bold.copyWith(
                      color: LogistixColors.primary,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: LogistixColors.textTertiary,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded) ...[
            const SizedBox(height: LogistixSpacing.md),
            LogistixAddressPicker(
              labelText: 'Pickup Address',
              hintText: 'Search pickup address...',
              address: widget.input.pickupAddress,
              placeId: widget.input.pickupPlaceId,
              icon: Icons.location_on_rounded,
              onChanged: (address) {
                widget.onUpdated(
                  widget.input.copyWith(
                    pickupAddress: address?.address ?? '',
                    pickupPlaceId: address?.placeId,
                  ),
                );
              },
            ),
            const SizedBox(height: LogistixSpacing.md),
            LogistixTextField(
              label: 'Pickup Phone',
              initialValue: widget.input.pickupPhone ?? '',
              hintText: 'Enter phone number',
              icon: Icons.phone_callback_rounded,
              keyboardType: TextInputType.phone,
              onChanged: (val) {
                widget.onUpdated(widget.input.copyWith(pickupPhone: val));
              },
            ),
            const SizedBox(height: LogistixSpacing.md),
            LogistixTextField(
              key: ValueKey('dt_${widget.input.scheduledAt}'),
              label: 'Scheduled Delivery (Optional)',
              initialValue: widget.input.scheduledAt != null
                  ? DateFormat(
                      'MMM dd, yyyy • hh:mm a',
                    ).format(widget.input.scheduledAt!)
                  : '',
              readOnly: true,
              onTap: _pickDateTime,
              hintText: 'Select date & time',
              icon: Icons.calendar_today_rounded,
              // suffix: widget.input.scheduledAt != null
              //     ? IconButton(
              //         icon: const Icon(Icons.close, size: 14),
              //         onPressed: () => widget.onUpdated(
              //           widget.input.copyWith(scheduledAt: null),
              //         ),
              //       )
              //     : null,
            ),
          ],
          const SizedBox(height: LogistixSpacing.md),
          LogistixTextField(
            label: 'Order Description',
            initialValue: widget.input.description ?? '',
            hintText: 'e.g. 2 x Large Pizza, fragile item...',
            icon: Icons.description_rounded,
            onChanged: (val) {
              widget.onUpdated(widget.input.copyWith(description: val));
            },
          ),
          const SizedBox(height: LogistixSpacing.md),
          _RiderSelector(
            selectedRider: widget.input.rider,
            onSelected: (rider) => widget.onUpdated(
              widget.input.copyWith(riderId: rider?.id, rider: rider),
            ),
          ),
        ],
      ),
    );
  }
}

class _AIPromptBanner extends StatelessWidget {
  const _AIPromptBanner({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: LogistixSpacing.md,
        vertical: LogistixSpacing.sm,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            LogistixColors.primary,
            LogistixColors.primary.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: LogistixColors.primary.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(LogistixSpacing.sm),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: LogistixSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Magic Paste',
                    style: context.textTheme.titleMedium?.bold.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Paste plain text to auto-fill orders',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

class _RiderSelector extends StatelessWidget {
  const _RiderSelector({required this.selectedRider, required this.onSelected});

  final Rider? selectedRider;
  final ValueChanged<Rider?> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Assign Rider',
          style: context.textTheme.labelSmall?.bold.copyWith(
            color: LogistixColors.textSecondary,
          ),
        ),
        const SizedBox(height: LogistixSpacing.xs),
        AssignRiderDropdownSearch(
          selectedRider: selectedRider,
          searchRiders: (filter) {
            return context.read<CreateOrderCubit>().searchRiders(filter);
          },
          onChanged: onSelected,
          label: 'Search rider by name...',
        ),
      ],
    );
  }
}
