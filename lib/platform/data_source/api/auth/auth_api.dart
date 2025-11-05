import 'package:attendance_app/platform/data_source/api/api.dart';
import 'package:attendance_app/platform/data_source/api/api_base_models.dart';
import 'package:attendance_app/platform/data_source/api/api_end_point.dart';
import 'package:attendance_app/platform/data_source/api/auth/models/auth_request.dart';

class AuthApi extends ApiCore {
  AuthApi({required super.requester});

  final _signUpBasePath = '/student/sign-up';
  final _loginBasePath = '/student/login';

  Future<ApiResponse<dynamic>> signUp(SignUpRequest request) async {
    final response = await requester.makeAppRequest(
      apiEndPoint: ApiEndPoint.createApiEndpoint(
        path: _signUpBasePath,
        requestType: HttpVerb.POST,
        body: request.toMap(),
      ),
    );
    return ApiResponse(
      response: response.response,
      status: response.status,
      statusCode: response.statusCode,
      message: response.message,
    );
  }

  Future<ApiResponse<dynamic>> login(LoginRequest request) async {
    final response = await requester.makeAppRequest(
      apiEndPoint: ApiEndPoint.createApiEndpoint(
        path: _loginBasePath,
        requestType: HttpVerb.POST,
        body: request.toMap(),
      ),
    );
    return ApiResponse(
      response: response.response,
      status: response.status,
      statusCode: response.statusCode,
      message: response.message,
    );
  }
}
