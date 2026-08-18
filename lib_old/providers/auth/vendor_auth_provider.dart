import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';
import '../../core/storage/secure_storage.dart';
import '../../models/auth/vendor_auth_model.dart';

enum VendorAuthState { initial, loading, authenticated, unauthenticated, error }

/// Manages Vendor authentication: login, token refresh, profile update, logout.
class VendorAuthProvider extends ChangeNotifier {
  VendorAuthState _state = VendorAuthState.initial;
  VendorAuthModel? _vendor;
  String? _token;
  String? _errorMessage;

  final SecureStorage _storage = SecureStorage();

  VendorAuthState get state => _state;
  VendorAuthModel? get vendor => _vendor;
  String? get token => _token;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _state == VendorAuthState.authenticated;

  String get vendorName => _vendor?.name ?? 'Demo Vendor';
  String get businessName => _vendor?.businessName ?? 'Royal Weddings & Catering';
  String get vendorEmail => _vendor?.email ?? 'vendor@eventitt.com';

  Future<void> restoreSession() async {
    final savedToken = await _storage.getVendorToken();
    final savedVendor = await _storage.getVendorUser();

    if (savedToken != null && savedVendor != null) {
      _token = savedToken;
      _vendor = VendorAuthModel.fromJson(savedVendor);
      _state = VendorAuthState.authenticated;
      notifyListeners();
      await _refreshVendor();
    } else {
      _state = VendorAuthState.unauthenticated;
      notifyListeners();
    }
  }

  Future<String?> login(String email, String password, {bool isDemo = false}) async {
    _state = VendorAuthState.loading;
    _errorMessage = null;
    notifyListeners();

    final cleanEmail = email.trim().toLowerCase();

    try {
      final client = ApiClient();
      final res = await client.post('/api/vendor/auth/login', {
        'email': cleanEmail,
        'password': password,
      });

      if (res.success && res.data != null) {
        final data = res.data as Map<String, dynamic>;
        _token = data['token']?.toString();
        final vendorData = data['vendor'] as Map<String, dynamic>?;
        if (_token != null && vendorData != null) {
          _vendor = VendorAuthModel.fromJson(vendorData);
          await _storage.saveVendorToken(_token!);
          await _storage.saveVendorUser(vendorData);
          _state = VendorAuthState.authenticated;
          _errorMessage = null;
          notifyListeners();
          return null; // success
        }
      }

      _state = VendorAuthState.error;
      _errorMessage = res.error ?? 'Invalid vendor credentials.';
      notifyListeners();
      return _errorMessage;
    } catch (e) {
      _state = VendorAuthState.error;
      _errorMessage = 'Network connection failed: $e';
      notifyListeners();
      return _errorMessage;
    }
  }

  Future<void> _refreshVendor() async {
    if (_token == null || SecureStorage.isMockOrInvalidToken(_token)) {
      await logout();
      return;
    }

    final client = ApiClient(token: _token);
    final res = await client.get('/api/vendor/me');
    if (res.success && res.data != null) {
      final data = res.data as Map<String, dynamic>;
      if (data['vendor'] != null) {
        _vendor = VendorAuthModel.fromJson(data['vendor'] as Map<String, dynamic>);
        await _storage.saveVendorUser(data['vendor'] as Map<String, dynamic>);
        notifyListeners();
      }
    } else if (res.statusCode == 401) {
      debugPrint('⚠️ [VENDOR AUTH] Saved token rejected with 401 on /api/vendor/me. Evicting session.');
      await logout();
    }
  }

  void handleUnauthorized() {
    if (_state == VendorAuthState.authenticated) {
      logout();
    }
  }

  Future<void> logout() async {
    _token = null;
    _vendor = null;
    _state = VendorAuthState.unauthenticated;
    _errorMessage = null;
    await _storage.clearVendor();
    notifyListeners();
  }
}
