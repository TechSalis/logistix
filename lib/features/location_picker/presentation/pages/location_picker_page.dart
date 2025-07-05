import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logistix/core/constants/styling.dart';
import 'package:logistix/core/utils/extensions/coordinates_extension.dart';
import 'package:logistix/features/home/presentation/widgets/user_map_view.dart';
import 'package:logistix/features/location_core/domain/entities/coordinate.dart';
import 'package:logistix/features/location_picker/application/location_picker_rp.dart';
import 'package:logistix/features/location_picker/application/location_search_rp.dart';
import 'package:logistix/features/location_picker/presentation/widgets/addresses_list.dart';
import 'package:logistix/features/map/presentation/widgets/location_pin.dart';
import 'package:logistix/features/permission/application/permission_rp.dart';
import 'package:logistix/features/permission/presentation/widgets/permission_dialog.dart';

class LocationPickerPage extends StatefulWidget {
  const LocationPickerPage({super.key});

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
                titleTextStyle: Theme.of(context).textTheme.titleMedium,
                title: const Text('Drag to position marker'),
                actions: [
                  Consumer(
                    builder: (context, ref, child) {
                      final address =
                          ref.watch(locationPickerProvider).value?.address;
                      return IconButton.filled(
                        onPressed:
                            address != null
                                ? () => Navigator.pop(context, address)
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
              child: const _MapSection(),
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
  const _MapSection();

  @override
  ConsumerState<_MapSection> createState() => _MapSectionState();
}

class _MapSectionState extends ConsumerState<_MapSection> {
  GoogleMapController? map;

  Future<Coordinates> getMapCoordinates(GoogleMapController map) async {
    final bounds = await map.getVisibleRegion();
    final center = Coordinates(
      (bounds.northeast.latitude + bounds.southwest.latitude) * .5,
      (bounds.northeast.longitude + bounds.southwest.longitude) * .5,
    );
    return center;
  }

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
      if (coordinates != null) {
        map?.animateCamera(CameraUpdate.newLatLng(coordinates.toPoint()));
      }
    });
    final permission =
        ref.watch(permissionProvider(PermissionData.location)).value;
    if (permission == null || !permission.isGranted) return const UserMapView();
    return Stack(
      children: [
        UserMapView(onMapCreated: (m) => setState(() => map = m)),
        Center(
          child: Transform.translate(
            offset: const Offset(0, -17),
            child: const LocationPin(size: 40),
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
                    ref.watch(locationPickerProvider).value!.address!.formatted,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
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
                  final coordinates = await getMapCoordinates(map!);
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
            padding: const EdgeInsets.symmetric(horizontal: 16),
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
                      onChanged:
                          ref.read(locationSearchProvider.notifier).onInput,
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
