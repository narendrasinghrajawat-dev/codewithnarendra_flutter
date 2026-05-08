import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/env_config.dart';
import '../exceptions/app_exceptions.dart';

class NetworkService {
  late Dio _dio;
  String? _authToken;
  VoidCallback? _onUnauthorized;
  bool _isHandlingUnauthorized = false;
  
  NetworkService() {
    _dio = Dio(BaseOptions(
      baseUrl: 'http://localhost:3000/api', // Default, will be updated by EnvConfig
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    
    _setupInterceptors();
    _updateBaseUrlFromEnv();
  }
  
  void _updateBaseUrlFromEnv() {
    try {
      final baseUrl = EnvConfig.apiBaseUrl;
      final timeout = EnvConfig.apiTimeout;
      _dio.options.baseUrl = baseUrl;
      _dio.options.connectTimeout = Duration(milliseconds: timeout);
      _dio.options.receiveTimeout = Duration(milliseconds: timeout);
      _dio.options.sendTimeout = Duration(milliseconds: timeout);
      print('Base URL set to: $baseUrl');
    } catch (e) {
      print('Error updating base URL from env: $e');
      print('Using default base URL: http://localhost:3000/api');
      _dio.options.baseUrl = 'http://localhost:3000/api';
    }
  }
  
  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add auth token if available
          if (_authToken != null) {
            options.headers['Authorization'] = 'Bearer $_authToken';
          }
          
          // Add language header
          options.headers['Accept-Language'] = 'en';
          
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
          
          // Handle 401 Unauthorized - redirect to login (prevent multiple calls)
          if (error.response?.statusCode == 401 && _onUnauthorized != null && !_isHandlingUnauthorized) {
            _isHandlingUnauthorized = true;
            _onUnauthorized!();
            // Reset after a delay to allow future handling
            Future.delayed(const Duration(seconds: 2), () {
              _isHandlingUnauthorized = false;
            });
          }
          
          // Create new DioException with the converted error
          final convertedError = DioException(
            requestOptions: error.requestOptions,
            error: exception,
            type: error.type,
          );
          handler.reject(convertedError);
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
        print('Connection Error Details:');
        print('  Message: ${error.message}');
        print('  Error: ${error.error}');
        print('  Request: ${error.requestOptions.uri}');
        return NetworkException(
          'Connection error: ${error.message ?? "Cannot connect to server"}',
          details: error.error,
        );
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

    print('GET called: $path');
    try {
      final response = await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      print('GET SUCCESS: ${response.statusCode}');
      print('GET RESPONSE DATA: ${response.data}');
      return response;
    } on DioException catch (e) {
      print('GET ERROR: ${e.message}');
      print('GET ERROR TYPE: ${e.type}');
      throw _handleError(e);
    }
  }
  
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    print('POST called: $path');
    print('POST data: $data');

    try {
      final response = await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      print('POST SUCCESS: ${response.statusCode}');
      print('POST RESPONSE: ${response.data}');
      return response;
    } on DioException catch (e) {
      print('POST ERROR: ${e.message}');
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
      final response = await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      print('PUT response: ${response.data}');
      return response;
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
      final response = await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      print('DELETE response: ${response.data}');
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  void setAuthToken(String? token) {
    _authToken = token;
    if (_authToken != null) {
      _dio.options.headers['Authorization'] = 'Bearer $_authToken';
    } else {
      _dio.options.headers.remove('Authorization');
    }
  }
  
  void setOnUnauthorizedCallback(VoidCallback callback) {
    _onUnauthorized = callback;
    _isHandlingUnauthorized = false; // Reset flag when setting new callback
  }
  
  void clearOnUnauthorizedCallback() {
    _onUnauthorized = null;
    _isHandlingUnauthorized = false;
  }
  
  void resetUnauthorizedFlag() {
    _isHandlingUnauthorized = false;
  }
  
  void clearAuthToken() {
    _authToken = null;
    _dio.options.headers.remove('Authorization');
  }
}

/// Provider for NetworkService
final networkServiceProvider = Provider<NetworkService>((ref) {
  return NetworkService();
});
