import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:attendance_app/platform/extensions/string_extensions.dart';

class LocationUtils {
  static double calculateDistance({
    required Position from,
    required double toLat,
    required double toLong,
  }) {
    return Geolocator.distanceBetween(
      from.latitude,
      from.longitude,
      toLat,
      toLong,
    );
  }

  static String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)}m';
    }
    return '${(meters / 1000).toStringAsFixed(2)}km';
  }

  static Future<String?> getPlaceFromCoordinates({
    required double latitude,
    required double longitude,
    bool addCountry = false,
    int maxWords = 2,
  }) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isEmpty) return null;

      Placemark place = placemarks.first;

      // Collect non-null, non-empty parts
      List<String> parts = [
        place.name,
        place.locality ?? place.subAdministrativeArea,
        place.administrativeArea,
        if (addCountry) place.country,
      ].where((e) => e?.isNullOrBlank == false).cast<String>().toSet().toList();

      // Limit to maximum words
      if (parts.length > maxWords) {
        parts = parts.sublist(0, maxWords);
      }

      return parts.join(', ');
    } catch (e) {
      return null;
    }
  }
}
