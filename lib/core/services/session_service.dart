import 'dart:html' show window;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// SessionService - Handles secure login session storage for Flutter SCF Customer App
/// Uses platform-based storage:
/// - Web: dart:html window.localStorage (keys stored directly without prefix)
/// - Android/iOS: flutter_secure_storage (encrypted storage)
class SessionService {
  // Storage keys - Production-grade names
  static const String _keyToken = 'token';
  static const String _keyCustomerId = 'customerId';
  static const String _keyCustomerName = 'customerName';
  static const String _keyCompanyName = 'companyName';
  static const String _keyIsLoggedIn = 'isLoggedIn';
  static const String _keyPartnerLanId = 'partnerLanId';

  // FlutterSecureStorage instance for mobile platforms
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  /// Save session data after successful login
  ///
  /// [token] - JWT authentication token
  /// [customerId] - Customer ID from backend
  /// [name] - Customer name
  /// [companyName] - Company name
  /// [partnerLanId] - Partner LAN ID from backend (optional)
  static Future<void> saveSession({
    required String token,
    required int customerId,
    required String name,
    required String companyName,
    String? partnerLanId,
  }) async {
    if (kIsWeb) {
      // Web: Use localStorage
      _WebStorageHelper.setItem(_keyToken, token);
      _WebStorageHelper.setItem(_keyCustomerId, customerId.toString());
      _WebStorageHelper.setItem(_keyCustomerName, name);
      _WebStorageHelper.setItem(_keyCompanyName, companyName);
      _WebStorageHelper.setItem(_keyIsLoggedIn, 'true');
      if (partnerLanId != null) {
        _WebStorageHelper.setItem(_keyPartnerLanId, partnerLanId);
      }
    } else {
      // Mobile: Use flutter_secure_storage
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

  /// Get the stored JWT token
  /// Returns null if not logged in
  static Future<String?> getToken() async {
    if (kIsWeb) {
      return _WebStorageHelper.getItem(_keyToken);
    } else {
      return await _secureStorage.read(key: _keyToken);
    }
  }

  /// Get the stored customer ID
  /// Returns null if not logged in
  static Future<int?> getCustomerId() async {
    if (kIsWeb) {
      final value = _WebStorageHelper.getItem(_keyCustomerId);
      return value != null ? int.tryParse(value) : null;
    } else {
      final value = await _secureStorage.read(key: _keyCustomerId);
      return value != null ? int.tryParse(value) : null;
    }
  }

  /// Get the stored customer name
  /// Returns null if not logged in
  static Future<String?> getCustomerName() async {
    if (kIsWeb) {
      return _WebStorageHelper.getItem(_keyCustomerName);
    } else {
      return await _secureStorage.read(key: _keyCustomerName);
    }
  }

  /// Get the stored company name
  /// Returns null if not logged in
  static Future<String?> getCompanyName() async {
    if (kIsWeb) {
      return _WebStorageHelper.getItem(_keyCompanyName);
    } else {
      return await _secureStorage.read(key: _keyCompanyName);
    }
  }

  /// Get the stored partner LAN ID
  /// Returns null if not available
  static Future<String?> getPartnerLanId() async {
    if (kIsWeb) {
      return _WebStorageHelper.getItem(_keyPartnerLanId);
    } else {
      return await _secureStorage.read(key: _keyPartnerLanId);
    }
  }

  /// Check if user is logged in
  /// Returns true if session exists and token is valid
  static Future<bool> isLoggedIn() async {
    if (kIsWeb) {
      final token = _WebStorageHelper.getItem(_keyToken);
      final isLoggedIn = _WebStorageHelper.getItem(_keyIsLoggedIn);
      return token != null && token.isNotEmpty && isLoggedIn == 'true';
    } else {
      final token = await _secureStorage.read(key: _keyToken);
      final isLoggedIn = await _secureStorage.read(key: _keyIsLoggedIn);
      return token != null && token.isNotEmpty && isLoggedIn == 'true';
    }
  }

  /// Clear all session data (logout)
  static Future<void> clearSession() async {
    if (kIsWeb) {
      // Web: Remove items from localStorage
      _WebStorageHelper.removeItem(_keyToken);
      _WebStorageHelper.removeItem(_keyCustomerId);
      _WebStorageHelper.removeItem(_keyCustomerName);
      _WebStorageHelper.removeItem(_keyCompanyName);
      _WebStorageHelper.removeItem(_keyIsLoggedIn);
      _WebStorageHelper.removeItem(_keyPartnerLanId);
    } else {
      // Mobile: Delete from secure storage
      await _secureStorage.delete(key: _keyToken);
      await _secureStorage.delete(key: _keyCustomerId);
      await _secureStorage.delete(key: _keyCustomerName);
      await _secureStorage.delete(key: _keyCompanyName);
      await _secureStorage.delete(key: _keyIsLoggedIn);
      await _secureStorage.delete(key: _keyPartnerLanId);
    }
  }

  /// Update token (for refresh scenarios)
  static Future<void> updateToken(String newToken) async {
    if (kIsWeb) {
      _WebStorageHelper.setItem(_keyToken, newToken);
    } else {
      await _secureStorage.write(key: _keyToken, value: newToken);
    }
  }
}

/// Web Storage Helper - Provides dart:html window.localStorage access
/// Only compiled and used when running on Web platform
class _WebStorageHelper {
  /// Set item in web localStorage
  /// Keys are stored directly without flutter. prefix
  static void setItem(String key, String value) {
    window.localStorage[key] = value;
  }

  /// Get item from web localStorage
  static String? getItem(String key) {
    return window.localStorage[key];
  }

  /// Remove item from web localStorage
  static void removeItem(String key) {
    window.localStorage.remove(key);
  }
}
