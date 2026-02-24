import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';
import 'secure_storage_service.dart';

class ApiService {
  late Dio _dio;
  final SecureStorageService secureStorage;
  bool _isRefreshing = false;
  
  ApiService({required this.secureStorage}) {
    _initDio();
  }
  
  void _initDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    
    _dio.interceptors.addAll([
      _AuthInterceptor(secureStorage: secureStorage, apiService: this),
      LogInterceptor(
        requestBody: kDebugMode,
        responseBody: kDebugMode,
        logPrint: (obj) => debugPrint(obj.toString()),
      ),
    ]);
  }
  
  Dio get dio => _dio;
  
  bool get isRefreshing => _isRefreshing;
  
  set isRefreshing(bool value) => _isRefreshing = value;
  
  // Generic GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }
  
  // Generic POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
  
  // Generic PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
  
  // Generic DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
  
  // Download file
  Future<Response> download(
    String urlPath,
    String savePath, {
    ProgressCallback? onReceiveProgress,
  }) async {
    return await _dio.download(
      urlPath,
      savePath,
      onReceiveProgress: onReceiveProgress,
    );
  }
}

class _AuthInterceptor extends Interceptor {
  final SecureStorageService secureStorage;
  final ApiService apiService;
  
  _AuthInterceptor({
    required this.secureStorage,
    required this.apiService,
  });
  
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth for login/refresh endpoints
    if (options.path.contains('/auth/login') ||
        options.path.contains('/auth/refresh') ||
        options.path.contains('/auth/otp')) {
      return handler.next(options);
    }
    
    final token = await secureStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    
    return handler.next(options);
  }
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Token expired, try to refresh
      if (!apiService.isRefreshing) {
        apiService.isRefreshing = true;
        
        try {
          final refreshToken = await secureStorage.getRefreshToken();
          if (refreshToken != null) {
            final response = await apiService.post(
              AppConstants.refreshTokenEndpoint,
              data: {'refresh_token': refreshToken},
              options: Options(
                headers: {'Authorization': ''},
              ),
            );
            
            if (response.statusCode == 200) {
              final newAccessToken = response.data['access_token'];
              final newRefreshToken = response.data['refresh_token'];
              
              await secureStorage.setAccessToken(newAccessToken);
              await secureStorage.setRefreshToken(newRefreshToken);
              
              // Retry the original request
              final options = err.requestOptions;
              options.headers['Authorization'] = 'Bearer $newAccessToken';
              
              final retryResponse = await apiService.dio.fetch(options);
              apiService.isRefreshing = false;
              return handler.resolve(retryResponse);
            }
          }
        } catch (e) {
          apiService.isRefreshing = false;
          // Refresh failed, clear tokens and notify
          await secureStorage.clearAll();
        }
      }
    }
    
    return handler.next(err);
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;
  
  ApiException({
    required this.message,
    this.statusCode,
    this.data,
  });
  
  factory ApiException.fromDioException(DioException e) {
    String message;
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'Connection timeout. Please try again.';
        break;
      case DioExceptionType.connectionError:
        message = 'No internet connection. Please check your network.';
        break;
      case DioExceptionType.badResponse:
        message = _handleBadResponse(e.response);
        break;
      case DioExceptionType.cancel:
        message = 'Request cancelled.';
        break;
      default:
        message = 'Something went wrong. Please try again.';
    }
    
    return ApiException(
      message: message,
      statusCode: e.response?.statusCode,
      data: e.response?.data,
    );
  }
  
  static String _handleBadResponse(Response? response) {
    if (response == null) return 'No response from server.';
    
    switch (response.statusCode) {
      case 400:
        return response.data?['message'] ?? 'Bad request.';
      case 401:
        return 'Unauthorized. Please login again.';
      case 403:
        return 'Access denied.';
      case 404:
        return 'Resource not found.';
      case 500:
        return 'Server error. Please try again later.';
      default:
        return response.data?['message'] ?? 'Something went wrong.';
    }
  }
  
  @override
  String toString() => message;
}
