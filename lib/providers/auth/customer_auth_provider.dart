import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';
import '../../core/storage/secure_storage.dart';
import '../../models/auth/customer_model.dart';

enum CustomerAuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
  otpSent,
  profileNeeded,
}

/// Manages Customer authentication: OTP, demo login, and registration.
class CustomerAuthProvider extends ChangeNotifier {
  CustomerAuthState _state = CustomerAuthState.initial;
  CustomerModel? _customer;
  String? _token;
  String? _errorMessage;
  String? _pendingEmail;
  bool _isNewCustomer = false;

  final SecureStorage _storage = SecureStorage();

  CustomerAuthState get state => _state;
  CustomerModel? get customer => _customer;
  String? get token => _token;
  String? get errorMessage => _errorMessage;
  String? get pendingEmail => _pendingEmail;
  bool get isNewCustomer => _isNewCustomer;
  bool get isAuthenticated => _state == CustomerAuthState.authenticated;

  String get customerName => _customer?.name ?? 'Customer';
  String get customerEmail => _customer?.email ?? 'customer@eventitt.com';

  Future<void> restoreSession() async {
    final savedToken = await _storage.getCustomerToken();
    final savedCustomer = await _storage.getCustomerUser();

    if (savedToken != null && savedCustomer != null) {
      _token = savedToken;
      _customer = CustomerModel.fromJson(savedCustomer);
      _state = CustomerAuthState.authenticated;
      notifyListeners();
    } else {
      _state = CustomerAuthState.unauthenticated;
      notifyListeners();
    }
  }

  Future<String?> requestOtp(String email) async {
    _state = CustomerAuthState.loading;
    _errorMessage = null;
    _pendingEmail = email.trim().toLowerCase();
    notifyListeners();

    try {
      final client = ApiClient();
      final res = await client.post(
        '/api/customer/auth/request-otp',
        {'email': _pendingEmail!},
      );

      if (res.success) {
        _state = CustomerAuthState.otpSent;
        notifyListeners();
        return null;
      }
      _state = CustomerAuthState.error;
      _errorMessage = res.error ?? 'Failed to request OTP.';
      notifyListeners();
      return _errorMessage;
    } catch (e) {
      _state = CustomerAuthState.error;
      _errorMessage = 'Network connection failed: $e';
      notifyListeners();
      return _errorMessage;
    }
  }

  Future<String?> verifyOtp(String code) async {
    if (_pendingEmail == null || _pendingEmail!.isEmpty) {
      return 'Please enter your email first.';
    }

    _state = CustomerAuthState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final client = ApiClient();
      final res = await client.post('/api/customer/auth/verify-otp', {
        'email': _pendingEmail!,
        'code': code,
      });

      if (res.success && res.data != null) {
        final data = res.data as Map<String, dynamic>;
        _token = data['token']?.toString();
        _isNewCustomer = data['newCustomer'] == true;

        if (data['customer'] != null) {
          _customer = CustomerModel.fromJson(data['customer'] as Map<String, dynamic>);
        }

        if (_isNewCustomer) {
          _state = CustomerAuthState.profileNeeded;
          notifyListeners();
          return null;
        }

        if (_token != null && _customer != null) {
          await _storage.saveCustomerToken(_token!);
          await _storage.saveCustomerUser(_customer!.toJson());
          _state = CustomerAuthState.authenticated;
          notifyListeners();
          return null;
        }
      }

      _state = CustomerAuthState.error;
      _errorMessage = res.error ?? 'Invalid verification code.';
      notifyListeners();
      return _errorMessage;
    } catch (e) {
      _state = CustomerAuthState.error;
      _errorMessage = 'Verification error: $e';
      notifyListeners();
      return _errorMessage;
    }
  }

  Future<String?> completeProfile(String name, {String? phone}) async {
    if (_token == null || SecureStorage.isMockOrInvalidToken(_token)) {
      return 'Authentication required. Please request a new code.';
    }

    _state = CustomerAuthState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final body = <String, dynamic>{'name': name.trim()};
      if (phone != null && phone.isNotEmpty) body['phone'] = phone.trim();

      final client = ApiClient(token: _token);
      final res = await client.put('/api/customer/profile', body);

      if (res.success && res.data != null) {
        final data = res.data as Map<String, dynamic>;
        if (data['customer'] != null) {
          _customer = CustomerModel.fromJson(data['customer'] as Map<String, dynamic>);
        } else if (_customer != null) {
          _customer = _customer!.copyWith(name: name, phone: phone);
        }
        await _storage.saveCustomerToken(_token!);
        if (_customer != null) {
          await _storage.saveCustomerUser(_customer!.toJson());
        }
        _state = CustomerAuthState.authenticated;
        notifyListeners();
        return null;
      }

      _state = CustomerAuthState.error;
      _errorMessage = res.error ?? 'Failed to update profile.';
      notifyListeners();
      return _errorMessage;
    } catch (e) {
      _state = CustomerAuthState.error;
      _errorMessage = 'Failed to update profile: $e';
      notifyListeners();
      return _errorMessage;
    }
  }

  Future<String?> demoLogin(String email, String password) async {
    _state = CustomerAuthState.loading;
    _errorMessage = null;
    notifyListeners();

    final cleanEmail = email.trim().toLowerCase();

    try {
      final client = ApiClient();
      final res = await client.post('/api/customer/auth/login', {
        'email': cleanEmail,
        'password': password,
      });

      if (res.success && res.data != null) {
        final data = res.data as Map<String, dynamic>;
        _token = data['token']?.toString();
        if (data['customer'] != null) {
          _customer = CustomerModel.fromJson(data['customer'] as Map<String, dynamic>);
        }
        if (_token != null && _customer != null) {
          await _storage.saveCustomerToken(_token!);
          await _storage.saveCustomerUser(_customer!.toJson());
          _state = CustomerAuthState.authenticated;
          _errorMessage = null;
          notifyListeners();
          return null;
        }
      }

      _state = CustomerAuthState.error;
      _errorMessage = res.error ?? 'Invalid customer credentials.';
      notifyListeners();
      return _errorMessage;
    } catch (e) {
      _state = CustomerAuthState.error;
      _errorMessage = 'Customer login error: $e';
      notifyListeners();
      return _errorMessage;
    }
  }

  void handleUnauthorized() {
    if (_state == CustomerAuthState.authenticated) {
      logout();
    }
  }

  Future<String?> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    _state = CustomerAuthState.loading;
    _errorMessage = null;
    notifyListeners();

    final body = <String, dynamic>{
      'name': name.trim(),
      'email': email.trim(),
      'password': password,
    };
    if (phone != null && phone.isNotEmpty) body['phone'] = phone.trim();

    try {
      final client = ApiClient();
      final res = await client.post('/api/customer/auth/register', body);

      if (res.success) {
        _state = CustomerAuthState.unauthenticated;
        notifyListeners();
        return null;
      }
    } catch (_) {}

    _state = CustomerAuthState.unauthenticated;
    notifyListeners();
    return null;
  }

  void resetOtpState() {
    _pendingEmail = null;
    _isNewCustomer = false;
    _errorMessage = null;
    if (_state == CustomerAuthState.otpSent ||
        _state == CustomerAuthState.profileNeeded) {
      _state = CustomerAuthState.unauthenticated;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _token = null;
    _customer = null;
    _pendingEmail = null;
    _isNewCustomer = false;
    _state = CustomerAuthState.unauthenticated;
    _errorMessage = null;
    await _storage.clearCustomer();
    notifyListeners();
  }
}
