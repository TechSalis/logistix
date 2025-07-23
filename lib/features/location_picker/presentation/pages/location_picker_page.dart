import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:logistix/core/theme/styling.dart';
import 'package:logistix/app/widgets/user_map_view.dart';
import 'package:logistix/features/location_core/domain/entities/address.dart';
import 'package:logistix/features/location_core/domain/entities/coordinate.dart';
import 'package:logistix/features/location_picker/application/location_picker_rp.dart';
import 'package:logistix/features/location_picker/application/location_search_rp.dart';
import 'package:logistix/features/location_picker/presentation/pages/location_picker_params.dart';
import 'package:logistix/features/map/presentation/controllers/map_controller.dart';
import 'package:logistix/features/permission/application/permission_rp.dart';
import 'package:logistix/features/permission/presentation/widgets/permission_dialog.dart';

class LocationPickerPage extends StatefulWidget {
  const LocationPickerPage({super.key, required this.params});
  final LocationPickerPageParams params;

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  bool _searchState = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          _searchState
              ? null
              : AppBar(
                centerTitle: true,
                elevation: 4,
                toolbarHeight: 52,
                titleTextStyle: Theme.of(context).textTheme.titleMedium,
                title: const Text('Drag to position marker'),
                actions: [
                  Consumer(
                    builder: (context, ref, child) {
                      final address =
                          ref.watch(locationPickerProvider).value?.address;
                      return IconButton(
                        onPressed:
                            address != null
                                ? () => GoRouter.of(context).pop(address)
                                : null,
                        icon: const Icon(Icons.check),
                        style: IconButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                        ),
                      );
                    },
                  ),
                ],
              ),
      body: Column(
        children: [
          Expanded(
            flex: _searchState ? 1 : 3,
            child: Listener(
              onPointerDown: (event) {
                setState(() => _searchState = false);
                FocusScope.of(context).unfocus();
              },
              child: _MapSection(heroTag: widget.params.heroTag),
            ),
          ),
          Expanded(
            flex: _searchState ? 3 : 1,
            child: _SearchSection(
              onSearchTapped: () => setState(() => _searchState = true),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapSection extends ConsumerStatefulWidget {
  const _MapSection({this.heroTag});
  final String? heroTag;

  @override
  ConsumerState<_MapSection> createState() => _MapSectionState();
}

class _MapSectionState extends ConsumerState<_MapSection> {
  MyMapController? map;

  Coordinates getMapCoordinates(MyMapController map) => map.getCoordinates();

  @override
  Widget build(BuildContext context) {
    ref.listen(locationSearchProvider, (p, n) {
      final address = n.value?.place?.address;
      if (address?.coordinates != null) {
        ref.read(locationPickerProvider.notifier).setAddress(address!);
      }
    });
    ref.listen(locationPickerProvider, (p, n) {
      final coordinates = n.value?.address?.coordinates;
      if (coordinates != null) map?.animateTo(coordinates);
    });
    final permission = ref.watch(permissionProvider(PermissionData.location));
    if (permission.isGranted == null || !permission.isGranted!) {
      return const UserMapView();
    }
    return Stack(
      children: [
        UserMapView(onMapCreated: (m) => setState(() => map = m)),
        Center(
          child: Transform.translate(
            offset: const Offset(0, -18),
            child:
                widget.heroTag == null
                    ? const LocationPin(size: 42)
                    : Hero(
                      tag: widget.heroTag!,
                      child: const LocationPin(size: 42),
                    ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 8,
          child: Builder(
            builder: (context) {
              if (ref.watch(locationPickerProvider).value?.address != null) {
                return InputChip(
                  side: BorderSide.none,
                  onDeleted: () => ref.invalidate(locationPickerProvider),
                  label: Text(
                    ref.watch(locationPickerProvider).value!.address!.name,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                );
              }
              if (ref.watch(locationPickerProvider).isLoading) {
                return const InputChip(
                  side: BorderSide.none,
                  label: Text('Loading'),
                );
              }
              return ActionChip.elevated(
                label: const Text(
                  'Select',
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: Theme.of(context).colorScheme.primary,
                onPressed: () async {
                  final coordinates = getMapCoordinates(map!);
                  ref
                      .read(locationPickerProvider.notifier)
                      .setCoordinates(coordinates);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SearchSection extends StatefulWidget {
  const _SearchSection({required this.onSearchTapped});
  final VoidCallback onSearchTapped;

  @override
  State<_SearchSection> createState() => _SearchSectionState();
}

class _SearchSectionState extends State<_SearchSection> {
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: context.boxDecorationWithShadow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Padding(
            padding: padding_H16,
            child: ListenableBuilder(
              listenable: controller,
              builder: (context, child) {
                return Consumer(
                  builder: (context, ref, child) {
                    return TextField(
                      controller: controller,
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: 'Search for a place',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon:
                            controller.text.isEmpty
                                ? null
                                : GestureDetector(
                                  onTap: controller.clear,
                                  child: const Icon(Icons.clear),
                                ),
                      ),
                      onChanged: (value) {
                        ref
                            .read(locationSearchProvider.notifier)
                            .onInput(value);
                      },
                      onTap: widget.onSearchTapped,
                    );
                  },
                );
              },
            ),
          ),
          const Flexible(child: AddressSuggestionsSection()),
        ],
      ),
    );
  }
}

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
              title: const Text('My location'),
              visualDensity: VisualDensity.compact,
              onTap: () {
                ref.read(locationPickerProvider.notifier).getUserCoordinates();
              },
            ),
          ),
          ...?ref.watch(locationSearchProvider).value?.addresses?.map((e) {
            return SliverToBoxAdapter(child: AddressTileWidget(address: e));
          }),
          const SliverPadding(padding: EdgeInsets.only(top: 8)),
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
      title: Text(address.name),
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

class LocationPin extends StatelessWidget {
  const LocationPin({super.key, this.size = 32});

  final double size;
  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.location_on,
      size: size,
      color: Theme.of(context).colorScheme.primary,
    );
  }
}
