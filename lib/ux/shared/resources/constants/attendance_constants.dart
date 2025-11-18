class AttendanceConstants {
  static const double acceptableGPSAccuracy = 50.0; // meters
  static const double maxAccuracyBuffer = 100.0; // meters
  static const double networkLocationBuffer = 200.0; // meters
  static const double poorGPSAccuracyThreshold = 100.0; // meters

  static const Duration retryDelay = Duration(seconds: 3);
  static const Duration locationTimeout = Duration(seconds: 20);
  static const Duration networkLocationTimeout = Duration(seconds: 30);

  static const int maxLocationAttempts = 3;

  static const double houseLat = 5.5328015;
  static const double houseLong = -0.3264844;
  static const double seaviewLat = 5.5355513;
  static const double seaviewLong = -0.331639;
  static const double kccLat = 5.6037;
  static const double kccLong = -0.1870;
  static const double maxDistanceMeters = 50.0;
}

class CampusLocation {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final double maxDistanceMeters;

  const CampusLocation({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.maxDistanceMeters,
  });
}

class CampusLocations {
  static const List<CampusLocation> campuses = [
    CampusLocation(
      id: 'house',
      name: 'House Campus',
      latitude: AttendanceConstants.houseLat,
      longitude: AttendanceConstants.houseLong,
      maxDistanceMeters: AttendanceConstants.maxDistanceMeters,
    ),
    CampusLocation(
      id: 'seaview',
      name: 'Seaview Campus',
      latitude: AttendanceConstants.seaviewLat,
      longitude: AttendanceConstants.seaviewLong,
      maxDistanceMeters: AttendanceConstants.maxDistanceMeters,
    ),
    CampusLocation(
      id: 'kcc',
      name: 'KCC Campus',
      latitude: AttendanceConstants.kccLat,
      longitude: AttendanceConstants.kccLong,
      maxDistanceMeters: AttendanceConstants.maxDistanceMeters,
    ),
  ];

  static CampusLocation? getCampus(String id) {
    try {
      return campuses.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<String> get campusIds => campuses.map((c) => c.id).toList();
}
