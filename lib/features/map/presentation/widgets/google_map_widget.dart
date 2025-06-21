import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapViewWidget extends StatefulWidget {
  const MapViewWidget({super.key, this.onMapCreated, this.onCameraIdle, required this.markers});

  final Set<Marker> markers;
  final void Function(GoogleMapController map)? onMapCreated;
  final void Function()? onCameraIdle;

  @override
  State<MapViewWidget> createState() => _MapViewWidgetState();
}

class _MapViewWidgetState extends State<MapViewWidget> {
  static const _kGooglePlex = CameraPosition(
    target: LatLng(6.5244, 3.3792),
    zoom: 15,
  );

  String mapTheme = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _getMapTheme();
  }

  _getMapTheme() {
    DefaultAssetBundle.of(context)
        .loadString(
          'assets/json/google_map_theme.${Theme.of(context).brightness.name}.json',
        )
        .then((theme) {
          if (mounted) setState(() => mapTheme = theme);
        });
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      compassEnabled: false,
      mapToolbarEnabled: false,
      zoomControlsEnabled: false,
      zoomGesturesEnabled: false,
      tiltGesturesEnabled: false,
      myLocationEnabled: false,
      myLocationButtonEnabled: false,
      markers: widget.markers,
      initialCameraPosition: _kGooglePlex,
      onMapCreated: widget.onMapCreated,
      onCameraIdle: widget.onCameraIdle,
      style: mapTheme,
    );
  }
}
