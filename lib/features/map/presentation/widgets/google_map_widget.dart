import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logistix/core/utils/extensions/coordinates_extension.dart';
import 'package:logistix/features/location_core/domain/entities/coordinate.dart';

class MapViewWidget extends StatefulWidget {
  const MapViewWidget({
    super.key,
    this.initialPosition,
    this.onMapCreated,
    this.onCameraIdle,
    this.markers = const {},
  });

  final Set<Marker> markers;
  final Coordinates? initialPosition;
  final void Function(GoogleMapController map)? onMapCreated;
  final void Function()? onCameraIdle;

  @override
  State<MapViewWidget> createState() => _MapViewWidgetState();
}

class _MapViewWidgetState extends State<MapViewWidget> {
  static const _kInitialPosition = CameraPosition(
    target: LatLng(6.5244, 3.3792),
    zoom: 15,
  );

  String mapTheme = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    rootBundle
        .loadString(
          'assets/json/google_map_theme.${Theme.of(context).brightness.name}.json',
        )
        .then((theme) {
          if (mounted) setState(() => mapTheme = theme);
        });
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: LayoutBuilder(
        builder: (context, consts) {
          return ClipRect(
            clipBehavior: Clip.hardEdge,
            child: OverflowBox(
              maxHeight: consts.maxHeight + 60,
              child: GoogleMap(
                compassEnabled: false,
                mapToolbarEnabled: false,
                zoomControlsEnabled: false,
                myLocationEnabled: false,
                myLocationButtonEnabled: false,
                initialCameraPosition: CameraPosition(
                  target:
                      widget.initialPosition?.toPoint() ??
                      _kInitialPosition.target,
                  zoom: _kInitialPosition.zoom,
                ),
                onMapCreated: widget.onMapCreated,
                onCameraIdle: widget.onCameraIdle,
                markers: widget.markers,
                style: mapTheme,
              ),
            ),
          );
        },
      ),
    );
  }
}
