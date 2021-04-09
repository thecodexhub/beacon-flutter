import 'package:flutter/foundation.dart';

class Beacon {
  final String passKey;
  final double latitude;
  final double longitude;
  final double accuracy;
  final double heading;
  final int createdAt;
  final int duration;

  Beacon({
    @required this.passKey,
    @required this.latitude,
    @required this.longitude,
    @required this.accuracy,
    @required this.heading,
    this.createdAt,
    this.duration,
  });

  factory Beacon.fromMap(Map<String, dynamic> data, String passKey) {
    final double latitude = data['latitude'];
    final double longitude = data['longitude'];
    final double accuracy = double.parse(data['accuracy'].toString());
    final double heading = double.parse(data['heading'].toString());
    final int createdAt = data['createdAt'];
    final int duration = data['duration'];

    return Beacon(
      passKey: passKey,
      latitude: latitude,
      longitude: longitude,
      accuracy: accuracy,
      heading: heading,
      createdAt: createdAt,
      duration: duration,
    );
  }

  Map<String, dynamic> toMapCreate() {
    return {
      'latitude': this.latitude,
      'longitude': this.longitude,
      'accuracy': this.accuracy,
      'heading': this.heading,
      'createdAt': this.createdAt,
      'duration': this.duration,
    };
  }

  Map<String, dynamic> toMapUpdate() {
    return {
      'latitude': this.latitude,
      'longitude': this.longitude,
      'accuracy': this.accuracy,
      'heading': this.heading,
    };
  }
}
