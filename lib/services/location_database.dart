import 'package:beaconflutter/models/beacon.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

abstract class Database {
  Future<void> createBeacon(
      {@required Beacon beacon, @required String passKey});
  Future<void> updateBeacon(
      {@required String passKey, @required Beacon beacon});
  Stream beaconStream({@required String passKey});
}

class BeaconDatabase implements Database {
  final databaseReference = FirebaseDatabase.instance.reference();

  @override
  Future<void> createBeacon(
      {@required Beacon beacon, @required String passKey}) async {
    try {
      await databaseReference
          .child("beaconflutter-$passKey")
          .set(beacon.toMapCreate());
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Future<void> updateBeacon(
      {@required String passKey, @required Beacon beacon}) async {
    try {
      await databaseReference
          .child("beaconflutter-$passKey")
          .update(beacon.toMapUpdate());
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Stream beaconStream({@required String passKey}) {
    return databaseReference
        .child("beaconflutter-$passKey")
        .onValue
        .map((snapshot) {
      return snapshot.snapshot;
    }).map((snapshot) {
      final result = Map<String, dynamic>.from(snapshot.value as Map);
      return Beacon.fromMap(result, passKey);
    });
  }
}
