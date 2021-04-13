import 'package:flutter_riverpod/flutter_riverpod.dart';

enum BeaconMapType { normal, hybrid }

final beaconMapTypeProvider =
    StateNotifierProvider<BeaconMapTypeStateNotifier, BeaconMapType>((ref) {
  return BeaconMapTypeStateNotifier();
});

class BeaconMapTypeStateNotifier extends StateNotifier<BeaconMapType> {
  BeaconMapTypeStateNotifier() : super(BeaconMapType.normal);

  void toggleMapType() {
    if (state == BeaconMapType.normal) {
      state = BeaconMapType.hybrid;
    } else {
      state = BeaconMapType.normal;
    }
  }
}
