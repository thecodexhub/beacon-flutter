import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  StreamSubscription _locationSubscription;
  GoogleMapController mapController;
  Location _location = Location();
  Marker marker;
  Circle circle;

  final LatLng _center = const LatLng(22.06046, 88.10975);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<Uint8List> getMarker() async {
    ByteData byteData =
        await DefaultAssetBundle.of(context).load('assets/arrow_pointer.png');
    return byteData.buffer.asUint8List();
  }

  void updateMarkerAndCircle(Uint8List imageData, LocationData location) {
    LatLng latLng = LatLng(location.latitude, location.longitude);
    this.setState(() {
      marker = Marker(
        markerId: MarkerId('arrow-head'),
        position: latLng,
        rotation: location.heading,
        draggable: false,
        zIndex: 2,
        flat: true,
        anchor: Offset(0.5, 0.5),
        icon: BitmapDescriptor.defaultMarker,
      );
      circle = Circle(
        circleId: CircleId('arrow-circle'),
        radius: location.accuracy,
        center: latLng,
        zIndex: 1,
        strokeColor: Colors.blue,
        fillColor: Colors.blue.withAlpha(70),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your location'),
      ),
      body: GoogleMap(
        mapType: MapType.hybrid,
        onMapCreated: _onMapCreated,
        zoomControlsEnabled: false,
        initialCameraPosition: CameraPosition(
          target: _center,
          zoom: 14.4746,
        ),
        markers: Set.of((marker != null) ? [marker] : []),
        circles: Set.of((circle != null) ? [circle] : []),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          getCurrentLocation();
        },
        backgroundColor: Colors.white,
        child: Icon(
          Icons.my_location,
          color: Colors.black,
        ),
      ),
    );
  }

  void getCurrentLocation() async {
    try {
      Uint8List imageData = await getMarker();
      final location = await _location.getLocation();
      // Update the Marker and Circle in the Google Maps according to user location
      updateMarkerAndCircle(imageData, location);

      if (_locationSubscription != null) _locationSubscription.cancel();

      _locationSubscription = _location.onLocationChanged.listen((newLocation) {
        if (mapController != null) {
          mapController.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(newLocation.latitude, newLocation.longitude),
                bearing: 192.8334901395799,
                tilt: 0,
                zoom: 14.4746,
              ),
            ),
          );
          updateMarkerAndCircle(imageData, newLocation);
        }
      });
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        debugPrint('Permission denied');
      }
    }
  }
}
