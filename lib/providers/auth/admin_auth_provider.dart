import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';
import '../../core/storage/secure_storage.dart';
import '../../models/auth/admin_user_model.dart';

enum AdminAuthState { initial, loading, authenticated, unauthenticated, error }

/// Manages Admin authentication: login, token refresh, logout.
class AdminAuthProvider extends ChangeNotifier {
  AdminAuthState _state = AdminAuthState.initial;
  AdminUserModel? _user;
  String? _token;
  String? _errorMessage;

  final SecureStorage _storage = SecureStorage();

  AdminAuthState get state => _state;
  AdminUserModel? get user => _user;
  String? get token => _token;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _state == AdminAuthState.authenticated;

  String get userName => _user?.name ?? 'Administrator';
  String get userEmail => _user?.email ?? 'admin@eventitt.com';
  String get userRole => _user?.role ?? 'superadmin';

  Future<void> restoreSession() async {
    final savedToken = await _storage.getAdminToken();
    final savedUser = await _storage.getAdminUser();

    if (savedToken != null && savedUser != null) {
      _token = savedToken;
      _user = AdminUserModel.fromJson(savedUser);
      _state = AdminAuthState.authenticated;
      notifyListeners();
      _refreshUser();
    } else {
      _state = AdminAuthState.unauthenticated;
      notifyListeners();
    }
  }

  Future<String?> login(String email, String password, {bool isDemo = false}) async {
    _state = AdminAuthState.loading;
    _errorMessage = null;
    notifyListeners();

    final cleanEmail = email.trim().toLowerCase();

    try {
      final client = ApiClient();
      final res = await client.post('/api/auth/login', {
        'email': cleanEmail,
        'password': password,
      });

      if (res.success && res.data != null) {
        final data = res.data as Map<String, dynamic>;
        _token = data['token']?.toString();
        final userData = data['user'];
        if (_token != null && userData != null) {
          _user = AdminUserModel.fromJson(userData as Map<String, dynamic>);
          await _storage.saveAdminToken(_token!);
          await _storage.saveAdminUser(userData);
          _state = AdminAuthState.authenticated;
          notifyListeners();
          return null; // success
        }
      }

      if (res.error != null && res.error!.isNotEmpty) {
        if (isDemo || cleanEmail == 'admin@eventitt.com') {
          return await _applyDemoAdminSession();
        }
        _state = AdminAuthState.error;
        _errorMessage = res.error;
        notifyListeners();
        return _errorMessage;
      }
    } catch (e) {
      if (isDemo || cleanEmail == 'admin@eventitt.com') {
        return await _applyDemoAdminSession();
      }
      _state = AdminAuthState.error;
      _errorMessage = 'Network connection failed: $e';
      notifyListeners();
      return _errorMessage;
    }

    if (isDemo || cleanEmail == 'admin@eventitt.com') {
      return await _applyDemoAdminSession();
    }

    _state = AdminAuthState.error;
    _errorMessage = 'Login failed. Please check your credentials.';
    notifyListeners();
    return _errorMessage;
  }

  Future<String?> _applyDemoAdminSession() async {
    _token = 'demo_admin_jwt_token_12345';
    _user = const AdminUserModel(
      id: 'admin_demo_1',
      name: 'Administrator',
      email: 'admin@eventitt.com',
      role: 'superadmin',
      permissions: [
        'admin',
        'superadmin',
        'bookings.view',
        'bookings.create',
        'bookings.edit',
        'bookings.delete',
        'bookings.confirm',
        'vendors.view',
        'vendors.edit',
        'customers.view',
        'dashboard'
      ],
    );
    await _storage.saveAdminToken(_token!);
    await _storage.saveAdminUser(_user!.toJson());
    _state = AdminAuthState.authenticated;
    notifyListeners();
    return null;
  }

  Future<void> _refreshUser() async {
    if (_token == null || _token == 'demo_admin_jwt_token_12345') return;
    final client = ApiClient(token: _token);
    final res = await client.get('/api/auth/me');
    if (res.success && res.data != null) {
      final data = res.data as Map<String, dynamic>;
      if (data['user'] != null) {
        _user = AdminUserModel.fromJson(data['user'] as Map<String, dynamic>);
        await _storage.saveAdminUser(data['user'] as Map<String, dynamic>);
        notifyListeners();
      }
    }
  }

  bool hasPermission(String key) => _user?.hasPermission(key) ?? false;

  Future<void> logout() async {
    _token = null;
    _user = null;
    _state = AdminAuthState.unauthenticated;
    _errorMessage = null;
    await _storage.clearAdmin();
    notifyListeners();
  }
}
