import 'package:attendance_app/platform/utils/location_utils.dart';
import 'package:geolocator/geolocator.dart';

enum UIState { empty, loading, success, error }

class UIResult<T> {
  T? data;
  UIState state;
  String? message = '';

  UIResult({
    this.data,
    required this.state,
    required this.message,
  });

  static UIResult<T> empty<T>() {
    return UIResult<T>(
      state: UIState.empty,
      message: null,
    );
  }

  static UIResult<T> loading<T>({dynamic data, String? message}) {
    return UIResult<T>(
      state: UIState.loading,
      data: data,
      message: message,
    );
  }

  static UIResult<T> success<T>({dynamic data, String? message}) {
    return UIResult<T>(
      state: UIState.success,
      data: data,
      message: message,
    );
  }

  static UIResult<T> error<T>({dynamic data, String? message}) {
    return UIResult<T>(
      state: UIState.error,
      data: data,
      message: message ?? 'Something went wrong',
    );
  }

  bool get isLoading => state == UIState.loading;
  bool get isSuccess => state == UIState.success;
  bool get isError => state == UIState.error;
  bool get isEmpty => state == UIState.empty;
  bool get hasData => data != null;
}

class AttendanceResult {
  final bool canAttend;
  final Position? position;
  final double? distance;
  final String? method;

  AttendanceResult({
    required this.canAttend,
    this.position,
    this.distance,
    this.method,
  });

  String get formattedDistance =>
      distance != null ? LocationUtils.formatDistance(distance!) : 'Unknown';

  double? get accuracy => position?.accuracy;

  String get statusMessage {
    if (canAttend) {
      if (method != null) {
        return 'Location verified via $method';
      }
      return 'Location verified';
    }
    return 'Not within attendance range';
  }
}
