import 'package:firebase_database/firebase_database.dart';

class LocationDatabase {
  final databaseReference = FirebaseDatabase.instance.reference();

  Future<void> createLocationData(String passKey, String latitude,
      String longitude, double accuracy, double heading, Duration duration) async {
    try {
      await databaseReference.child("beaconflutter-$passKey").set({
        'latitude': latitude,
        'longitude': longitude,
        'accuracy': accuracy,
        'heading': heading,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'duration': duration.inMilliseconds,
      });
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> updateLocationData(String passKey, String latitude,
      String longitude, double accuracy, double heading) async {
    try {
      await databaseReference.child("beaconflutter-$passKey").update({
        'latitude': latitude,
        'longitude': longitude,
        'accuracy': accuracy,
        'heading': heading,
      });
    } catch (e) {
      print(e.toString());
    }
  }

  Stream fetchLocation(String passKey) {
    return databaseReference.child("beaconflutter-$passKey").onValue;
  }
}
