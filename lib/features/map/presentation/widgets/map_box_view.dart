import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class MapViewWidget extends StatelessWidget {
  const MapViewWidget({super.key});

  _onMapCreated(MapboxMap mapboxMap) {
    mapboxMap.gestures.updateSettings(
      GesturesSettings(
        quickZoomEnabled: false,
        pinchToZoomEnabled: false,
        simultaneousRotateAndPinchToZoomEnabled: false,
        doubleTapToZoomInEnabled: false,
        pinchToZoomDecelerationEnabled: false,
      ),
    );
    mapboxMap.location.updateSettings(
      LocationComponentSettings(
        enabled: true,
        pulsingEnabled: true,
        puckBearingEnabled: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MapWidget(
      key: const ValueKey('home-map'),
      onMapCreated: _onMapCreated,
      styleUri: MapboxStyles.LIGHT,
      viewport: FollowPuckViewportState(pitch: 30, zoom: 15.6),
      cameraOptions: CameraOptions(
        center: Point(coordinates: Position(6.465422, 3.406448, 7)),
        pitch: 30,
        zoom: 15.6,
      ),
    );
  }
}
