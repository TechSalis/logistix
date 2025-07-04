import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logistix/features/location_core/domain/entities/address.dart';
import 'package:logistix/features/location_picker/application/location_picker_rp.dart';
import 'package:logistix/features/location_picker/application/location_search_rp.dart';

class AddressSuggestionsSection extends ConsumerWidget {
  const AddressSuggestionsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      child: CustomScrollView(
        slivers: [
          const SliverPadding(padding: EdgeInsets.only(top: 12)),
          SliverToBoxAdapter(
            child: ListTile(
              leading: const Icon(Icons.my_location),
              title: const Text('Use my location'),
              visualDensity: VisualDensity.compact,
              onTap:
                  ref.read(locationPickerProvider.notifier).getUserCoordinates,
            ),
          ),
          ...?ref.watch(locationSearchProvider).value?.addresses?.map((e) {
            return SliverToBoxAdapter(child: AddressTileWidget(address: e));
          }),
          const SliverPadding(padding: EdgeInsets.only(top: 12)),
        ],
      ),
    );
  }
}

class AddressTileWidget extends ConsumerWidget {
  const AddressTileWidget({super.key, required this.address, this.leading});

  final Widget? leading;
  final Address address;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: leading,
      title: Text(address.formatted),
      visualDensity: VisualDensity.compact,
      trailing: IconButton(
        icon: const Icon(Icons.favorite_outline),
        visualDensity: VisualDensity.compact,
        onPressed: () {},
      ),
      onTap: () {
        ref.read(locationSearchProvider.notifier).getPlaceData(address);
      },
    );
  }
}
