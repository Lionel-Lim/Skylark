import 'dart:async';

import 'package:geolocator/geolocator.dart';

class GetLocation {
  Future<Position> getCurrentUserLocation() async {
    await Geolocator.requestPermission()
        .then((value) {})
        .onError((error, stackTrace) async {
      await Geolocator.requestPermission();
    });
    return await Geolocator.getCurrentPosition();
  }
}
