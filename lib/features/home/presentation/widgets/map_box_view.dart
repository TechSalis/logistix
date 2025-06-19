import 'package:flutter/material.dart';
import 'package:logistix/core/utils/extensions/context_extension.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class MapViewWidget extends StatelessWidget {
  const MapViewWidget({super.key, this.onMapCreated, this.viewport});

  final ViewportState? viewport;
  final void Function(MapboxMap map)? onMapCreated;

  @override
  Widget build(BuildContext context) {
    return MapWidget(
      key: ObjectKey(context.isLightTheme),
      viewport: viewport,
      styleUri: context.isLightTheme ? MapboxStyles.LIGHT : MapboxStyles.DARK,
      cameraOptions: CameraOptions(
        center: Point(coordinates: Position(3.3792, 6.5244)),
        zoom: 15.5,
        pitch: 30,
      ),
      onMapCreated: (map) {
        _mapInitialiser(map);
        onMapCreated?.call(map);
      },
    );
  }
}

_mapInitialiser(MapboxMap mapboxMap) {
  mapboxMap.logo.updateSettings(LogoSettings(enabled: false));
  mapboxMap.attribution.updateSettings(AttributionSettings(enabled: false));
  mapboxMap.scaleBar.updateSettings(ScaleBarSettings(enabled: false));
  mapboxMap.compass.updateSettings(CompassSettings(enabled: true));
  mapboxMap.gestures.updateSettings(
    GesturesSettings(scrollDecelerationEnabled: false, zoomAnimationAmount: 0),
  );
  mapboxMap.location.updateSettings(
    LocationComponentSettings(
      enabled: true,
      pulsingEnabled: true,
      puckBearingEnabled: true,
    ),
  );
}
