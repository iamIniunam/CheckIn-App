final class NetworkStrings {
  NetworkStrings._();

  // Generic Errors
  static const somethingWentWrong = 'Something went wrong';

  // Connection Errors
  static const connectionTimeOut =
      'Connection timed out, please check your internet connection';
  static const internetError =
      'Could not connect to the server, please check your internet connection';
  static const slowConnection =
      'Slow connection detected. This may take a while';

  // SSL/Security Errors
  static const certificateError =
      'An error occurred could not verify server certificate';
  static const handShakeError =
      'Could not establish secure connection with the server';

  // Data Format Errors
  static const formatError = 'Improperly formatted value';
  static const noResponse = 'No response from server';

  // HTTP Status Errors (4xx)
  static const badRequest = 'Invalid request. Please check your input';
  static const unauthorized = 'Unauthorized. Please login again';
  static const forbidden = 'Access denied';
  static const notFound = 'Resource not found';
  static const tooManyRequests = 'Too many requests. Please try again later';

  // HTTP Status Errors (5xx)
  static const serverError = 'Server error. Please try again later';
  static const serviceUnavailable = 'Service temporarily unavailable';

  // Other
  static const requestCancelled = 'Request was cancelled';
}
