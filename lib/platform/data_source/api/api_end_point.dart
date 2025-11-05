import 'package:attendance_app/platform/data_source/api/api.dart';

class ApiEndPoint {
  ApiEndPoint({
    required this.address,
    required this.baseUrl,
    required this.path,
    required this.requestType,
    required this.body,
    required this.headers,
    required this.recordApiEvent,
    this.compressMedia = false,
  });

  Uri address;
  String baseUrl;
  String path;
  HttpVerb requestType;
  Map<String, dynamic> body;
  Map<String, String> headers;
  bool recordApiEvent;
  bool compressMedia;

  static ApiEndPoint createApiEndpoint({
    String? authority,
    required String path,
    bool recordApiEvent = true,
    requestType = HttpVerb,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    bool compressMedia = false,
  }) {
    authority ??= ApiCore.apiBaseUrl;

    if (!authority.contains('://')) {
      authority = 'http://$authority';
    }

    var mainHeaders = {
      'Content-Type': 'application/json; charset=UTF-8',
    };

    if (headers != null) {
      mainHeaders.addAll(headers);
    }

    var requestBody = body;
    requestBody ??= {};

    Uri uri;

    if (requestType == HttpVerb.GET) {
      // Ensure path joins correctly
      final full = authority.endsWith('/') || path.startsWith('/')
          ? '$authority$path'
          : '$authority/$path';
      uri = Uri.parse(full).replace(
        queryParameters: requestBody.map(
          (key, value) => MapEntry(
            key,
            value.toString(),
          ),
        ),
      );
    } else {
      final full = authority.endsWith('/') || path.startsWith('/')
          ? '$authority$path'
          : '$authority/$path';
      uri = Uri.parse(full);
    }

    return ApiEndPoint(
      address: uri,
      baseUrl: authority,
      path: path,
      requestType: requestType,
      body: requestBody,
      headers: mainHeaders,
      recordApiEvent: recordApiEvent,
      compressMedia: compressMedia,
    );
  }
}
