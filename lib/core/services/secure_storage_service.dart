import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

class SecureStorageService {
  late FlutterSecureStorage _storage;
  
  SecureStorageService();
  
  Future<void> init() async {
    _storage = const FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
      ),
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock_this_device,
      ),
    );
  }
  
  // Access Token
  Future<void> setAccessToken(String token) async {
    await _storage.write(key: AppConstants.accessTokenKey, value: token);
  }
  
  Future<String?> getAccessToken() async {
    return await _storage.read(key: AppConstants.accessTokenKey);
  }
  
  // Refresh Token
  Future<void> setRefreshToken(String token) async {
    await _storage.write(key: AppConstants.refreshTokenKey, value: token);
  }
  
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: AppConstants.refreshTokenKey);
  }
  
  // User Data
  Future<void> setUserData(String userData) async {
    await _storage.write(key: AppConstants.userDataKey, value: userData);
  }
  
  Future<String?> getUserData() async {
    return await _storage.read(key: AppConstants.userDataKey);
  }
  
  // Login Status
  Future<void> setIsLoggedIn(bool value) async {
    await _storage.write(key: AppConstants.isLoggedInKey, value: value.toString());
  }
  
  Future<bool> isLoggedIn() async {
    final value = await _storage.read(key: AppConstants.isLoggedInKey);
    return value == 'true';
  }
  
  // Clear All
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
  
  // Clear Token Only
  Future<void> clearTokens() async {
    await _storage.delete(key: AppConstants.accessTokenKey);
    await _storage.delete(key: AppConstants.refreshTokenKey);
  }
}
