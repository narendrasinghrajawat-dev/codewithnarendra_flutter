import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import '../exceptions/app_exceptions.dart';

class NetworkService {
  late Dio _dio;
  
  NetworkService() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: Duration(milliseconds: int.parse(AppConstants.apiTimeout)),
      receiveTimeout: Duration(milliseconds: int.parse(AppConstants.apiTimeout)),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    
    _setupInterceptors();
  }
  
  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print('Request: ${options.method} ${options.path}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          print('Response: ${response.statusCode} ${response.requestOptions.path}');
          handler.next(response);
        },
        onError: (error, handler) {
          final exception = _handleError(error);
          print('Error: ${exception.toString()}');
          handler.reject(error);
        },
      ),
    );
  }
  
  AppException _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutException('Request timeout');
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        switch (statusCode) {
          case 400:
            return ValidationException(
              error.response?.data['message'] ?? 'Bad request',
              code: statusCode.toString(),
            );
          case 401:
            return AuthenticationException(
              error.response?.data['message'] ?? 'Unauthorized',
              code: statusCode.toString(),
            );
          case 403:
            return AuthorizationException(
              error.response?.data['message'] ?? 'Forbidden',
              code: statusCode.toString(),
            );
          case 404:
            return NotFoundException(
              error.response?.data['message'] ?? 'Not found',
              code: statusCode.toString(),
            );
          case 500:
            return ServerException(
              error.response?.data['message'] ?? 'Internal server error',
              code: statusCode.toString(),
            );
          default:
            return ServerException(
              error.response?.data['message'] ?? 'Server error',
              code: statusCode.toString(),
            );
        }
      case DioExceptionType.cancel:
        return const NetworkException('Request cancelled');
      case DioExceptionType.connectionError:
        return const NetworkException('Connection error');
      case DioExceptionType.unknown:
        return NetworkException(
          error.message ?? 'Unknown network error',
          details: error.error,
        );
      default:
        return NetworkException(
          error.message ?? 'Network error',
          details: error.error,
        );
    }
  }
  
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  void updateAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }
  
  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }
}
