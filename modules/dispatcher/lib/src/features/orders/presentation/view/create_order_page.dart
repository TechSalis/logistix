import 'package:bootstrap/interfaces/toast/toast_service.dart';
import 'package:bootstrap/interfaces/toast/toast_service_provider.dart';
import 'package:bootstrap/services/equality_filter.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:dispatcher/src/features/orders/presentation/cubit/create_order_cubit.dart';
import 'package:dispatcher/src/features/orders/presentation/cubit/metrics_cubit.dart'; // Corrected import
import 'package:dispatcher/src/features/orders/presentation/cubit/orders_cubit.dart';
import 'package:dispatcher/src/features/riders/presentation/widgets/rider_card.dart';
import 'package:dispatcher/src/presentation/router/dispatcher_routes.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:logistix_ux/logistix_ux.dart';
import 'package:shared/shared.dart';

class CreateOrderPage extends StatelessWidget {
  CreateOrderPage({super.key});

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AddressCubit(),
      child: BlocConsumer<CreateOrderCubit, CreateOrderState>(
        listener: (context, state) {
          if (state.success) {
            context.toast.showToast(
              'Orders created successfully',
              type: ToastType.success,
            );
            context.read<CreateOrderCubit>().reset();
            context.read<MetricsCubit>().loadMetrics();
            context.read<OrdersCubit>().loadInitial();
          } else if (state.error != null) {
            context.toast.showToast(state.error!, type: ToastType.error);
          }
        },
        builder: (context, state) {
          final createOrderCubit = context.read<CreateOrderCubit>();
          return Scaffold(
            appBar: AppBar(
              title: const Text('Create Orders'),
              leading: IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => context.pop(),
              ),
            ),
            body: state.isLoading
                ? const Center(child: LogistixInlineLoader())
                : Form(
                    key: _formKey,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: state.orders.length + 2,
                      // +1 for banner, +1 for add button
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return _AIPromptBanner(
                            onTap: () => context.go(DispatcherRoutes.parseText),
                          );
                        }

                        final orderIndex = index - 1;
                        if (orderIndex == state.orders.length) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: TextButton.icon(
                              onPressed: createOrderCubit.addOrder,
                              icon: const Icon(Icons.add_rounded),
                              label: const Text('Add Another Order'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: LogistixColors.primary,
                              ),
                            ),
                          );
                        }

                        return Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: _OrderInputCard(
                            index: orderIndex,
                            input: state.orders[orderIndex],
                            riders: state.riders,
                            onRemoved: () {
                              createOrderCubit.removeOrder(orderIndex);
                            },
                            onUpdated: (newInput) {
                              createOrderCubit.updateOrder(
                                orderIndex,
                                newInput,
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
            bottomNavigationBar: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: LogistixColors.border)),
              ),
              child: ElevatedButton(
                onPressed: state.isLoading
                    ? null
                    : () {
                        if (_formKey.currentState?.validate() != true) return;
                        createOrderCubit.submit();
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: LogistixColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  state.orders.length > 1
                      ? 'Submit ${state.orders.length} Orders'
                      : 'Submit Order',
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _OrderInputCard extends StatelessWidget {
  const _OrderInputCard({
    required this.index,
    required this.input,
    required this.riders,
    required this.onRemoved,
    required this.onUpdated,
  });

  final int index;
  final OrderCreateInput input;
  final List<Rider> riders;
  final VoidCallback onRemoved;
  final ValueChanged<OrderCreateInput> onUpdated;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: LogistixColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: LogistixColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'ORDER #${index + 1}',
                  style: context.textTheme.labelLarge?.bold.copyWith(
                    color: LogistixColors.primary,
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: index > 0 ? onRemoved : null,
                color: LogistixColors.error,
                icon: const Icon(Icons.delete_outline_rounded),
              ),
            ],
          ),
          const SizedBox(height: 8),
          DropdownSearch<AddressDto>(
            items: (String filter, _) async {
              final cubit = context.read<AddressCubit>();
              final results = await cubit.fetchAddresses(filter);
              if (filter.isNotEmpty &&
                  !results.any((e) => e.address == filter)) {
                return [...results, AddressDto(address: filter)];
              }
              return results;
            },
            itemAsString: (item) => item.address,
            compareFn: EqualityFilter<AddressDto>(
              (value) => value.address,
            ).call,
            selectedItem: input.pickupAddress.isEmpty
                ? null
                : AddressDto(address: input.pickupAddress),
            onChanged: (address) {
              if (address != null) {
                onUpdated(input.copyWith(pickupAddress: address.address));
              }
            },
            suffixProps: const DropdownSuffixProps(
              clearButtonProps: ClearButtonProps(isVisible: true),
              dropdownButtonProps: DropdownButtonProps(isVisible: false),
            ),
            decoratorProps: DropDownDecoratorProps(
              decoration: InputDecoration(
                filled: true,
                fillColor: LogistixColors.background,
                labelText: 'Pickup Address',
                hintText: 'Search pickup address...',
                prefixIcon: const Icon(
                  Icons.location_on_rounded,
                  size: 18,
                  color: LogistixColors.textTertiary,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 40,
                  minHeight: 48,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
            popupProps: PopupProps.menu(
              showSearchBox: true,
              loadingBuilder: (_, _) => const LogistixLoadingIndicator(),
              searchFieldProps: TextFieldProps(
                autofocus: true,
                autocorrect: false,
                decoration: InputDecoration(
                  hintText: 'Start typing address...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            validator: FormBuilderValidators.required(),
          ),
          const SizedBox(height: 12),
          DropdownSearch<AddressDto>(
            items: (String filter, _) async {
              final cubit = context.read<AddressCubit>();
              final results = await cubit.fetchAddresses(filter);
              if (filter.isNotEmpty &&
                  !results.any((e) => e.address == filter)) {
                return [...results, AddressDto(address: filter)];
              }
              return results;
            },
            itemAsString: (item) => item.address,
            compareFn: EqualityFilter<AddressDto>(
              (value) => value.address,
            ).call,
            selectedItem: (input.dropOffAddress?.isEmpty ?? true)
                ? null
                : AddressDto(address: input.dropOffAddress!),
            onChanged: (address) {
              onUpdated(input.copyWith(dropOffAddress: address?.address));
            },
            suffixProps: const DropdownSuffixProps(
              clearButtonProps: ClearButtonProps(isVisible: true),
              dropdownButtonProps: DropdownButtonProps(isVisible: false),
            ),
            decoratorProps: DropDownDecoratorProps(
              decoration: InputDecoration(
                filled: true,
                fillColor: LogistixColors.background,
                labelText: 'Drop-off Address',
                hintText: 'Search drop-off address...',
                prefixIcon: const Icon(
                  Icons.flag_rounded,
                  size: 18,
                  color: LogistixColors.textTertiary,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 40,
                  minHeight: 48,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
            popupProps: PopupProps.menu(
              showSearchBox: true,
              loadingBuilder: (_, _) => const LogistixLoadingIndicator(),
              searchFieldProps: TextFieldProps(
                autofocus: true,
                autocorrect: false,
                decoration: InputDecoration(
                  hintText: 'Start typing address...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _InputField(
            label: 'Order Description',
            initialValue: input.description ?? '',
            hintText: 'e.g. 2 x Large Pizza, fragile item...',
            icon: Icons.description_rounded,
            onChanged: (val) => onUpdated(input.copyWith(description: val)),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 4,
                child: _InputField(
                  label: 'Customer Phone',
                  initialValue: input.customerPhone ?? '',
                  hintText: '0801 234 5678',
                  icon: Icons.phone_rounded,
                  keyboardType: TextInputType.phone,
                  onChanged: (val) {
                    onUpdated(input.copyWith(customerPhone: val));
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: _InputField(
                  label: 'COD Amount',
                  initialValue: input.codAmount?.toString() ?? '',
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
                  onChanged: (val) => onUpdated(
                    input.copyWith(codAmount: double.tryParse(val)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _RiderSelector(
            currentRiderId: input.riderId,
            riders: riders,
            onSelected: (id) => onUpdated(input.copyWith(riderId: id)),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              padding: const EdgeInsets.all(10),
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
            const SizedBox(width: 16),
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
  const _RiderSelector({
    required this.currentRiderId,
    required this.riders,
    required this.onSelected,
  });

  final String? currentRiderId;
  final List<Rider> riders;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    final selectedRider = riders
        .where((r) => r.id == currentRiderId)
        .firstOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Assign Rider',
          style: context.textTheme.labelSmall?.bold.copyWith(
            color: LogistixColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        DropdownSearch<Rider>(
          selectedItem: selectedRider,
          items: (filter, _) {
            return context.read<CreateOrderCubit>().searchRiders(filter);
          },
          itemAsString: (Rider r) => r.fullName,
          onChanged: (Rider? r) => onSelected(r?.id),
          compareFn: EqualityFilter<Rider>((state) => state.id).call,
          decoratorProps: DropDownDecoratorProps(
            decoration: InputDecoration(
              filled: true,
              fillColor: LogistixColors.background,
              hintText: 'Search rider by name...',
              hintStyle: context.textTheme.bodyMedium?.copyWith(
                color: LogistixColors.textTertiary,
              ),
              prefixIcon: const Icon(
                Icons.directions_bike_rounded,
                size: 18,
                color: LogistixColors.textTertiary,
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 40,
                minHeight: 48,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            ),
          ),
          popupProps: PopupProps.menu(
            showSearchBox: true,
            loadingBuilder: (_, _) => const LogistixLoadingIndicator(),
            searchFieldProps: TextFieldProps(
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Type to search...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            itemBuilder: (context, rider, isDisabled, isSelected) {
              return RiderInfoListTile(
                rider: rider,
                enabled: rider.hasLocation,
                isSelected: isSelected,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.label,
    required this.initialValue,
    required this.icon,
    required this.onChanged,
    this.hintText,
    this.inputFormatters = const [],
    this.keyboardType,
  });

  final String label;
  final String initialValue;
  final String? hintText;
  final IconData icon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter> inputFormatters;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.textTheme.labelSmall?.bold.copyWith(
            color: LogistixColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          initialValue: initialValue,
          onChanged: onChanged,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: context.textTheme.bodyMedium?.semiBold,
          decoration: InputDecoration(
            filled: true,
            isDense: true,
            hintText: hintText,
            hintStyle: context.textTheme.bodyMedium?.copyWith(
              color: LogistixColors.textTertiary,
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 40,
              minHeight: 48,
            ),
            prefixIcon: Icon(
              icon,
              size: 18,
              color: LogistixColors.textTertiary,
            ),
            fillColor: LogistixColors.background,
          ),
        ),
      ],
    );
  }
}
