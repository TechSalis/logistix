import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logistix/features/location_core/domain/entities/address.dart';
import 'package:logistix/features/location_picker/application/location_search_rp.dart';

class AddressSuggestionsSection extends ConsumerWidget {
  const AddressSuggestionsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(locationSearchProvider)
        .maybeWhen(
          skipLoadingOnRefresh: true,
          skipLoadingOnReload: true,
          skipError: true,
          orElse: SizedBox.new,
          data: (data) {
            return Material(
              child: ListView.builder(
                addAutomaticKeepAlives: false,
                padding: EdgeInsets.zero,
                itemCount: data.addresses?.length ?? 0,
                itemBuilder: (context, index) {
                  return AddressTileWidget(address: data.addresses![index]);
                },
              ),
            );
          },
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
