import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/parcel.dart';
import '../services/delivery_store.dart';
import '../services/location_service.dart';
import '../services/route_service.dart';
import 'confirm_delivery_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key, required this.parcel});

  final Parcel parcel;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late final Future<_MapViewData> _mapViewData;
  final LocationService _locationService = LocationService();
  final RouteService _routeService = RouteService();

  @override
  void initState() {
    super.initState();
    _mapViewData = _loadMapData();
  }

  Future<_MapViewData> _loadMapData() async {
    final fallbackRiderPoint = LatLng(
      widget.parcel.riderLatitude,
      widget.parcel.riderLongitude,
    );
    final destinationPoint = LatLng(
      widget.parcel.destinationLatitude,
      widget.parcel.destinationLongitude,
    );

    try {
      final currentPoint = await _locationService.getCurrentLocation();
      return await _buildMapData(
        riderPoint: currentPoint,
        destinationPoint: destinationPoint,
        locationSourceLabel: 'GPS ปัจจุบัน',
      );
    } on LocationException catch (error) {
      return _buildMapDataWithFallback(
        riderPoint: fallbackRiderPoint,
        destinationPoint: destinationPoint,
        warningMessage: error.message,
        locationSourceLabel: 'พิกัดตัวอย่าง',
      );
    } catch (_) {
      return _buildMapDataWithFallback(
        riderPoint: fallbackRiderPoint,
        destinationPoint: destinationPoint,
        warningMessage: 'ไม่สามารถอ่านตำแหน่งปัจจุบันได้ ใช้พิกัดตัวอย่างแทน',
        locationSourceLabel: 'พิกัดตัวอย่าง',
      );
    }
  }

  Future<_MapViewData> _buildMapData({
    required LatLng riderPoint,
    required LatLng destinationPoint,
    required String locationSourceLabel,
    String? warningMessage,
  }) async {
    try {
      final route = await _routeService.getDrivingRoute(
        origin: riderPoint,
        destination: destinationPoint,
      );

      return _MapViewData(
        riderPoint: riderPoint,
        destinationPoint: destinationPoint,
        routePoints: route.points,
        distanceKm: route.distanceKm,
        eta: _formatEta(route.durationSeconds),
        warningMessage: warningMessage,
        locationSourceLabel: locationSourceLabel,
      );
    } on RouteException catch (error) {
      final combinedWarning = _mergeWarnings(warningMessage, error.message);
      return _buildMapDataWithFallback(
        riderPoint: riderPoint,
        destinationPoint: destinationPoint,
        warningMessage: combinedWarning,
        locationSourceLabel: locationSourceLabel,
      );
    } catch (_) {
      final combinedWarning = _mergeWarnings(
        warningMessage,
        'ไม่สามารถโหลดเส้นทางถนนได้ ใช้เส้นตรงแทนชั่วคราว',
      );
      return _buildMapDataWithFallback(
        riderPoint: riderPoint,
        destinationPoint: destinationPoint,
        warningMessage: combinedWarning,
        locationSourceLabel: locationSourceLabel,
      );
    }
  }

  _MapViewData _buildMapDataWithFallback({
    required LatLng riderPoint,
    required LatLng destinationPoint,
    required String locationSourceLabel,
    String? warningMessage,
  }) {
    final distanceKm = const Distance()
        .as(LengthUnit.Kilometer, riderPoint, destinationPoint);
    return _MapViewData(
      riderPoint: riderPoint,
      destinationPoint: destinationPoint,
      routePoints: [riderPoint, destinationPoint],
      distanceKm: distanceKm,
      eta: _formatEta((distanceKm / 32) * 3600),
      warningMessage: warningMessage,
      locationSourceLabel: locationSourceLabel,
    );
  }

  String _mergeWarnings(String? first, String second) {
    return [
      ...?first == null ? null : [first],
      second,
    ].join('\n');
  }

  String _formatEta(double durationSeconds) {
    final totalMinutes = (durationSeconds / 60).ceil();
    if (totalMinutes < 60) {
      return '$totalMinutes นาที';
    }

    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    if (minutes == 0) {
      return '$hours ชม.';
    }
    return '$hours ชม. $minutes นาที';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('แผนที่การจัดส่ง'),
      ),
      body: FutureBuilder<_MapViewData>(
        future: _mapViewData,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: Text('ไม่สามารถโหลดแผนที่ได้'),
            );
          }

          final data = snapshot.data!;

          return Stack(
            children: [
              FlutterMap(
                options: MapOptions(
                  initialCameraFit: CameraFit.coordinates(
                    coordinates: [data.riderPoint, data.destinationPoint],
                    padding: const EdgeInsets.all(56),
                    maxZoom: 16,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.apprider.app',
                    maxNativeZoom: 19,
                  ),
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: data.routePoints,
                        strokeWidth: 5,
                        color: const Color(0xFF0B63F6),
                      ),
                    ],
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: data.riderPoint,
                        width: 130,
                        height: 72,
                        child: _MapMarker(
                          icon: Icons.delivery_dining_rounded,
                          label: data.locationSourceLabel,
                          color: const Color(0xFF0B63F6),
                        ),
                      ),
                      Marker(
                        point: data.destinationPoint,
                        width: 120,
                        height: 72,
                        child: const _MapMarker(
                          icon: Icons.location_on_rounded,
                          label: 'ปลายทาง',
                          color: Color(0xFFE2574C),
                        ),
                      ),
                    ],
                  ),
                  const RichAttributionWidget(
                    attributions: [
                      TextSourceAttribution('OpenStreetMap contributors'),
                    ],
                  ),
                ],
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: ListenableBuilder(
                  listenable: DeliveryStore.instance,
                  builder: (context, child) => _MapSummaryCard(
                    parcel: widget.parcel,
                    distanceKm: data.distanceKm,
                    eta: data.eta,
                    warningMessage: data.warningMessage,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MapViewData {
  const _MapViewData({
    required this.riderPoint,
    required this.destinationPoint,
    required this.routePoints,
    required this.distanceKm,
    required this.eta,
    required this.locationSourceLabel,
    this.warningMessage,
  });

  final LatLng riderPoint;
  final LatLng destinationPoint;
  final List<LatLng> routePoints;
  final double distanceKm;
  final String eta;
  final String locationSourceLabel;
  final String? warningMessage;
}

class _MapSummaryCard extends StatelessWidget {
  const _MapSummaryCard({
    required this.parcel,
    required this.distanceKm,
    required this.eta,
    this.warningMessage,
  });

  final Parcel parcel;
  final double distanceKm;
  final String eta;
  final String? warningMessage;

  @override
  Widget build(BuildContext context) {
    final isDelivered = DeliveryStore.instance.isDelivered(parcel);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            parcel.customerName,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            parcel.address,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (warningMessage != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4E5),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                warningMessage!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF8A5300),
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  icon: Icons.route_outlined,
                  label: 'ระยะทาง',
                  value: '${distanceKm.toStringAsFixed(1)} กม.',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  icon: Icons.access_time_rounded,
                  label: 'ถึงปลายทาง',
                  value: eta,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'เวลาและระยะทางคำนวณจากเส้นทางบนถนนที่หาได้ล่าสุด',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.black54,
                ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isDelivered
                  ? null
                  : () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (context) =>
                              ConfirmDeliveryScreen(parcel: parcel),
                        ),
                      );
                    },
              icon: const Icon(Icons.check_circle_outline_rounded),
              label: Text(
                isDelivered ? 'ยืนยันการจัดส่งแล้ว' : 'ยืนยันการจัดส่ง',
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F7FB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF0B63F6), size: 20),
          const SizedBox(height: 10),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.black54,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _MapMarker extends StatelessWidget {
  const _MapMarker({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(999),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
        Icon(
          Icons.location_on_rounded,
          color: color,
          size: 34,
        ),
      ],
    );
  }
}
