import 'dart:async';

import 'package:beaconflutter/common_widgets/beacon_google_map.dart';
import 'package:beaconflutter/models/beacon.dart';
import 'package:beaconflutter/providers/map_type_state_notifier.dart';
import 'package:beaconflutter/services/location_database.dart';
import 'package:custom_timer/custom_timer.dart';
import 'package:duration_picker/duration_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:random_string/random_string.dart';

class CarryScreen extends StatefulWidget {
  @override
  _CarryScreenState createState() => _CarryScreenState();
}

class _CarryScreenState extends State<CarryScreen> {
  StreamSubscription _locationSubscription;
  GoogleMapController mapController;
  final Location _location = Location();
  Duration _duration = const Duration();
  Marker _marker;
  Circle _circle;
  Polyline _polyline;
  String passKey;

  List<LatLng> points = [];

  bool isCarrying = false;

  final Database _database = BeaconDatabase();

  final LatLng _center = const LatLng(22.06046, 88.10975);

  void _onMapCreated(GoogleMapController controller) =>
      mapController = controller;

  // Future<Uint8List> getMarker() async {
  //   final ByteData byteData =
  //       await DefaultAssetBundle.of(context).load('assets/arrow_pointer.png');
  //   return byteData.buffer.asUint8List();
  // }

  void updateMarkerAndCircle(LocationData location) {
    final LatLng latLng = LatLng(location.latitude, location.longitude);
    setState(() {
      _marker = Marker(
        markerId: MarkerId('arrow-head'),
        position: latLng,
        rotation: location.heading,
        zIndex: 2,
        flat: true,
        anchor: const Offset(0.5, 0.5),
      );
      _circle = Circle(
        circleId: CircleId('arrow-circle'),
        radius: location.accuracy,
        center: latLng,
        zIndex: 1,
        strokeColor: Colors.blue,
        fillColor: Colors.blue.withAlpha(70),
      );
    });
  }

  void updatePolyline(List<LatLng> points) {
    setState(() {
      _polyline = Polyline(
        polylineId: PolylineId('route'),
        points: points,
        width: 5,
        color: Colors.red,
        startCap: Cap.roundCap,
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
        title: const Text('Carry the beacon'),
        actions: [
          IconButton(
            icon: const Icon(Icons.center_focus_strong),
            onPressed: () =>
                context.read(beaconMapTypeProvider.notifier).toggleMapType(),
          ),
        ],
      ),
      body: Stack(
        children: [
          BeaconGoogleMap(
            initialTarget: _center,
            onMapCreated: _onMapCreated,
            marker: _marker,
            circle: _circle,
            polyline: _polyline,
          ),
          if (isCarrying)
            Container(
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
          else
            Container(),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "carrybeacon",
            onPressed: isCarrying
                ? () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Operation Failed'),
                            content: const Text('Already has an active carry.'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('OK'),
                              )
                            ],
                          );
                        });
                  }
                : () {
                    showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) {
                          return StatefulBuilder(
                            builder:
                                (BuildContext context, StateSetter setState) {
                              return _buildDialog(context, setState);
                            },
                          );
                        });
                  },
            backgroundColor: Colors.white,
            child: const Icon(
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
            child: const Icon(
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
              const snackBar = SnackBar(
                content: Text('Copied to Clipboard'),
              );
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            },
            child: const Icon(Icons.copy, size: 18.0),
          ),
        ],
      ),
      const SizedBox(height: 8.0),
      CustomTimer(
        from: _duration,
        to: const Duration(),
        onBuildAction: CustomTimerAction.auto_start,
        builder: (CustomTimerRemainingTime remaining) {
          return Text(
            "Expires in: ${remaining.hours}:${remaining.minutes}:${remaining.seconds}",
            style: Theme.of(context).textTheme.subtitle2,
          );
        },
        onFinish: () {
          setState(() {
            isCarrying = false;
          });
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Passkey expired'),
                  content:
                      const Text('The time for the active passkey is over!'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('OK'),
                    ),
                  ],
                );
              });
        },
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
                icon: const Icon(Icons.clear),
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
              onPressed: _duration > const Duration(minutes: 1)
                  ? () async {
                      Navigator.of(context).pop();
                      final location = await _location.getLocation();
                      setState(() {
                        isCarrying = true;
                        passKey = randomAlphaNumeric(10);
                      });

                      points.add(LatLng(location.latitude, location.longitude));
                      updatePolyline(points);

                      _database.createBeacon(
                        beacon: Beacon(
                          passKey: passKey,
                          latitude: location.latitude,
                          longitude: location.longitude,
                          accuracy: location.accuracy,
                          heading: location.accuracy,
                          points: points.map((e) => e.toJson()).toList(),
                          createdAt: DateTime.now().millisecondsSinceEpoch,
                          duration: _duration.inMilliseconds,
                        ),
                        passKey: passKey,
                      );
                    }
                  : null,
              child: const Text(
                'Lets carry it!',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> getCurrentLocation() async {
    try {
      // Uint8List imageData = await getMarker();
      final location = await _location.getLocation();
      // Update the Marker and Circle in the Google Maps according to user location
      updateMarkerAndCircle(location);
      if (isCarrying) {
        points.add(LatLng(location.latitude, location.longitude));
        updatePolyline(points);

        _database.updateBeacon(
          passKey: passKey,
          beacon: Beacon(
            passKey: passKey,
            latitude: location.latitude,
            longitude: location.longitude,
            accuracy: location.accuracy,
            heading: location.heading,
            points: points.map((e) => e.toJson()).toList(),
          ),
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
                zoom: 14.4746,
              ),
            ),
          );
          // Update the marker according to the new location
          updateMarkerAndCircle(newLocation);
          if (isCarrying &&
              (newLocation.latitude != location.latitude ||
                  newLocation.longitude != location.longitude)) {
            points.add(LatLng(newLocation.latitude, newLocation.longitude));
            updatePolyline(points);

            _database.updateBeacon(
              passKey: passKey,
              beacon: Beacon(
                passKey: passKey,
                latitude: newLocation.latitude,
                longitude: newLocation.longitude,
                accuracy: newLocation.accuracy,
                heading: newLocation.heading,
                points: points.map((e) => e.toJson()).toList(),
              ),
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
