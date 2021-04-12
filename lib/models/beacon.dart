import 'package:flutter/foundation.dart';

class Beacon {
  final String passKey;
  final double latitude;
  final double longitude;
  final double accuracy;
  final double heading;
  final List<Object> points;
  // final List<Map<String, dynamic>> points;
  final int createdAt;
  final int duration;

  Beacon({
    @required this.passKey,
    @required this.latitude,
    @required this.longitude,
    @required this.accuracy,
    @required this.heading,
    @required this.points,
    this.createdAt,
    this.duration,
  });

  factory Beacon.fromMap(Map<String, dynamic> data, String passKey) {
    final double latitude = data['latitude'] as double;
    final double longitude = data['longitude'] as double;
    final double accuracy = double.parse(data['accuracy'].toString());
    final double heading = double.parse(data['heading'].toString());
    final List<Object> points = data['points'] as List<Object>;
    final int createdAt = data['createdAt'] as int;
    final int duration = data['duration'] as int;

    return Beacon(
      passKey: passKey,
      latitude: latitude,
      longitude: longitude,
      accuracy: accuracy,
      heading: heading,
      points: points,
      createdAt: createdAt,
      duration: duration,
    );
  }

  Map<String, dynamic> toMapCreate() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'heading': heading,
      'createdAt': createdAt,
      'points': points,
      'duration': duration,
    };
  }

  Map<String, dynamic> toMapUpdate() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'heading': heading,
      'points': points,
    };
  }
}
