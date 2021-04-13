import 'package:beaconflutter/providers/map_type_state_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class BeaconGoogleMap extends ConsumerWidget {
  const BeaconGoogleMap({
    this.onMapCreated,
    @required this.initialTarget,
    this.marker,
    this.circle,
    this.polyline,
  });
  final Function(GoogleMapController) onMapCreated;
  final LatLng initialTarget;
  final Marker marker;
  final Circle circle;
  final Polyline polyline;

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final mapType = watch(beaconMapTypeProvider);

    return GoogleMap(
      mapType:
          mapType == BeaconMapType.normal ? MapType.normal : MapType.hybrid,
      onMapCreated: onMapCreated,
      zoomControlsEnabled: false,
      initialCameraPosition: CameraPosition(
        target: initialTarget,
        zoom: 14.4746,
      ),
      markers: Set.of((marker != null) ? [marker] : []),
      circles: Set.of((circle != null) ? [circle] : []),
      polylines: Set.of((polyline != null) ? [polyline] : []),
    );
  }
}
