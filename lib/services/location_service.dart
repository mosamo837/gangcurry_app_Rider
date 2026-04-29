import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class LocationService {
  Future<LatLng> getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationException('กรุณาเปิด GPS ของมือถือก่อน');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw const LocationException('แอปยังไม่ได้รับสิทธิ์เข้าถึงตำแหน่ง');
    }

    if (permission == LocationPermission.deniedForever) {
      throw const LocationException(
        'สิทธิ์เข้าถึงตำแหน่งถูกปิดถาวร กรุณาเปิดจาก Settings',
      );
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      ),
    );

    return LatLng(position.latitude, position.longitude);
  }
}

class LocationException implements Exception {
  const LocationException(this.message);

  final String message;

  @override
  String toString() => message;
}
