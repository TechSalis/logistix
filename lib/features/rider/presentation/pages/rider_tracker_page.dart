import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logistix/core/utils/extensions/coordinates_extension.dart';
import 'package:logistix/features/location/domain/entities/coordinate.dart';
import 'package:logistix/features/map/presentation/widgets/google_map_widget.dart';
import 'package:logistix/features/rider/application/track_rider_rp.dart';
import 'package:logistix/features/rider/domain/entities/rider.dart';
import 'package:logistix/features/rider/presentation/widgets/rider_card_small.dart';

class RiderTrackerPage extends StatefulWidget {
  const RiderTrackerPage({super.key, required this.rider});
  final Rider rider;

  @override
  State<RiderTrackerPage> createState() => _RiderTrackerPageState();
}

class _RiderTrackerPageState extends State<RiderTrackerPage> {
  GoogleMapController? map;
  bool? followMarkerState = true;
  Offset? tapDownPosition;

  void _trackUser(Coordinates? val) {
    if (val != null) map?.animateCamera(CameraUpdate.newLatLng(val.toPoint()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Colors.transparent,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Consumer(
              builder: (context, ref, child) {
                ref.listen(trackRiderProvider(widget.rider), (p, n) {
                  if (followMarkerState == true) _trackUser(n.value);
                });
                return Listener(
                  onPointerDown: (event) {
                    tapDownPosition = event.position;
                    //Dont update UI yet to show track location hutton
                    if (followMarkerState == true) {
                      followMarkerState = false;
                    } else {
                      followMarkerState = null;
                    }
                  },
                  onPointerUp: (event) {
                    // if (followMarkerState) return;
                    final dx = (tapDownPosition!.dx - event.position.dx).abs();
                    final dy = (tapDownPosition!.dy - event.position.dy).abs();

                    //Now we can update UI to show track location hutton
                    if ((dx < 40 || dy < 40) && followMarkerState == false) {
                      followMarkerState = true;
                    }
                    setState(() {});
                  },
                  child: MapViewWidget(
                    onMapCreated: (m) => map = m,
                    markers: {
                      if (ref.watch(trackRiderProvider(widget.rider)).hasValue)
                        Marker(
                          markerId: const MarkerId('find_rider'),
                          position:
                              ref
                                  .watch(trackRiderProvider(widget.rider))
                                  .value!
                                  .toPoint(),
                        ),
                    },
                  ),
                );
              },
            ),
          ),
          if (followMarkerState != true)
            Positioned(
              right: 16,
              bottom: 140,
              child: Consumer(
                builder: (context, ref, child) {
                  return IconButton(
                    onPressed: () {
                      setState(() => followMarkerState = true);
                      _trackUser(
                        ref.read(trackRiderProvider(widget.rider)).value,
                      );
                    },
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.my_location),
                  );
                },
              ),
            ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: SafeArea(child: RiderCardSmall(rider: widget.rider)),
          ),
        ],
      ),
    );
  }
}
