import 'package:beaconflutter/common_widgets/beacon_google_map.dart';
import 'package:beaconflutter/common_widgets/empty_content.dart';
import 'package:beaconflutter/models/beacon.dart';
import 'package:beaconflutter/providers/map_type_state_notifier.dart';
import 'package:beaconflutter/services/location_database.dart';
import 'package:custom_timer/custom_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class FollowScreen extends StatefulWidget {
  const FollowScreen({Key key, @required this.passKey}) : super(key: key);
  final String passKey;

  @override
  _FollowScreenState createState() => _FollowScreenState();
}

class _FollowScreenState extends State<FollowScreen> {
  GoogleMapController mapController;
  Marker _marker;
  Circle _circle;
  Polyline _polyline;

  // final Set<Polyline> polyline = {};
  List<LatLng> points = [];

  final Database _database = BeaconDatabase();

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void updateMarkerAndCircle(Beacon beacon) {
    final LatLng latLng = LatLng(beacon.latitude, beacon.longitude);
    points = beacon.points.map((e) => LatLng.fromJson(e)).toList();

    _marker = Marker(
      markerId: MarkerId('follow-arrow-head'),
      position: latLng,
      rotation: beacon.heading,
      zIndex: 2,
      flat: true,
      anchor: const Offset(0.5, 0.5),
    );
    _circle = Circle(
      circleId: CircleId('follow-arrow-circle'),
      radius: beacon.accuracy,
      center: latLng,
      zIndex: 1,
      strokeColor: Colors.blue,
      fillColor: Colors.blue.withAlpha(70),
    );

    _polyline = Polyline(
      polylineId: PolylineId('follow_route'),
      points: points,
      visible: true,
      width: 5,
      color: Colors.red,
      startCap: Cap.roundCap,
    );

    if (mapController != null) {
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(beacon.latitude, beacon.longitude),
            bearing: 192.8334901395799,
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
        title: const Text('Follow the beacon'),
        actions: [
          IconButton(
            icon: const Icon(Icons.center_focus_strong),
            onPressed: () =>
                context.read(beaconMapTypeProvider.notifier).toggleMapType(),
          ),
        ],
      ),
      body: StreamBuilder(
          stream: _database.beaconStream(passKey: widget.passKey),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              final Beacon beacon = snapshot.data as Beacon;

              final diff =
                  DateTime.now().millisecondsSinceEpoch - beacon.createdAt;
              final Duration remainingTime =
                  Duration(milliseconds: beacon.duration - diff);
              final Duration rDuration = Duration(
                hours: remainingTime.inHours,
                minutes: remainingTime.inMinutes.remainder(60) as int,
                seconds: remainingTime.inSeconds.remainder(60) as int,
              );

              if (rDuration > const Duration(milliseconds: 1)) {
                updateMarkerAndCircle(beacon);
                return _buildContent(beacon, remainingTime);
              } else {
                return const EmptyContent(
                  title: 'Passkey Expired!',
                  desc: 'Your passkey has been expired! Please go back to Home Screen and use another.',
                );
              }
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
    );
  }

  Widget _buildCard(Duration duration) {
    return Container(
      margin: const EdgeInsets.only(top: 12.0),
      padding: const EdgeInsets.all(20.0),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
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
            from: duration,
            to: const Duration(),
            onBuildAction: CustomTimerAction.auto_start,
            builder: (CustomTimerRemainingTime remaining) {
              return Text(
                "Remaining time: ${remaining.hours}:${remaining.minutes}:${remaining.seconds}",
                style: Theme.of(context).textTheme.subtitle2,
              );
            },
            onFinish: () {
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContent(Beacon beacon, Duration duration) {
    return Stack(
      children: [
        BeaconGoogleMap(
          initialTarget: LatLng(beacon.latitude, beacon.longitude),
          onMapCreated: _onMapCreated,
          marker: _marker,
          circle: _circle,
          polyline: _polyline,
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: _buildCard(duration),
        ),
      ],
    );
  }
}
