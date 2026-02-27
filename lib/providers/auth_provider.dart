import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/services/api_service.dart';
import '../core/services/secure_storage_service.dart';
import '../core/services/session_service.dart';
import '../models/auth_models.dart';

enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthProvider extends ChangeNotifier {
  final ApiService apiService;
  final SecureStorageService secureStorage;
  
  AuthState _state = AuthState.initial;
  User? _user;
  String? _errorMessage;
  bool _isOtpSent = false;
  String? _pendingMobileNumber;
  
  AuthProvider({
    required this.apiService,
    required this.secureStorage,
  }) {
    _checkAuthStatus();
  }
  
  // Getters
  AuthState get state => _state;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isOtpSent => _isOtpSent;
  bool get isAuthenticated => _state == AuthState.authenticated;
  String? get pendingMobileNumber => _pendingMobileNumber;
  
  // Check if user is already logged in
  Future<void> _checkAuthStatus() async {
    try {
      // Use SessionService for checking login status
      final isLoggedIn = await SessionService.isLoggedIn();
      
      if (isLoggedIn) {
        _state = AuthState.authenticated;
        // Load user data from SessionService
        final customerId = await SessionService.getCustomerId();
        final customerName = await SessionService.getCustomerName();
        final companyName = await SessionService.getCompanyName();
        
        if (customerId != null && customerName != null && companyName != null) {
          _user = User(
            id: customerId.toString(),
            mobileNumber: '',
            companyName: companyName,
            email: '',
            createdAt: DateTime.now(),
          );
        }
      } else {
        _state = AuthState.unauthenticated;
      }
    } catch (e) {
      _state = AuthState.unauthenticated;
    }
    notifyListeners();
  }
  
  // Request OTP for login
  Future<bool> requestOtp(String mobileNumber) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final response = await apiService.post(
        '/customers/login/otp',
        data: {'mobile': mobileNumber},
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        _isOtpSent = true;
        _pendingMobileNumber = mobileNumber;
        _state = AuthState.unauthenticated;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.data?['message'] ?? 'Failed to send OTP';
        _state = AuthState.error;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Failed to send OTP. Please try again.';
      _state = AuthState.error;
      notifyListeners();
      return false;
    }
  }
  
  // Send OTP (alias for requestOtp)
  Future<bool> sendOtp(String mobileNumber) => requestOtp(mobileNumber);
  
  // Verify OTP and Login
  Future<bool> verifyOtpAndLogin(String mobileNumber, String otp) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final response = await apiService.post(
        '/customers/login/otp/verify',
        data: {
          'mobile': mobileNumber,
          'otp': otp,
        },
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Try new backend format first, fall back to old format
        if (response.data['success'] == true && response.data['token'] != null) {
          // New backend format
          final loginResponse = LoginResponse.fromJson(response.data);
          
          // Save session using SessionService
          await SessionService.saveSession(
            token: loginResponse.token,
            customerId: int.tryParse(loginResponse.customer?.id ?? '0') ?? 0,
            name: loginResponse.customer?.name ?? '',
            companyName: loginResponse.customer?.companyName ?? '',
            partnerLanId: loginResponse.partnerLanId,
          );
          
          _user = User(
            id: loginResponse.customer?.id ?? '',
            mobileNumber: loginResponse.customer?.mobile ?? '',
            companyName: loginResponse.customer?.companyName ?? '',
            email: '',
            createdAt: DateTime.now(),
          );
        } else {
          // Old backend format
          final authResponse = AuthResponse.fromJson(response.data);
          
          // Store token in SharedPreferences (key: "auth_token")
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', authResponse.accessToken);
          
          // Also store in secure storage for other uses
          await secureStorage.setAccessToken(authResponse.accessToken);
          await secureStorage.setRefreshToken(authResponse.refreshToken);
          await secureStorage.setUserData(authResponse.user.toJson().toString());
          await secureStorage.setIsLoggedIn(true);
          
          _user = authResponse.user;
        }
        
        _state = AuthState.authenticated;
        _isOtpSent = false;
        _pendingMobileNumber = null;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.data?['message'] ?? 'Invalid OTP';
        _state = AuthState.error;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Invalid OTP. Please try again.';
      _state = AuthState.error;
      notifyListeners();
      return false;
    }
  }
  
  // Login with Password
  Future<bool> loginWithPassword(String mobileNumber, String password) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final response = await apiService.post(
        '/customers/login',
        data: {
          'mobile': mobileNumber,
          'password': password,
        },
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Try new backend format first, fall back to old format
        if (response.data['success'] == true && response.data['token'] != null) {
          // New backend format
          final loginResponse = LoginResponse.fromJson(response.data);
          
          // Save session using SessionService
          await SessionService.saveSession(
            token: loginResponse.token,
            customerId: int.tryParse(loginResponse.customer?.id ?? '0') ?? 0,
            name: loginResponse.customer?.name ?? '',
            companyName: loginResponse.customer?.companyName ?? '',
            partnerLanId: loginResponse.partnerLanId,
          );
          
          _user = User(
            id: loginResponse.customer?.id ?? '',
            mobileNumber: loginResponse.customer?.mobile ?? '',
            companyName: loginResponse.customer?.companyName ?? '',
            email: '',
            createdAt: DateTime.now(),
          );
        } else {
          // Old backend format
          final authResponse = AuthResponse.fromJson(response.data);
          
          // Store token in SharedPreferences (key: "auth_token")
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', authResponse.accessToken);
          
          // Also store in secure storage for other uses
          await secureStorage.setAccessToken(authResponse.accessToken);
          await secureStorage.setRefreshToken(authResponse.refreshToken);
          await secureStorage.setUserData(authResponse.user.toJson().toString());
          await secureStorage.setIsLoggedIn(true);
          
          _user = authResponse.user;
        }
        
        _state = AuthState.authenticated;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.data?['message'] ?? 'Invalid credentials';
        _state = AuthState.error;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Invalid credentials. Please try again.';
      _state = AuthState.error;
      notifyListeners();
      return false;
    }
  }
  
  // Set or update password
  Future<bool> setPassword(String mobileNumber, String password) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final response = await apiService.post(
        '/customers/password',
        data: {
          'mobile': mobileNumber,
          'password': password,
        },
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        _state = AuthState.unauthenticated;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.data?['message'] ?? 'Failed to set password';
        _state = AuthState.error;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Failed to set password. Please try again.';
      _state = AuthState.error;
      notifyListeners();
      return false;
    }
  }
  
  // Logout
  Future<void> logout() async {
    _state = AuthState.loading;
    notifyListeners();
    
    try {
      // Call logout API
      await apiService.logout();
    } catch (_) {
      // Continue with local logout even if API fails
    }
    
    try {
      // Clear session using SessionService
      await SessionService.clearSession();
      
      // Also clear SharedPreferences token for backward compatibility
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      
      // Clear secure storage
      await secureStorage.clearAll();
      
      _user = null;
      _state = AuthState.unauthenticated;
      _isOtpSent = false;
      _pendingMobileNumber = null;
    } catch (e) {
      // Even if API fails, clear local storage
      await SessionService.clearSession();
      await secureStorage.clearAll();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      _user = null;
      _state = AuthState.unauthenticated;
    }
    notifyListeners();
  }
  
  // Clear error
  void clearError() {
    _errorMessage = null;
    _state = AuthState.unauthenticated;
    notifyListeners();
  }
  
  // Reset OTP
  void resetOtp() {
    _isOtpSent = false;
    _pendingMobileNumber = null;
    notifyListeners();
  }
}
