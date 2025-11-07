// ignore_for_file: constant_identifier_names

import 'package:attendance_app/platform/data_source/api/requester.dart';

class Api {
  Requester requester;

  Api({required this.requester});
}

abstract class ApiCore {
static String apiBaseUrl = 'http://192.168.100.5:8000/api';
// static String apiBaseUrl = 'http://10.207.210.84:8000/api';
  static const String baseUrlPrefix = 'http://';

  Requester requester;

  ApiCore({required this.requester});
}

enum ApiResponseStatus { Success, NoInternet, Error, Timeout, Unknown }

enum HttpVerb { POST, GET, PUT, PATCH, DELETE }
