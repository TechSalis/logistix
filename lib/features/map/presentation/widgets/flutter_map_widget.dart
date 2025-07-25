import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:latlong2/latlong.dart';
import 'package:logistix/core/env_config.dart';
import 'package:logistix/core/utils/extensions/widget_extensions.dart';
import 'package:logistix/features/location_core/domain/entities/coordinate.dart';
import 'package:logistix/features/map/presentation/controllers/map_controller.dart';

class MapViewWidget extends StatefulWidget {
  const MapViewWidget({
    super.key,
    this.initialPosition,
    this.markers = const [],
    this.liteModeEnabled = false,
    this.onMapCreated,
    this.onEvent,
  });

  final bool liteModeEnabled;
  final List<fm.Marker> markers;
  final Coordinates? initialPosition;
  final void Function(MyMapController map)? onMapCreated;
  final void Function(fm.MapEventSource event)? onEvent;

  @override
  State<MapViewWidget> createState() => _MapViewWidgetState();
}

class _MapViewWidgetState extends State<MapViewWidget>
    with SingleTickerProviderStateMixin {
  late final MyMapController mapController;

  @override
  void initState() {
    mapController = MyMapController(this);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant MapViewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialPosition != null &&
        widget.initialPosition != oldWidget.initialPosition) {
      mapController.setPosition(widget.initialPosition!);
    }
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: fm.FlutterMap(
        mapController: mapController.map,
        options: fm.MapOptions(
          initialZoom: 14,
          keepAlive: !widget.liteModeEnabled,
          onMapReady: () {
            if (widget.initialPosition != null) {
              mapController.setPosition(widget.initialPosition!);
            }
            widget.onMapCreated?.call(mapController);
          },
          onMapEvent:
              widget.onEvent == null
                  ? null
                  : (e) => widget.onEvent?.call(e.source),
          initialCenter:
              widget.initialPosition?.toPoint() ?? const LatLng(6.5244, 3.3792),
        ),
        children: [
          // fm.TileLayer(
          //   urlTemplate:
          //       'https://{s}.basemaps.cartocdn.com/{style}/{z}/{x}/{y}{r}.png',
          //   subdomains: const ['a', 'b', 'c', 'd'],
          //   additionalOptions: {
          //     'style': context.isDarkTheme ? 'dark_all' : 'light_all',
          //   },
          //   userAgentPackageName: 'com.techsalis.logistix',
          // ),
          // fm.TileLayer(
          //   urlTemplate:
          //       'https://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png',
          //   subdomains: ['a', 'b', 'c'],
          // ),
          fm.TileLayer(
            urlTemplate:
                'https://api.mapbox.com/styles/v1/thispatcher/${context.isDarkTheme ? 'cmdg8ifgf001w01r19boc0vjv' : 'cmdg84wvr00gj01r1d8yo1ia6'}/tiles/256/{z}/{x}/{y}@2x?access_token=${EnvConfig.instance.mapboxApiKey}',
          ),
          // fm.TileLayer(
          //   urlTemplate:
          //       'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
          //   // 'https://api.maptiler.com/maps/streets/{z}/{x}/{y}.png?key=bZn9OQS794DI9eYFiFTW',
          //   // 'https://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png',
          //   // 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          //   subdomains: const ['a', 'b', 'c', 'd'],
          //   additionalOptions: {
          //     'style': context.isDarkTheme ? 'dark_all' : 'light_all',
          //   },
          //   userAgentPackageName: 'com.techsalis.logistix',
          // ),
          fm.MarkerLayer(markers: widget.markers),
        ],
      ),
    );
  }
}
