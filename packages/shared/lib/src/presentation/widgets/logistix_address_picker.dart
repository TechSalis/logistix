import 'package:bootstrap/services/equality_filter.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logistix_ux/logistix_ux.dart';
import 'package:shared/shared.dart';

class LogistixAddressPicker extends StatefulWidget {
  const LogistixAddressPicker({
    required this.labelText,
    required this.hintText,
    required this.address,
    required this.placeId,
    required this.icon,
    required this.onChanged,
    this.validator,
    this.isRequired = false,
    super.key,
  });

  final String labelText;
  final String hintText;
  final String? address;
  final String? placeId;
  final IconData icon;
  final ValueChanged<AddressDto?> onChanged;
  final String? Function(AddressDto?)? validator;
  final bool isRequired;

  @override
  State<LogistixAddressPicker> createState() => _LogistixAddressPickerState();
}

class _LogistixAddressPickerState extends State<LogistixAddressPicker> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.address);
  }

  @override
  void didUpdateWidget(covariant LogistixAddressPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.address != oldWidget.address) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _searchController.text = widget.address ?? '';
        }
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasAddress = widget.address != null && widget.address!.isNotEmpty;
    final isUnresolved = hasAddress && widget.placeId == null;

    return DropdownSearch<AddressDto>(
      items: (String filter, _) async {
        final cubit = context.read<AddressCubit>();
        final results = await cubit.fetchAddresses(filter);
        if (filter.isNotEmpty && !results.any((e) => e.address == filter)) {
          return [...results, AddressDto(address: filter)];
        }
        return results;
      },
      itemAsString: (item) => item.address,
      compareFn: EqualityFilter<AddressDto>((value) => value.address).call,
      selectedItem: hasAddress ? AddressDto(address: widget.address!) : null,
      onChanged: widget.onChanged,
      suffixProps: const DropdownSuffixProps(
        clearButtonProps: ClearButtonProps(isVisible: true),
        dropdownButtonProps: DropdownButtonProps(isVisible: false),
      ),
      decoratorProps: DropDownDecoratorProps(
        decoration: InputDecoration(
          isDense: true,
          fillColor: isUnresolved
              ? LogistixColors.warning.withValues(alpha: 0.1)
              : widget.isRequired && !hasAddress
              ? LogistixColors.primary.withValues(alpha: 0.03)
              : null, // Let theme handle it
          label: widget.isRequired
              ? Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: widget.labelText),
                      const TextSpan(
                        text: ' *',
                        style: TextStyle(color: LogistixColors.error),
                      ),
                    ],
                  ),
                )
              : null,
          labelText: widget.isRequired ? null : widget.labelText,
          labelStyle: isUnresolved
              ? const TextStyle(color: LogistixColors.warning)
              : widget.isRequired && !hasAddress
              ? const TextStyle(color: LogistixColors.primary)
              : null,
          hintText: widget.hintText,
          helperText: isUnresolved
              ? 'Exact location not found. Please select from list.'
              : null,
          helperStyle: const TextStyle(color: LogistixColors.warning),
          prefixIcon: Icon(
            widget.icon,
            size: 18,
            color: isUnresolved
                ? LogistixColors.warning
                : widget.isRequired && !hasAddress
                ? LogistixColors.primary
                : LogistixColors.textTertiary,
          ),
          border: isUnresolved
              ? OutlineInputBorder(
                  borderRadius: BorderRadius.circular(BootstrapRadii.input),
                  borderSide: const BorderSide(color: LogistixColors.warning),
                )
              : null, // Let theme handle it
          enabledBorder: isUnresolved
              ? OutlineInputBorder(
                  borderRadius: BorderRadius.circular(BootstrapRadii.input),
                  borderSide: const BorderSide(color: LogistixColors.warning),
                )
              : null,
        ),
      ),
      popupProps: PopupProps.menu(
        showSearchBox: true,
        loadingBuilder: (_, _) => const BootstrapLoadingIndicator(),
        searchFieldProps: TextFieldProps(
          controller: _searchController,
          autofocus: true,
          autocorrect: false,
          decoration: const InputDecoration(
            isDense: true,
            hintText: 'Start typing address...',
            prefixIcon: Icon(Icons.search_rounded, size: 20),
          ),
        ),
      ),
      validator: widget.validator,
    );
  }
}
