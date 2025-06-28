import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logistix/core/constants/styling.dart';
import 'package:logistix/core/utils/extensions/coordinates_extension.dart';
import 'package:logistix/features/map/application/usecases/map_moved_usecase.dart';
import 'package:logistix/features/app/presentaion/widgets/user_map_view.dart';
import 'package:logistix/features/location_core/domain/entities/coordinate.dart';
import 'package:logistix/features/location_picker/application/location_picker_rp.dart';
import 'package:logistix/features/location_picker/application/location_search_rp.dart';
import 'package:logistix/features/location_picker/presentation/widgets/addresses_list.dart';
import 'package:logistix/features/map/presentation/widgets/center_user_button.dart';
import 'package:logistix/features/map/presentation/widgets/location_pin.dart';
import 'package:logistix/features/permission/application/permission_rp.dart';
import 'package:logistix/features/permission/presentation/widgets/permission_dialog.dart';

enum _ExpandedState { none, search }

class LocationPickerPage extends StatefulWidget {
  const LocationPickerPage({super.key});

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  _ExpandedState _expandedState = _ExpandedState.none;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          _expandedState == _ExpandedState.search
              ? null
              : AppBar(
                centerTitle: true,
                titleTextStyle: Theme.of(context).textTheme.titleMedium,
                actionsPadding: const EdgeInsets.all(8),
                title: const Text(
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  'Drag to position marker',
                ),
                actions: [
                  Consumer(
                    builder: (context, ref, child) {
                      final address =
                          ref.watch(locationPickerProvider).value?.address;
                      return IconButton.filled(
                        onPressed:
                            address != null
                                ? () {
                                  Navigator.of(context).pop(address);
                                  ref.invalidate(locationPickerProvider);
                                }
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
          const Expanded(child: _MapSection()),
          Expanded(
            flex: _expandedState == _ExpandedState.search ? 3 : 1,
            child: _SearchSection(
              onSearchState: (value) {
                setState(() {
                  _expandedState =
                      value ? _ExpandedState.search : _ExpandedState.none;
                });
              },
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
        map?.animateCamera(
          CameraUpdate.newLatLng(address.coordinates!.toPoint()),
        );
      }
    });
    final permission =
        ref.watch(permissionProvider(PermissionData.location)).value;
    if (permission == null || !permission.isGranted) {
      return UserMapView(onMapCreated: (m) => map = m);
    }
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (map != null)
                Align(
                  alignment: Alignment.centerRight,
                  child: CenterUserOnMapButton(map: map),
                ),
              const SizedBox(height: 8),
              if (ref.watch(locationPickerProvider).value?.address != null)
                InputChip(
                  side: BorderSide.none,
                  onDeleted: () => ref.invalidate(locationPickerProvider),
                  label: Text(
                    ref.watch(locationPickerProvider).value!.address!.formatted,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                )
              else if (ref.watch(locationPickerProvider).isLoading)
                const InputChip(
                  side: BorderSide.none,
                  label: Text('Loading...'),
                )
              else
                ActionChip.elevated(
                  label: const Text('Select'),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  onPressed: () async {
                    MapMovedUsecase(
                      newCoordinates: await getMapCoordinates(map!),
                      provider: ref.read(locationPickerProvider.notifier),
                      address: ref.read(locationPickerProvider).value?.address,
                    ).call();
                  },
                ),
            ],
          ),
        ),
        // Positioned(
        //   right: 8,
        //   bottom: 64,
        //   child: IconButton(
        //     onPressed: () async {
        //       final provider = ref.read(locationProvider.notifier);
        //       await centerUserHelperFunction(map!, provider);
        //     },
        //     style: IconButton.styleFrom(
        //       backgroundColor: Colors.black,
        //       foregroundColor: Colors.white,
        //     ),
        //     icon: const Icon(Icons.my_location),
        //   ),
        // ),
        // Positioned(
        //   left: 0,
        //   right: 0,
        //   bottom: 8,
        //   child: Builder(
        //     builder: (context) {
        //       if (ref.watch(locationPickerProvider).value?.address != null) {
        //         return InputChip(
        //           side: BorderSide.none,
        //           onDeleted: () => ref.invalidate(locationPickerProvider),
        //           label: Text(
        //             ref.watch(locationPickerProvider).value!.address!.formatted,
        //             overflow: TextOverflow.ellipsis,
        //             maxLines: 2,
        //           ),
        //         );
        //       }
        //       if (ref.watch(locationPickerProvider).isLoading) {
        //         return const InputChip(
        //           side: BorderSide.none,
        //           label: Text('Loading...'),
        //         );
        //       }
        //       return ActionChip.elevated(
        //         label: const Text('Select'),
        //         backgroundColor: Theme.of(context).colorScheme.primary,
        //         onPressed: () async {
        //           MapMovedUsecase(
        //             newCoordinates: await getCenter(map!),
        //             provider: ref.read(locationPickerProvider.notifier),
        //             address: ref.read(locationPickerProvider).value?.address,
        //           ).call();
        //         },
        //       );
        //     },
        //   ),
        // ),
      ],
    );
  }
}

class _SearchSection extends StatefulWidget {
  const _SearchSection({required this.onSearchState});
  final Function(bool) onSearchState;

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
                      onSubmitted: (value) => widget.onSearchState(false),
                      onTap: () => widget.onSearchState(true),
                      onTapOutside: (_) {
                        FocusScope.of(context).unfocus();
                        widget.onSearchState(false);
                      },
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const Flexible(child: AddressSuggestionsSection()),
        ],
      ),
    );
  }
}
