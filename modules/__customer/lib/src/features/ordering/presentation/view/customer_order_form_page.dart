import 'package:bootstrap/interfaces/toast/toast_service.dart';
import 'package:bootstrap/interfaces/toast/toast_service_provider.dart';
import 'package:bootstrap/services/equality_filter.dart';
import 'package:customer/src/data/dtos/customer_order_input.dart';
import 'package:customer/src/domain/entities/customer_order_type.dart';
import 'package:customer/src/features/ordering/presentation/cubit/customer_address_cubit.dart';
import 'package:customer/src/features/ordering/presentation/cubit/order_form_cubit.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:logistix_ux/logistix_ux.dart';
import 'package:shared/shared.dart';

class CustomerOrderFormPage extends StatefulWidget {
  const CustomerOrderFormPage({required this.orderType, super.key});

  final CustomerOrderType orderType;

  @override
  State<CustomerOrderFormPage> createState() => _CustomerOrderFormPageState();
}

class _CustomerOrderFormPageState extends State<CustomerOrderFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _payloadController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _dropoffPhoneController;

  AddressDto? _pickupLocation;
  AddressDto? _dropoffLocation;
  DateTime? _scheduledAt;

  @override
  void initState() {
    super.initState();
    _payloadController = TextEditingController();
    _descriptionController = TextEditingController();
    _dropoffPhoneController = TextEditingController();
  }

  @override
  void dispose() {
    _payloadController.dispose();
    _descriptionController.dispose();
    _dropoffPhoneController.dispose();
    super.dispose();
  }

  Future<List<AddressDto>> _searchLocation(String filter, bool isPickup) async {
    final types = isPickup
        ? widget.orderType.googlePlaceTypes
        : ['address', 'establishment'];
    return context.read<CustomerAddressCubit>().fetchAddressesWithType(
      filter,
      types,
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_dropoffLocation == null || _pickupLocation == null) {
      context.toast.showToast(
        'Please select valid locations',
        type: ToastType.error,
      );
      return;
    }

    final type = widget.orderType;
    final header = '[${type.name} Order]';
    final payload = _payloadController.text;
    final notes = _descriptionController.text;
    final description =
        '$header\nDetails: $payload${notes.isNotEmpty ? '\nNotes: $notes' : ''}';

    final input = CustomerOrderInput(
      dropOffAddress: _dropoffLocation!.address,
      dropOffPlaceId: _dropoffLocation!.placeId,
      pickupAddress: _pickupLocation!.address,
      pickupPlaceId: _pickupLocation!.placeId,
      dropOffPhone: _dropoffPhoneController.text,
      description: description,
      scheduledAt: _scheduledAt?.toIso8601String(),
    );

    context.read<OrderFormCubit>().submitOrder(input);
  }

  Widget _buildSchedulePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Schedule Delivery (Optional)', style: context.textTheme.labelMedium?.bold),
        const SizedBox(height: BootstrapSpacing.xs),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.calendar_today_rounded, color: LogistixColors.primary),
          title: Text(
            _scheduledAt == null
                ? 'Deliver as soon as possible'
                : 'Deliver at: ${DateFormat('MMM dd, yyyy HH:mm').format(_scheduledAt!)}',
          ),
          trailing: _scheduledAt != null
              ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => _scheduledAt = null),
                )
              : const Icon(Icons.chevron_right),
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 30)),
            );
            if (date != null && mounted) {
              final time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (time != null && mounted) {
                setState(() {
                  _scheduledAt = DateTime(
                    date.year,
                    date.month,
                    date.day,
                    time.hour,
                    time.minute,
                  );
                });
              }
            }
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OrderFormCubit, OrderFormState>(
      listener: (context, state) {
        if (state.error != null) {
          context.toast.showToast(state.error!, type: ToastType.error);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: Text(widget.orderType.title)),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(BootstrapSpacing.lg),
              children: [
                Text('Where from?', style: context.textTheme.titleMedium?.bold),
                const SizedBox(height: BootstrapSpacing.sm),
                _buildLocationDropdown(
                  label: widget.orderType.locationLabel,
                  icon: Icons.store_rounded,
                  isPickup: true,
                  onChanged: (val) => setState(() => _pickupLocation = val),
                ),
                const SizedBox(height: BootstrapSpacing.lg),
                Text(
                  widget.orderType.payloadLabel,
                  style: context.textTheme.labelMedium?.bold.copyWith(
                    color: LogistixColors.textSecondary,
                  ),
                ),
                const SizedBox(height: BootstrapSpacing.xs),
                BootstrapTextField(
                  controller: _payloadController,
                  icon: Icons.list_alt_rounded,
                  hintText: 'Enter order details...',
                  lineCount: 3,
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Required field' : null,
                ),
                const SizedBox(height: BootstrapSpacing.xl),
                Text('Where to?', style: context.textTheme.titleMedium?.bold),
                const SizedBox(height: BootstrapSpacing.sm),
                _buildLocationDropdown(
                  label: 'Delivery Address',
                  icon: Icons.location_on_rounded,
                  isPickup: false,
                  onChanged: (val) => setState(() => _dropoffLocation = val),
                ),
                const SizedBox(height: BootstrapSpacing.lg),
                BootstrapTextField(
                  controller: _dropoffPhoneController,
                  label: 'Recipient Phone',
                  icon: Icons.phone_rounded,
                  keyboardType: TextInputType.phone,
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Required field' : null,
                ),
                const SizedBox(height: BootstrapSpacing.lg),
                BootstrapTextField(
                  controller: _descriptionController,
                  label: 'Extra Instructions',
                  icon: Icons.note_alt_rounded,
                  hintText: 'Any specific delivery instructions...',
                  lineCount: 2,
                ),
                const SizedBox(height: BootstrapSpacing.lg),
                _buildSchedulePicker(),
                const SizedBox(height: BootstrapSpacing.xxl),
                BootstrapButton(
                  onPressed: _submit,
                  label: 'Submit Order',
                  isLoading: state.isLoading,
                ),
                const SizedBox(height: BootstrapSpacing.xxl),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLocationDropdown({
    required String label,
    required IconData icon,
    required bool isPickup,
    required ValueChanged<AddressDto?> onChanged,
  }) {
    return DropdownSearch<AddressDto>(
      items: (filter, _) => _searchLocation(filter, isPickup),
      itemAsString: (item) => item.address,
      compareFn: EqualityFilter<AddressDto>((value) => value.address).call,
      onChanged: onChanged,
      validator: (val) =>
          val == null || val.address.isEmpty ? 'Required field' : null,
      decoratorProps: DropDownDecoratorProps(
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      ),
      popupProps: PopupProps.menu(
        showSearchBox: true,
        loadingBuilder: (_, __) => const BootstrapLoadingIndicator(),
        searchFieldProps: TextFieldProps(
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search $label...',
            prefixIcon: const Icon(Icons.search),
          ),
        ),
      ),
    );
  }
}
