import 'package:flutter/foundation.dart';
import '../core/services/api_service.dart';
import '../core/services/secure_storage_service.dart';
import '../core/constants/app_constants.dart';
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
  
  // Check if user is already logged in
  Future<void> _checkAuthStatus() async {
    try {
      final isLoggedIn = await secureStorage.isLoggedIn();
      final token = await secureStorage.getAccessToken();
      
      if (isLoggedIn && token != null) {
        _state = AuthState.authenticated;
        // Load user data from storage
        final userData = await secureStorage.getUserData();
        if (userData != null) {
          // Parse user data - in real app, parse from JSON
          _user = User(
            id: '1',
            mobileNumber: '+91 9876543210',
            companyName: 'ABC Traders Pvt Ltd',
            email: 'contact@abctraders.com',
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
  
  // Login with OTP
  Future<bool> sendOtp(String mobileNumber) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // In real app, call API
      // final response = await apiService.post(
      //   AppConstants.otpEndpoint,
      //   data: {'mobile_number': mobileNumber},
      // );
      
      _isOtpSent = true;
      _state = AuthState.unauthenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to send OTP. Please try again.';
      _state = AuthState.error;
      notifyListeners();
      return false;
    }
  }
  
  // Verify OTP and Login
  Future<bool> verifyOtpAndLogin(String mobileNumber, String otp) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock successful response
      final response = AuthResponse(
        accessToken: 'mock_access_token_${DateTime.now().millisecondsSinceEpoch}',
        refreshToken: 'mock_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
        user: User(
          id: '1',
          mobileNumber: mobileNumber,
          companyName: 'ABC Traders Pvt Ltd',
          email: 'contact@abctraders.com',
          panNumber: 'AABCU9600R1ZN',
          gstNumber: '29AABCU9600R1ZN',
          createdAt: DateTime.now(),
        ),
      );
      
      // Save tokens
      await secureStorage.setAccessToken(response.accessToken);
      await secureStorage.setRefreshToken(response.refreshToken);
      await secureStorage.setUserData(response.user.toJson().toString());
      await secureStorage.setIsLoggedIn(true);
      
      _user = response.user;
      _state = AuthState.authenticated;
      notifyListeners();
      return true;
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
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock successful response
      final response = AuthResponse(
        accessToken: 'mock_access_token_${DateTime.now().millisecondsSinceEpoch}',
        refreshToken: 'mock_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
        user: User(
          id: '1',
          mobileNumber: mobileNumber,
          companyName: 'ABC Traders Pvt Ltd',
          email: 'contact@abctraders.com',
          createdAt: DateTime.now(),
        ),
      );
      
      // Save tokens
      await secureStorage.setAccessToken(response.accessToken);
      await secureStorage.setRefreshToken(response.refreshToken);
      await secureStorage.setUserData(response.user.toJson().toString());
      await secureStorage.setIsLoggedIn(true);
      
      _user = response.user;
      _state = AuthState.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Invalid credentials. Please try again.';
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
      // await apiService.post(AppConstants.logoutEndpoint);
      
      // Clear local storage
      await secureStorage.clearAll();
      
      _user = null;
      _state = AuthState.unauthenticated;
      _isOtpSent = false;
    } catch (e) {
      // Even if API fails, clear local storage
      await secureStorage.clearAll();
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
    notifyListeners();
  }
}
