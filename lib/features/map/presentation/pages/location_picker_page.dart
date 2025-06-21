import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logistix/core/constants/styling.dart';
import 'package:logistix/core/utils/extensions/coordinates.dart';
import 'package:logistix/features/map/presentation/widgets/map_view.dart';
import 'package:logistix/core/domain/entities/coordinate.dart';
import 'package:logistix/features/map/presentation/logic/location_picker_rp.dart';
import 'package:logistix/features/map/presentation/logic/location_search_rp.dart';
import 'package:logistix/features/map/presentation/widgets/addresses_list.dart';
import 'package:logistix/features/map/presentation/widgets/location_pin.dart';
import 'package:logistix/features/permission/presentation/logic/permission_rp.dart';
import 'package:logistix/features/permission/presentation/widgets/permission_dialog.dart';

enum _ExpandedState { none, search }

class LocationPickerPage extends ConsumerStatefulWidget {
  const LocationPickerPage({super.key});

  @override
  ConsumerState<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends ConsumerState<LocationPickerPage> {
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
                title: Text(
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  'Drag to position marker',
                ),
                actions: [
                  Consumer(
                    builder: (context, ref, child) {
                      return IconButton.filled(
                        onPressed:
                            ref.watch(locationPickerProvider).value?.address !=
                                    null
                                ? () {
                                  Navigator.of(context).pop(
                                    ref
                                        .read(locationPickerProvider)
                                        .value!
                                        .address,
                                  );
                                  ref.invalidate(locationPickerProvider);
                                }
                                : null,
                        icon: Icon(Icons.check),
                        style: IconButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary,
                        ),
                      );
                    },
                  ),
                ],
              ),
      body: Column(
        children: [
          Expanded(
            child: _MapSection(
              isLocationGranted:
                  ref
                      .watch(permissionProvider(PermissionData.location))
                      .value!
                      .isGranted,
            ),
          ),
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
  const _MapSection({required this.isLocationGranted});
  final bool isLocationGranted;

  @override
  ConsumerState<_MapSection> createState() => _MapSectionState();
}

class _MapSectionState extends ConsumerState<_MapSection> {
  GoogleMapController? map;

  void onMapCreated(GoogleMapController map) async {
    this.map = map;
  }

  Future<Coordinates> getCenter(GoogleMapController map) async {
    final bounds = await map.getVisibleRegion();
    final centerLatLng = LatLng(
      (bounds.northeast.latitude + bounds.southwest.latitude) * .5,
      (bounds.northeast.longitude + bounds.southwest.longitude) * .5,
    );

    return centerLatLng.toCoordinates();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(locationSearchProvider, (p, n) {
      if (n.value?.place?.address.coordinates != null) {
        ref
            .read(locationPickerProvider.notifier)
            .setAddress(n.requireValue.place!.address);
        map?.animateCamera(
          CameraUpdate.newLatLng(
            n.requireValue.place!.address.coordinates!.toPoint(),
          ),
        );
      }
    });
    if (!widget.isLocationGranted) return MapView(onMapCreated: onMapCreated);
    return Stack(
      children: [
        MapView(onMapCreated: onMapCreated),
        Center(
          child: Transform.translate(
            offset: Offset(0, -15),
            child: const LocationPin(size: 40),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 4,
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
                return InputChip(
                  side: BorderSide.none,
                  label: Text('Loading...'),
                );
              }
              return ActionChip.elevated(
                label: Text('Select'),
                onPressed: () async {
                  final position = await getCenter(map!);
                  ref
                      .read(locationPickerProvider.notifier)
                      .onMapMoved(position);
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
          SizedBox(height: 12),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
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
                        prefixIcon: Icon(Icons.search),
                        suffixIcon:
                            controller.text.isEmpty
                                ? null
                                : GestureDetector(
                                  onTap: controller.clear,
                                  child: Icon(Icons.clear),
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
          SizedBox(height: 12),
          Divider(height: 1),
          const Flexible(child: AddressSuggestionsSection()),
        ],
      ),
    );
  }
}
