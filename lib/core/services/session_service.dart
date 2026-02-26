import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SessionService - Handles secure login session storage for Flutter SCF Customer App
/// Storage strategy:
/// - Web: shared_preferences (browser localStorage under the hood)
/// - Android/iOS: flutter_secure_storage (encrypted)
class SessionService {
  // Storage keys
  static const String _keyToken = 'token';
  static const String _keyCustomerId = 'customerId';
  static const String _keyCustomerName = 'customerName';
  static const String _keyCompanyName = 'companyName';
  static const String _keyIsLoggedIn = 'isLoggedIn';
  static const String _keyPartnerLanId = 'partnerLanId';

  // Secure storage for mobile
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  /* --------------------------------------------------------------------------
   * Save Session
   * -------------------------------------------------------------------------- */
  static Future<void> saveSession({
    required String token,
    required int customerId,
    required String name,
    required String companyName,
    String? partnerLanId,
  }) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyToken, token);
      await prefs.setString(_keyCustomerId, customerId.toString());
      await prefs.setString(_keyCustomerName, name);
      await prefs.setString(_keyCompanyName, companyName);
      await prefs.setBool(_keyIsLoggedIn, true);
      if (partnerLanId != null) {
        await prefs.setString(_keyPartnerLanId, partnerLanId);
      }
    } else {
      await _secureStorage.write(key: _keyToken, value: token);
      await _secureStorage.write(key: _keyCustomerId, value: customerId.toString());
      await _secureStorage.write(key: _keyCustomerName, value: name);
      await _secureStorage.write(key: _keyCompanyName, value: companyName);
      await _secureStorage.write(key: _keyIsLoggedIn, value: 'true');
      if (partnerLanId != null) {
        await _secureStorage.write(key: _keyPartnerLanId, value: partnerLanId);
      }
    }
  }

  /* --------------------------------------------------------------------------
   * Getters
   * -------------------------------------------------------------------------- */
  static Future<String?> getToken() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyToken);
    }
    return _secureStorage.read(key: _keyToken);
  }

  static Future<int?> getCustomerId() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final value = prefs.getString(_keyCustomerId);
      return value != null ? int.tryParse(value) : null;
    }
    final value = await _secureStorage.read(key: _keyCustomerId);
    return value != null ? int.tryParse(value) : null;
  }

  static Future<String?> getCustomerName() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyCustomerName);
    }
    return _secureStorage.read(key: _keyCustomerName);
  }

  static Future<String?> getCompanyName() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyCompanyName);
    }
    return _secureStorage.read(key: _keyCompanyName);
  }

  static Future<String?> getPartnerLanId() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyPartnerLanId);
    }
    return _secureStorage.read(key: _keyPartnerLanId);
  }

  /* --------------------------------------------------------------------------
   * Auth State
   * -------------------------------------------------------------------------- */
  static Future<bool> isLoggedIn() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_keyToken);
      final loggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
      return token != null && token.isNotEmpty && loggedIn;
    } else {
      final token = await _secureStorage.read(key: _keyToken);
      final loggedIn = await _secureStorage.read(key: _keyIsLoggedIn);
      return token != null && token.isNotEmpty && loggedIn == 'true';
    }
  }

  /* --------------------------------------------------------------------------
   * Clear Session
   * -------------------------------------------------------------------------- */
  static Future<void> clearSession() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyToken);
      await prefs.remove(_keyCustomerId);
      await prefs.remove(_keyCustomerName);
      await prefs.remove(_keyCompanyName);
      await prefs.remove(_keyIsLoggedIn);
      await prefs.remove(_keyPartnerLanId);
    } else {
      await _secureStorage.deleteAll();
    }
  }

  /* --------------------------------------------------------------------------
   * Update Token
   * -------------------------------------------------------------------------- */
  static Future<void> updateToken(String newToken) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyToken, newToken);
    } else {
      await _secureStorage.write(key: _keyToken, value: newToken);
    }
  }
}