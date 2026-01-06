import 'package:attendance_app/platform/data_source/api/api.dart';
import 'package:attendance_app/platform/data_source/api/api_base_models.dart';
import 'package:attendance_app/platform/data_source/api/api_end_point.dart';
import 'package:attendance_app/platform/data_source/api/course/models/course_request.dart';
import 'package:attendance_app/platform/data_source/api/course/models/course_response.dart';

class CourseApi extends ApiCore {
  CourseApi({required super.requester});

  final _courseBasePath = '/courses/getAllCourses';
  final _coursesForLevelBasePath = '/courses/getCoursesForLevelAndSemester';
  final _registerCoursesBasePath = '/student/registerCourse';
  final _registeredCoursesBasePath = '/student/getRegisteredCourses';
  final _dropCourseBasePath = '/student/dropCourse';

  Future<ApiResponse<ListDataResponse<Course>>> getAllCourses(
      {required GetAllCoursesRequest getAllCoursesRequest}) async {
    final response = await requester.makeAppRequest(
      apiEndPoint: ApiEndPoint.createApiEndpoint(
        path: _courseBasePath,
        requestType: HttpVerb.GET,
        body: getAllCoursesRequest.toMap(),
      ),
    );

    if (response.status == ApiResponseStatus.Success) {
      try {
        final data = ListDataResponse<Course>.fromJson(
          response.response,
          (json) => Course.fromJson(json),
        );

        final colouredCourses = Course.assignUniqueColors(data.data ?? []);

        final colouredData = ListDataResponse<Course>(
          data: colouredCourses,
          pageSize: data.pageSize,
          totalNumberOfPages: data.totalNumberOfPages,
          totalNumberOfRecords: data.totalNumberOfRecords,
          pageNumber: data.pageNumber,
        );

        return ApiResponse(
          response: colouredData,
          status: response.status,
          statusCode: response.statusCode,
          message: response.message,
        );
      } catch (e) {
        return ApiResponse(
          status: ApiResponseStatus.Error,
          message: 'Failed to parse courses',
        );
      }
    }

    return ApiResponse(
      status: response.status,
      statusCode: response.statusCode,
      message: response.message ?? 'Failed to get courses',
    );
  }

  Future<ApiResponse<List<Course>>> getCoursesForLevelAndSemester(
      GetCoursesForLevelAndSemesterRequest request) async {
    final response = await requester.makeAppRequest(
      apiEndPoint: ApiEndPoint.createApiEndpoint(
        path:
            '$_coursesForLevelBasePath/${request.levelId}/${request.semesterId}',
        requestType: HttpVerb.GET,
        body: {},
      ),
    );

    if (response.status == ApiResponseStatus.Success) {
      try {
        final data = response.response['data'];
        if (data != null && data is List) {
          final courses = (data)
              .map((json) => Course.fromJson(json as Map<String, dynamic>))
              .toList();

          final coloredCourses = Course.assignUniqueColors(courses);

          return ApiResponse(
            response: coloredCourses,
            status: response.status,
            statusCode: response.statusCode,
            message: response.message,
          );
        }
      } catch (e) {
        return ApiResponse(
          status: ApiResponseStatus.Error,
          message: 'Failed to parse courses',
        );
      }
    }

    return ApiResponse(
      status: response.status,
      statusCode: response.statusCode,
      message:
          response.message ?? 'Failed to get courses for level and semester',
    );
  }

  Future<ApiResponse<RegisterCourseResponse>> registerCourse(
      RegisterCourseRequest request) async {
    final response = await requester.makeAppRequest(
      apiEndPoint: ApiEndPoint.createApiEndpoint(
        path: _registerCoursesBasePath,
        requestType: HttpVerb.POST,
        body: request.toMap(),
      ),
    );

    if (response.status == ApiResponseStatus.Success) {
      try {
        final registerResponse =
            RegisterCourseResponse.fromJson(response.response);

        return ApiResponse(
          response: registerResponse,
          status: response.status,
          statusCode: response.statusCode,
          message: response.message ?? 'Course registered successfully',
        );
      } catch (e) {
        return ApiResponse(
          status: ApiResponseStatus.Error,
          message: 'Failed to parse registration response',
        );
      }
    }

    return ApiResponse(
      status: response.status,
      statusCode: response.statusCode,
      message: response.message ?? 'Failed to register course',
    );
  }

  Future<ApiResponse<List<Course>>> getRegisteredCourses(
      GetRegisteredCoursesRequest request) async {
    final response = await requester.makeAppRequest(
      apiEndPoint: ApiEndPoint.createApiEndpoint(
        path: '$_registeredCoursesBasePath/${request.studentId}',
        requestType: HttpVerb.GET,
        body: {},
      ),
    );

    if (response.status == ApiResponseStatus.Success) {
      try {
        final data = response.response['data'];
        if (data != null && data is List) {
          final courses = (data)
              .map((json) => Course.fromJson(json as Map<String, dynamic>))
              .toList();

          final coloredCourses = Course.assignUniqueColors(courses);

          return ApiResponse(
            response: coloredCourses,
            status: response.status,
            statusCode: response.statusCode,
            message: response.message,
          );
        }
      } catch (e) {
        return ApiResponse(
          status: ApiResponseStatus.Error,
          message: 'Failed to parse registered courses',
        );
      }
    }

    return ApiResponse(
      status: response.status,
      statusCode: response.statusCode,
      message: response.message ?? 'Failed to get registered courses',
    );
  }

  Future<ApiResponse<DropCourseResponse>> dropCourse(
      DropCourseRequest request) async {
    final response = await requester.makeAppRequest(
      apiEndPoint: ApiEndPoint.createApiEndpoint(
        path: _dropCourseBasePath,
        requestType: HttpVerb.POST,
        body: request.toMap(),
      ),
    );

    if (response.status == ApiResponseStatus.Success) {
      try {
        final dropResponse = DropCourseResponse.fromJson(response.response);

        return ApiResponse(
          response: dropResponse,
          status: response.status,
          statusCode: response.statusCode,
          message: response.message ?? 'Course dropped successfully',
        );
      } catch (e) {
        return ApiResponse(
          status: ApiResponseStatus.Error,
          message: 'Failed to parse drop course response',
        );
      }
    }
    return ApiResponse(
      status: response.status,
      statusCode: response.statusCode,
      message: response.message ?? 'Failed to drop course',
    );
  }
}
