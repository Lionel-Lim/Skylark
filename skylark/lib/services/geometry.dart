import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as maptool;

typedef Haversine = Map<String, double>;

class Geometry {
  static const double earthRadius = 6371009.0;

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
    maptool.SphericalUtil.earthRadius;
    return maptool.PolygonUtil.containsLocation(
        maptool.LatLng(point.latitude, point.longitude), coordSet, true);
  }
}

class PolygonTool {
  late LatLng southwest;
  late LatLng northeast;
  late LatLng centroid;

  PolygonTool(List<LatLng> vertices) {
    double swLat = _getMin(vertices.map((e) => e.latitude).toList());
    double swLng = _getMin(vertices.map((e) => e.longitude).toList());
    double neLat = _getMax(vertices.map((e) => e.latitude).toList());
    double neLng = _getMax(vertices.map((e) => e.longitude).toList());

    southwest = LatLng(swLat, swLng);
    northeast = LatLng(neLat, neLng);

    centroid = LatLng((southwest.latitude + northeast.latitude) / 2,
        (southwest.longitude + northeast.longitude) / 2);
  }

  double _getMin(List<double> values) {
    return values.reduce((value, element) => value < element ? value : element);
  }

  double _getMax(List<double> values) {
    return values.reduce((value, element) => value > element ? value : element);
  }
}

double calculateAngle(Offset center, Offset point) {
  final dx = point.dx - center.dx;
  final dy = point.dy - center.dy;
  return atan2(dy, dx);
}

SectorAngles calculateSectorAngles(
    Offset start, Offset end, Offset center, Offset user) {
  final startAngle = calculateAngle(center, start);
  final endAngle = calculateAngle(center, end);
  final sweepAngle = endAngle - startAngle;
  return SectorAngles(startAngle: startAngle, sweepAngle: sweepAngle);
}

class SectorAngles {
  final double startAngle;
  final double sweepAngle;

  SectorAngles({required this.startAngle, required this.sweepAngle});
}

class SectorPainter extends CustomPainter {
  final double startAngle;
  final double sweepAngle;
  final Color color;

  SectorPainter(
      {required this.startAngle,
      required this.sweepAngle,
      required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;

    final path = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(Rect.fromCircle(center: center, radius: radius), startAngle,
          sweepAngle, false)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant SectorPainter oldDelegate) {
    return oldDelegate.startAngle != startAngle ||
        oldDelegate.sweepAngle != sweepAngle ||
        oldDelegate.color != color;
  }
}
