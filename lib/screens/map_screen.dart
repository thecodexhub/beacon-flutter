import 'dart:async';
import 'dart:typed_data';

import 'package:beaconflutter/services/location_database.dart';
import 'package:duration_picker/duration_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:random_string/random_string.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  StreamSubscription _locationSubscription;
  GoogleMapController mapController;
  Location _location = Location();
  Duration _duration = Duration(hours: 0, minutes: 0);
  Marker marker;
  Circle circle;
  String passKey;

  bool isCarrying = false;

  LocationDatabase locationDatabase = LocationDatabase();

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
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your location'),
      ),
      body: Stack(
        children: [
          GoogleMap(
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
          isCarrying
              ? Container(
                  margin: const EdgeInsets.all(8.0),
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    color: Colors.white,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: _buildContent(),
                  ),
                )
              : Container(),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "carrybeacon",
            onPressed: () {
              showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) {
                    return StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                        return _buildDialog(context, setState);
                      },
                    );
                  });
            },
            backgroundColor: Colors.white,
            child: Icon(
              Icons.add_circle_outlined,
              color: Colors.indigo,
            ),
          ),
          const SizedBox(height: 12.0),
          FloatingActionButton(
            heroTag: "currentlocation",
            onPressed: () {
              getCurrentLocation();
            },
            backgroundColor: Colors.white,
            child: Icon(
              Icons.my_location,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildContent() {
    return [
      Text(
        'You are currently carrying the beacon',
        style: Theme.of(context).textTheme.headline6,
      ),
      const SizedBox(height: 6.0),
      Row(
        children: [
          Text(
            'Your passkey is: ',
            style: Theme.of(context).textTheme.subtitle1,
          ),
          Text(
            passKey,
            style: Theme.of(context).textTheme.subtitle1.copyWith(
                  color: Colors.indigo,
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(width: 10.0),
          InkWell(
            onTap: () {
              Clipboard.setData(ClipboardData(text: passKey));
              final snackBar = SnackBar(
                content: Text('Copied to Clipboard'),
              );
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            },
            child: Icon(Icons.copy, size: 18.0),
          ),
        ],
      ),
      const SizedBox(height: 8.0),
      Text(
        'Time remaining: ${_duration.toString().substring(0, 7)}',
        style: Theme.of(context).textTheme.subtitle2,
      ),
    ];
  }

  Widget _buildDialog(BuildContext context, StateSetter setState) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: WrapAlignment.center,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: Icon(Icons.clear),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            Text(
              'Select a duration',
              style: Theme.of(context).textTheme.headline6,
            ),
            const SizedBox(height: 10.0),
            DurationPicker(
              duration: _duration,
              onChange: (val) {
                setState(() => _duration = val);
              },
              snapToMins: 5.0,
            ),
            OutlinedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final location = await _location.getLocation();
                setState(() {
                  isCarrying = true;
                  passKey = randomAlphaNumeric(10);
                });
                locationDatabase.createLocationData(
                  passKey,
                  location.latitude.toString(),
                  location.longitude.toString(),
                  location.accuracy,
                  location.heading,
                );
              },
              child: Text(
                'Lets carry it!',
              ),
            ),
          ],
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
      if (isCarrying) {
        locationDatabase.updateLocationData(
          passKey,
          location.latitude.toString(),
          location.longitude.toString(),
          location.accuracy,
          location.heading,
        );
      }

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
          // Update the marker according to the new location
          updateMarkerAndCircle(imageData, newLocation);
          if (isCarrying) {
            locationDatabase.updateLocationData(
              passKey,
              newLocation.latitude.toString(),
              newLocation.longitude.toString(),
              newLocation.accuracy,
              newLocation.heading,
            );
          }
        }
      });
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        debugPrint('Permission denied');
      }
    }
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }
}
