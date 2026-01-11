import 'package:attendance_app/platform/data_source/api/api.dart';
import 'package:attendance_app/platform/data_source/api/attendance/attendance_api.dart';
import 'package:attendance_app/platform/data_source/api/auth/auth_api.dart';
import 'package:attendance_app/platform/data_source/api/course/course_api.dart';
import 'package:attendance_app/platform/data_source/api/requester.dart';
import 'package:attendance_app/platform/data_source/persistence/manager.dart';
import 'package:attendance_app/platform/services/local_auth_service.dart';
import 'package:attendance_app/platform/utils/location_provider.dart';
import 'package:attendance_app/platform/utils/multi_campus_location_helper.dart';
import 'package:attendance_app/ux/shared/resources/constants/attendance_validator.dart';
import 'package:attendance_app/ux/shared/view_models/attendance/attendance_view_model.dart';
import 'package:attendance_app/ux/shared/view_models/attendance/online_code_view_model.dart';
import 'package:attendance_app/ux/shared/view_models/attendance/qr_scan_view_model.dart';
import 'package:attendance_app/ux/shared/view_models/attendance/attendance_location_view_model.dart';
import 'package:attendance_app/ux/shared/view_models/auth_view_model.dart';
import 'package:attendance_app/ux/shared/view_models/course_search_view_model.dart';
import 'package:attendance_app/ux/shared/view_models/course_view_model.dart';
import 'package:attendance_app/ux/shared/view_models/remote_config_view_model.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppDI {
  const AppDI._();

  static GetIt getIt = GetIt.instance;

  static Future<void> init(
      {required SharedPreferences sharedPreferences}) async {
    final manager = PreferenceManager(sharedPreferences);
    final requester = Requester(manager: manager);

    getIt.registerSingleton<SharedPreferences>(sharedPreferences);
    getIt.registerLazySingleton<PreferenceManager>(() => manager);
    getIt.registerLazySingleton<Requester>(() => requester);

    getIt.registerLazySingleton<Api>(() => Api(requester: requester));

    getIt.registerLazySingleton<AuthApi>(() => AuthApi(requester: requester));
    getIt.registerLazySingleton<CourseApi>(
        () => CourseApi(requester: requester));
    getIt.registerLazySingleton<AttendanceApi>(
        () => AttendanceApi(requester: requester));

    //View Models
    getIt.registerLazySingleton<AuthViewModel>(() => AuthViewModel());
    getIt.registerLazySingleton<CourseViewModel>(() => CourseViewModel());
    getIt.registerLazySingleton<AttendanceViewModel>(
        () => AttendanceViewModel());
    getIt.registerLazySingleton<CourseSearchViewModel>(
        () => CourseSearchViewModel());
    getIt.registerLazySingleton<QrScanViewModel>(() => QrScanViewModel());
    getIt.registerLazySingleton<OnlineCodeViewModel>(
        () => OnlineCodeViewModel());
    getIt.registerLazySingleton<AttendanceLocationViewModel>(
        () => AttendanceLocationViewModel());
    getIt.registerLazySingleton<RemoteConfigViewModel>(
        () => RemoteConfigViewModel());

    // Services
    getIt.registerLazySingleton<LocationProvider>(() => LocationProvider());
    getIt.registerLazySingleton<AttendanceValidator>(
        () => AttendanceValidator());
    getIt.registerLazySingleton<LocalAuthService>(() => LocalAuthService());
    getIt.registerLazySingleton<MultiCampusLocationHelper>(
        () => MultiCampusLocationHelper());
  }
}

extension ApiExtensions on Api {
  AuthApi get authApi => AppDI.getIt<AuthApi>();
  CourseApi get courseApi => AppDI.getIt<CourseApi>();
  AttendanceApi get attendanceApi => AppDI.getIt<AttendanceApi>();
}
