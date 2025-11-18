class LocationException implements Exception {
  final String message;

  LocationException(this.message);

  @override
  String toString() => message;
}

class LocationServiceException extends LocationException {
  LocationServiceException(String message) : super(message);
}

class LocationPermissionException extends LocationException {
  LocationPermissionException(String message) : super(message);
}

class LocationTimeoutException extends LocationException {
  LocationTimeoutException(String message) : super(message);
}