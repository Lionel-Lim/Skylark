// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';

// class GetUserLocation {
//   static LatLng userLatLng =
//       const LatLng(51.53827870886303, -0.009924861467517582);
//   static Future<LatLng> getLatLng() async {
//     try {
//       await Geolocator.getCurrentPosition(
//               desiredAccuracy: LocationAccuracy.best,
//               forceAndroidLocationManager: true)
//           .then((Position position) {
//         userLatLng = LatLng(position.latitude, position.longitude);
//         print("$userLatLng");
//         return userLatLng;
//       });
//     } catch (e) {
//       print(e);
//     }
//     throw userLatLng;
//   }
// }
