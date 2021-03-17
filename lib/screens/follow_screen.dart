import 'dart:typed_data';

import 'package:beaconflutter/services/location_database.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class FollowScreen extends StatefulWidget {
  FollowScreen({Key key, @required this.passKey}) : super(key: key);
  final String passKey;

  @override
  _FollowScreenState createState() => _FollowScreenState();
}

class _FollowScreenState extends State<FollowScreen> {
  GoogleMapController mapController;
  Marker marker;
  Circle circle;

  final LocationDatabase _locationDatabase = LocationDatabase();

  final LatLng _center = const LatLng(22.06046, 88.10975);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void updateMarkerAndCircle(
      double latitude, double longitude, double accuracy, double heading) {
    LatLng latLng = LatLng(latitude, longitude);
    marker = Marker(
      markerId: MarkerId('follow-arrow-head'),
      position: latLng,
      rotation: heading,
      draggable: false,
      zIndex: 2,
      flat: true,
      anchor: Offset(0.5, 0.5),
      icon: BitmapDescriptor.defaultMarker,
    );
    circle = Circle(
      circleId: CircleId('follow-arrow-circle'),
      radius: accuracy,
      center: latLng,
      zIndex: 1,
      strokeColor: Colors.blue,
      fillColor: Colors.blue.withAlpha(70),
    );

    if (mapController != null) {
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(latitude, longitude),
            bearing: 192.8334901395799,
            tilt: 0,
            zoom: 14.4746,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tracking location'),
      ),
      body: StreamBuilder(
        stream: _locationDatabase.fetchLocation(widget.passKey),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.hasError) {
              return Center(
                child: Text(snapshot.error.toString()),
              );
            } else {
              DataSnapshot _snapshot = snapshot.data.snapshot;
              final latitudeString = _snapshot.value["latitude"];
              final longitudeString = _snapshot.value["longitude"];
              final accuracyValue = _snapshot.value["accuracy"];
              final headingValue = _snapshot.value["heading"];

              final double latitude = double.parse(latitudeString);
              final double longitude = double.parse(longitudeString);
              final double accuracy = double.parse(accuracyValue.toString());
              final double heading = double.parse(headingValue.toString());

              updateMarkerAndCircle(latitude, longitude, accuracy, heading);
              return _buildContent(latitude, longitude);
            }
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  Widget _buildCard() {
    return Container(
      margin: const EdgeInsets.all(12.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'You are currently following the beacon',
            style: Theme.of(context).textTheme.headline6,
          ),
          const SizedBox(height: 6.0),
          Row(
            children: [
              Text(
                'Passkey is: ',
                style: Theme.of(context).textTheme.subtitle1,
              ),
              Text(
                widget.passKey,
                style: Theme.of(context).textTheme.subtitle1.copyWith(
                      color: Colors.indigo,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(width: 10.0),
              InkWell(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: widget.passKey));
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
            'Time remaining:',
            style: Theme.of(context).textTheme.subtitle2,
          ),
        ],
      ),
    );
  }

  Widget _buildContent(double latitude, double longitude) {
    return Stack(
      children: [
        GoogleMap(
          mapType: MapType.hybrid,
          onMapCreated: _onMapCreated,
          zoomControlsEnabled: false,
          compassEnabled: true,
          initialCameraPosition: CameraPosition(
            target: LatLng(latitude, longitude),
            zoom: 14.4746,
          ),
          markers: Set.of((marker != null) ? [marker] : []),
          circles: Set.of((circle != null) ? [circle] : []),
        ),
        _buildCard(),
      ],
    );
  }
}
