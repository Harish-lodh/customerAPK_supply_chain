import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../constants/app_constants.dart';
import 'secure_storage_service.dart';
import 'session_service.dart';

class ApiService {
  late Dio _dio;
  final SecureStorageService secureStorage;
  bool _isRefreshing = false;
  
  ApiService({required this.secureStorage}) {
    _initDio();
  }
  
  void _initDio() {
    // Read base URL from dotenv
    final baseUrl = dotenv.env['BASE_URL'] ?? '';
    
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
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

  // ============================================
  // API ENDPOINTS
  // ============================================

  /// Get dashboard data
  /// GET /dashboard
  Future<Response> getDashboard() async {
    return await get(AppConstants.dashboardEndpoint);
  }

  /// Get drawdown list
  /// GET /drawdown/list
  Future<Response> getDrawdownList() async {
    return await get(AppConstants.drawdownListEndpoint);
  }

  /// Submit a new drawdown request
  /// POST /drawdown
  Future<Response> submitDrawdown(Map<String, dynamic> body) async {
    return await post(AppConstants.drawdownEndpoint, data: body);
  }

  /// Get all loans
  /// GET /loans
  Future<Response> getLoans() async {
    return await get(AppConstants.loansEndpoint);
  }

  /// Get loan details by loan ID
  /// GET /loans/detail?loanId={loanId}
  Future<Response> getLoanDetail(String loanId) async {
    return await get(
      AppConstants.loanDetailEndpoint,
      queryParameters: {'loanId': loanId},
    );
  }

  /// Get loan repayment schedule
  /// GET /loans/schedule?loanId={loanId}
  Future<Response> getLoanSchedule(String loanId) async {
    return await get(
      AppConstants.loanScheduleEndpoint,
      queryParameters: {'lan': loanId},
    );
  }

  /// Get loan statement for a date range
  /// GET /loans/statement?loanId={loanId}&fromDate={fromDate}&toDate={toDate}
  Future<Response> getLoanStatement(
    String loanId,
    String fromDate,
    String toDate,
  ) async {
    return await get(
      AppConstants.loanStatementEndpoint,
      queryParameters: {
        'loanId': loanId,
        'fromDate': fromDate,
        'toDate': toDate,
      },
    );
  }

  /// Get foreclosure preview for a loan
  /// GET /loans/foreclosure-preview?loanId={loanId}
  Future<Response> getForeclosurePreview(String loanId) async {
    return await get(
      AppConstants.loanForeclosurePreviewEndpoint,
      queryParameters: {'loanId': loanId},
    );
  }

  /// Get paginated transactions
  /// GET /transactions?page={page}&pageSize={pageSize}
  Future<Response> getTransactions(int page, int pageSize) async {
    return await get(
      AppConstants.transactionsEndpoint,
      queryParameters: {
        'page': page,
        'pageSize': pageSize,
      },
    );
  }

  /// Get transaction receipt by ID
  /// GET /transactions/{id}/receipt
  Future<Response> getTransactionReceipt(String id) async {
    return await get('${AppConstants.transactionsEndpoint}/$id/receipt');
  }

  /// Get all notifications
  /// GET /notifications
  Future<Response> getNotifications() async {
    return await get(AppConstants.notificationsEndpoint);
  }

  /// Mark a notification as read
  /// PUT /notifications/{id}/read
  Future<Response> markNotificationRead(String id) async {
    return await put('${AppConstants.notificationsEndpoint}/$id/read');
  }

  /// Mark all notifications as read
  /// PUT /notifications/read-all
  Future<Response> markAllNotificationsRead() async {
    return await put('${AppConstants.notificationsEndpoint}/read-all');
  }

  /// Get bank details for profile
  /// GET /profile/bank-details
  Future<Response> getBankDetails() async {
    return await get(AppConstants.bankDetailsEndpoint);
  }

  /// Logout user
  /// POST /auth/logout
  Future<Response> logout() async {
    return await post(AppConstants.logoutEndpoint);
  }

  /// Refresh access token
  /// POST /auth/refresh
  Future<Response> refreshToken(String refreshToken) async {
    return await post(
      AppConstants.refreshTokenEndpoint,
      data: {'refresh_token': refreshToken},
      options: Options(
        headers: {'Authorization': ''},
      ),
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
    // Skip auth for login/otp endpoints
    if (options.path.contains('/customers/login') ||
        options.path.contains('/customers/password')) {
      return handler.next(options);
    }
    
    // Get token from SessionService
    final token = await SessionService.getToken();
    
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
              
              // Also update token in SessionService
              await SessionService.updateToken(newAccessToken);
              
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
          await SessionService.clearSession();
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
