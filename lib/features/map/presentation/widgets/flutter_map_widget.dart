import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:latlong2/latlong.dart';
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

class _MapViewWidgetState extends State<MapViewWidget> {
  final mapController = MyMapController();
  String mapTheme = '';

  @override
  void didUpdateWidget(covariant MapViewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialPosition != null &&
        widget.initialPosition != oldWidget.initialPosition) {
      mapController.setPosition(widget.initialPosition!);
    }
  }

  @override

  void didChangeDependencies() {
    super.didChangeDependencies();
    rootBundle
        .loadString(
          'assets/json/google_map_theme.'
          '${Theme.of(context).brightness.name}.json',
        )
        .then((theme) {
          if (mounted) setState(() => mapTheme = theme);
        });
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
        mapController: mapController.controller,
        options: fm.MapOptions(
          initialZoom: 16,
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
          fm.TileLayer(
            urlTemplate:
                'https://{s}.basemaps.cartocdn.com/{style}/{z}/{x}/{y}{r}.png',
            subdomains: const ['a', 'b', 'c', 'd'],
            additionalOptions: {
              'style': context.isDarkTheme ? 'dark_all' : 'light_all',
            },
            // urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            // subdomains: ['a', 'b', 'c'],
            userAgentPackageName: 'com.techsalis.logistix', // IMPORTANT
          ),
          fm.MarkerLayer(markers: widget.markers),
          // TileLayer(
          //   // Bring your own tiles
          //   urlTemplate:
          //       'https://tile.openstreetmap.org/{z}/{x}/{y}.png', // For demonstration only
          //   userAgentPackageName:
          //       'com.techsalis.logistix', // Add your app identifier
          //   // And many more recommended properties!
          // ),
          // RichAttributionWidget(
          //   // Include a stylish prebuilt attribution widget that meets all requirments
          //   attributions: [
          //     TextSourceAttribution(
          //       'OpenStreetMap contributors',
          //       onTap: () {
          //         return launchUrl(
          //           Uri.parse('https://openstreetmap.org/copyright'),
          //         );
          //       }, // (external)
          //     ),
          //     // Also add images...
          //   ],
          // ),
        ],
      ),
    );
  }
}
