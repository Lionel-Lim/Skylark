import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as maptool;

typedef Haversine = Map<String, double>;

class Geometry {
  /// Rotate [endPoint] relative to [startPoint] by [angle].
  LatLng rotatePoint(LatLng startPoint, LatLng endPoint, double angle) {
    final angleRad = angle * pi / 180.0; // convert angle to radians
    final dx = endPoint.longitude - startPoint.longitude;
    final dy = endPoint.latitude - startPoint.latitude;
    final cosAngle = cos(angleRad);
    final sinAngle = sin(angleRad);

    // rotate the line using 2D rotation matrix
    final newX = dx * cosAngle - dy * sinAngle;
    final newY = dx * sinAngle + dy * cosAngle;

    // calculate new endpoint coordinates
    final newLongitude = startPoint.longitude + newX;
    final newLatitude = startPoint.latitude + newY;

    return LatLng(newLatitude, newLongitude);
  }

  /// haversine formula to calculate geometry between WGS84 coordinates.
  Haversine haversine(LatLng point1, LatLng point2) {
    const double earthRadius = 6371000;
    double point1Lat = point1.latitude * pi / 180;
    double point2Lat = point2.latitude * pi / 180;
    double deltaLat = (point2.latitude - point1.latitude) * pi / 180;
    double deltaLng = (point2.longitude - point1.longitude) * pi / 180;

    double a = (sin(deltaLat / 2) * sin(deltaLat / 2)) +
        (cos(point1Lat) *
            cos(point2Lat) *
            sin(deltaLng / 2) *
            sin(deltaLng / 2));
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = earthRadius * c;

    return {"Distance": distance, "deltaLat": deltaLat, "deltaLng": deltaLng};
  }

  /// calculate distance between [point1] and [point2] in meter.
  double? calculateDistance(LatLng point1, LatLng point2) {
    return haversine(point1, point2)["Distance"];
  }

  bool isInside(LatLng point, List<LatLng> coordinates) {
    // To convert google maps latlng type to map toolkit latlng type
    List<maptool.LatLng> coordSet = [];
    for (var coord in coordinates) {
      coordSet.add(maptool.LatLng(coord.latitude, coord.longitude));
    }
    return maptool.PolygonUtil.containsLocation(
        maptool.LatLng(point.latitude, point.longitude), coordSet, true);
  }
}
