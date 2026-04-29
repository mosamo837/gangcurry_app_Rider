import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class RouteService {
  Future<RouteResult> getDrivingRoute({
    required LatLng origin,
    required LatLng destination,
  }) async {
    final uri = Uri.parse(
      'https://router.project-osrm.org/route/v1/driving/'
      '${origin.longitude},${origin.latitude};'
      '${destination.longitude},${destination.latitude}'
      '?overview=full&geometries=geojson&steps=false',
    );

    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw const RouteException('ไม่สามารถโหลดเส้นทางถนนได้');
    }

    final Map<String, dynamic> json = jsonDecode(response.body);
    if (json['code'] != 'Ok') {
      throw const RouteException('หาเส้นทางที่ขับรถได้ไม่เจอ');
    }

    final routes = json['routes'] as List<dynamic>;
    if (routes.isEmpty) {
      throw const RouteException('ไม่พบข้อมูลเส้นทาง');
    }

    final route = routes.first as Map<String, dynamic>;
    final geometry = route['geometry'] as Map<String, dynamic>;
    final coordinates = geometry['coordinates'] as List<dynamic>;

    final points = coordinates
        .map((coordinate) => coordinate as List<dynamic>)
        .map((coordinate) => LatLng(
              (coordinate[1] as num).toDouble(),
              (coordinate[0] as num).toDouble(),
            ))
        .toList();

    return RouteResult(
      points: points,
      distanceKm: ((route['distance'] as num).toDouble()) / 1000,
      durationSeconds: (route['duration'] as num).toDouble(),
    );
  }
}

class RouteResult {
  const RouteResult({
    required this.points,
    required this.distanceKm,
    required this.durationSeconds,
  });

  final List<LatLng> points;
  final double distanceKm;
  final double durationSeconds;
}

class RouteException implements Exception {
  const RouteException(this.message);

  final String message;

  @override
  String toString() => message;
}
