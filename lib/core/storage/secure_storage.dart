import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Keys {
  static const String adminToken = 'ei_admin_token';
  static const String adminUser = 'ei_admin_user';
  static const String vendorToken = 'ei_vendor_token';
  static const String vendorUser = 'ei_vendor_user';
  static const String customerToken = 'ei_customer_token';
  static const String customerUser = 'ei_customer_user';
}

/// Handles persisting auth tokens and user objects across app restarts.
/// Exception-safe with in-memory fallbacks in case native platform channel is unavailable.
class SecureStorage {
  static final SecureStorage _instance = SecureStorage._internal();
  factory SecureStorage() => _instance;
  SecureStorage._internal();

  SharedPreferences? _prefs;
  final Map<String, String> _memCache = {};

  Future<SharedPreferences?> get _storage async {
    if (_prefs != null) return _prefs;
    try {
      _prefs = await SharedPreferences.getInstance();
      return _prefs;
    } catch (e) {
      debugPrint('⚠️ [STORAGE WARNING] SharedPreferences platform channel error: $e');
      return null;
    }
  }

  Future<void> _setString(String key, String value) async {
    _memCache[key] = value;
    try {
      final s = await _storage;
      await s?.setString(key, value);
    } catch (e) {
      debugPrint('⚠️ [STORAGE WRITE WARNING] Failed for key $key: $e');
    }
  }

  Future<String?> _getString(String key) async {
    if (_memCache.containsKey(key)) return _memCache[key];
    try {
      final s = await _storage;
      final val = s?.getString(key);
      if (val != null) _memCache[key] = val;
      return val;
    } catch (e) {
      debugPrint('⚠️ [STORAGE READ WARNING] Failed for key $key: $e');
      return null;
    }
  }

  Future<void> _remove(String key) async {
    _memCache.remove(key);
    try {
      final s = await _storage;
      await s?.remove(key);
    } catch (e) {
      debugPrint('⚠️ [STORAGE REMOVE WARNING] Failed for key $key: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Admin
  // ---------------------------------------------------------------------------

  Future<void> saveAdminToken(String token) async => _setString(_Keys.adminToken, token);
  Future<String?> getAdminToken() async => _getString(_Keys.adminToken);

  Future<void> saveAdminUser(Map<String, dynamic> user) async =>
      _setString(_Keys.adminUser, jsonEncode(user));

  Future<Map<String, dynamic>?> getAdminUser() async {
    final raw = await _getString(_Keys.adminUser);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> clearAdmin() async {
    await _remove(_Keys.adminToken);
    await _remove(_Keys.adminUser);
  }

  // ---------------------------------------------------------------------------
  // Vendor
  // ---------------------------------------------------------------------------

  Future<void> saveVendorToken(String token) async => _setString(_Keys.vendorToken, token);
  Future<String?> getVendorToken() async => _getString(_Keys.vendorToken);

  Future<void> saveVendorUser(Map<String, dynamic> vendor) async =>
      _setString(_Keys.vendorUser, jsonEncode(vendor));

  Future<Map<String, dynamic>?> getVendorUser() async {
    final raw = await _getString(_Keys.vendorUser);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> clearVendor() async {
    await _remove(_Keys.vendorToken);
    await _remove(_Keys.vendorUser);
  }

  // ---------------------------------------------------------------------------
  // Customer
  // ---------------------------------------------------------------------------

  Future<void> saveCustomerToken(String token) async => _setString(_Keys.customerToken, token);
  Future<String?> getCustomerToken() async => _getString(_Keys.customerToken);

  Future<void> saveCustomerUser(Map<String, dynamic> customer) async =>
      _setString(_Keys.customerUser, jsonEncode(customer));

  Future<Map<String, dynamic>?> getCustomerUser() async {
    final raw = await _getString(_Keys.customerUser);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> clearCustomer() async {
    await _remove(_Keys.customerToken);
    await _remove(_Keys.customerUser);
  }

  Future<void> clearAll() async {
    await clearAdmin();
    await clearVendor();
    await clearCustomer();
  }
}
