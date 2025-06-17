import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logistix/features/map/domain/entities/coordinate.dart';
import 'package:logistix/features/map/presentation/logic/location_rp.dart';
import 'package:logistix/features/map/presentation/widgets/address_suggestions_list.dart';
import 'package:logistix/features/map/presentation/widgets/location_pin.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

extension PointToCoord on Point {
  Coordinates toCoordinate() {
    return Coordinates(coordinates.lat, coordinates.lng);
  }
}

class LocationPickerPage extends ConsumerStatefulWidget {
  const LocationPickerPage({super.key});

  @override
  ConsumerState<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends ConsumerState<LocationPickerPage> {
  MapboxMap? _map;

  void _onMapCreated(MapboxMap mapboxMap) => _map = mapboxMap;

  void _onCameraIdle(MapIdleEventData data) async {
    final screen = MediaQuery.of(context).size;
    final screenCenter = ScreenCoordinate(
      x: screen.width * .5,
      y: screen.height * .5,
    );
    final center =
        (await _map!.coordinateForPixel(screenCenter)).toCoordinate();
    ref.read(locationPickerProvider.notifier).getAddress(center);
  }

  @override
  void dispose() {
    _map?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final address = ref.watch(locationPickerProvider).address;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    MapWidget(
                      key: const ValueKey('location-picker-map'),
                      onMapCreated: _onMapCreated,
                      onMapIdleListener: _onCameraIdle,
                      styleUri: MapboxStyles.LIGHT,
                      onTapListener: (_) => FocusScope.of(context).unfocus(),
                      viewport: CameraViewportState(zoom: 15.6, pitch: 30),
                    ),
                    const LocationPin(),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  padding: EdgeInsets.all(16.r),
                  child: Column(
                    children: [
                      if (address != null)
                        Text(
                          address.formatted,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      SizedBox(height: 8.h),
                      const AddressSuggestionsList(),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.r),
            child: SafeArea(
              child: Row(
                children: [
                  BackButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).scaffoldBackgroundColor,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search for a place',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
