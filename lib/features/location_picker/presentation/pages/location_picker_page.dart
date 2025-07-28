import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:logistix/app/widgets/user_map_view.dart';
import 'package:logistix/core/theme/styling.dart';
import 'package:logistix/features/location_core/domain/entities/address.dart';
import 'package:logistix/features/location_picker/application/location_picker_rp.dart';
import 'package:logistix/features/location_picker/application/location_search_rp.dart';
import 'package:logistix/features/location_picker/presentation/pages/location_picker_params.dart';

class _AddressTileWidget extends ConsumerWidget {
  const _AddressTileWidget({
    required this.address,
    required this.onTap,
    this.leading,
  });

  final Address address;
  final Widget? leading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      title: Text(address.name),
      visualDensity: VisualDensity.compact,
      leading: leading,
      // trailing: IconButton(
      //   icon: const Icon(Icons.favorite_outline),
      //   visualDensity: VisualDensity.compact,
      //   onPressed: () {},
      // ),
      onTap: onTap,
    );
  }
}

class _LocationPin extends StatelessWidget {
  const _LocationPin({this.size});

  final double? size;
  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.my_location,
      size: size,
      color: Theme.of(context).colorScheme.primary,
    );
  }
}

class _ConfirmButton extends StatelessWidget {
  const _ConfirmButton();

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final address = ref.watch(locationPickerProvider).value?.address;
        return IconButton(
          onPressed:
              address != null ? () => GoRouter.of(context).pop(address) : null,
          icon: const Icon(Icons.check),
          style: IconButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
          ),
        );
      },
    );
  }
}

class _SearchSection extends ConsumerWidget {
  const _SearchSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final addresses = ref.watch(locationSearchProvider).value?.addresses;
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: borderRadius_8,
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Material(
        child: Column(
          children: [
            if (addresses == null || addresses.isEmpty)
              _AddressTileWidget(
                address: const Address("My location"),
                leading: const MyLocationPin(size: 24),
                onTap: ref.read(locationPickerProvider.notifier).pickMyLocation,
              )
            else
              ...addresses.map((e) {
                return _AddressTileWidget(
                  address: e,
                  onTap: () {
                    ref.read(locationPickerProvider.notifier).pickAddress(e);
                  },
                );
              }),
          ],
        ),
      ),
    );
  }
}

class LocationPickerPage extends StatefulWidget {
  const LocationPickerPage({super.key, this.params});
  final LocationPickerPageParams? params;

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  bool _isSearching = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Select Location'),
        actions: const [_ConfirmButton()],
      ),
      body: Stack(
        children: [
          Consumer(
            builder: (context, ref, child) {
              return UserMapView(
                onMapCreated: ref.watch(locationPickerProvider.notifier).setMap,
              );
            },
          ),
          Center(
            child:
                widget.params?.heroTag == null
                    ? const _LocationPin(size: 42)
                    : Hero(
                      tag: widget.params!.heroTag!,
                      child: const _LocationPin(size: 42),
                    ),
          ),
          Padding(
            padding: padding_16,
            child: Column(
              children: [
                Consumer(
                  builder: (context, ref, child) {
                    final controller =
                        ref
                            .read(locationPickerProvider.notifier)
                            .searchController;
                    return TextField(
                      controller: controller,
                      onTap: () {
                        setState(() => _isSearching = true);
                      },
                      onSubmitted: (_) {
                        setState(() => _isSearching = false);
                      },
                      onChanged:
                          ref.read(locationSearchProvider.notifier).onInput,
                      decoration: InputDecoration(
                        hintText: "Search for a location",
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon:
                            ref.watch(locationSearchProvider).isLoading ||
                                    ref.watch(locationPickerProvider).isLoading
                                ? const Padding(
                                  padding: padding_16,
                                  child: SizedBox.square(
                                    dimension: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )
                                : controller.text.isEmpty
                                ? null
                                : IconButton(
                                  onPressed: () {
                                    ref
                                        .read(locationPickerProvider.notifier)
                                        .clearInput();
                                    ref
                                        .watch(locationSearchProvider.notifier)
                                        .onInput('');
                                  },
                                  icon: const Icon(Icons.close),
                                ),
                      ),
                    );
                  },
                ),
                if (_isSearching) const _SearchSection(),
                const Spacer(),
                Consumer(
                  builder: (context, ref, child) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 32),
                      child: ElevatedButton.icon(
                        icon: const _LocationPin(),
                        label: const Text("Select location"),
                        onPressed:
                            ref
                                .read(locationPickerProvider.notifier)
                                .pickCurrentCoordinates,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
