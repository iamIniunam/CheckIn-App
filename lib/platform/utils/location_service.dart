import 'package:geolocator/geolocator.dart';

class LocationService {
  static Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission locationPermission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled');
    }

    locationPermission = await Geolocator.checkPermission();
    if (locationPermission == LocationPermission.denied) {
      locationPermission = await Geolocator.requestPermission();
      if (locationPermission == LocationPermission.denied) {
        throw Exception('Location permission denied');
      }
    }

    if (locationPermission == LocationPermission.deniedForever) {
      throw Exception(
          'Location permissions are permanently denied. Please enable them in settings.');
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  static bool isWithinRange(Position currentPosition, double targetLat,
      double targetLong, double maxDistanceMeters) {
    double distance = Geolocator.distanceBetween(currentPosition.latitude,
        currentPosition.longitude, targetLat, targetLong);

    return distance <= maxDistanceMeters;
  }
}
