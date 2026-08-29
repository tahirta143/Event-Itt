import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';
import '../../models/vendor/vendor_models.dart';

class VendorProfileProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isSaving = false;
  bool _isChangingPassword = false;
  String? _error;
  String? _message;

  VendorProfileModel? _profile;
  int _portfolioCount = 0;
  int _blackoutCount = 0;

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  bool get isChangingPassword => _isChangingPassword;
  String? get error => _error;
  String? get message => _message;
  VendorProfileModel? get profile => _profile;
  int get portfolioCount => _portfolioCount;
  int get blackoutCount => _blackoutCount;

  Future<void> fetchProfile(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final client = ApiClient(token: token);
    final results = await Future.wait([
      client.get('/api/vendor/me'),
      client.get('/api/vendor/portfolio'),
      client.get('/api/vendor/blackout-dates'),
    ]);

    final meRes = results[0];
    final pfRes = results[1];
    final blkRes = results[2];

    if (meRes.success && meRes.data != null) {
      final vendorMap = meRes.data is Map ? (meRes.data['vendor'] ?? meRes.data) : null;
      if (vendorMap is Map<String, dynamic>) {
        _profile = VendorProfileModel.fromJson(vendorMap);
      }
    } else {
      _error = meRes.error ?? 'Could not load profile';
    }

    if (pfRes.success && pfRes.data is List) {
      _portfolioCount = (pfRes.data as List).length;
    }

    if (blkRes.success && blkRes.data != null) {
      final days = blkRes.data is Map ? blkRes.data['days'] : (blkRes.data is List ? blkRes.data : []);
      _blackoutCount = (days as List).length;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> saveProfile(
    String token, {
    required String name,
    String? phone,
    String? address,
    String? city,
    String? description,
    String? logoFilePath,
  }) async {
    _isSaving = true;
    _error = null;
    notifyListeners();

    final client = ApiClient(token: token);
    final fields = <String, String>{
      'name': name.trim(),
      'contact_phone': phone?.trim() ?? '',
      'address': address?.trim() ?? '',
      'city': city?.trim() ?? '',
      'description': description?.trim() ?? '',
    };

    ApiResponse<dynamic> res;
    if (logoFilePath != null && logoFilePath.isNotEmpty) {
      res = await client.multipartPut(
        '/api/vendor/profile',
        fields: fields,
        filePath: logoFilePath,
        fileField: 'logo',
      );
    } else {
      res = await client.put('/api/vendor/profile', fields);
    }

    _isSaving = false;
    if (res.success && res.data != null) {
      final vendorMap = res.data is Map ? (res.data['vendor'] ?? res.data) : null;
      if (vendorMap is Map<String, dynamic>) {
        _profile = VendorProfileModel.fromJson(vendorMap);
      }
      _message = 'Profile updated successfully';
      notifyListeners();
      return true;
    } else {
      _error = res.error ?? 'Could not save profile';
      notifyListeners();
      return false;
    }
  }

  Future<bool> changePassword(
    String token, {
    required String currentPassword,
    required String newPassword,
  }) async {
    _isChangingPassword = true;
    _error = null;
    notifyListeners();

    final client = ApiClient(token: token);
    final res = await client.put('/api/vendor/password', {
      'current_password': currentPassword,
      'new_password': newPassword,
    });

    _isChangingPassword = false;
    if (res.success) {
      _message = 'Password changed successfully';
      notifyListeners();
      return true;
    } else {
      _error = res.error ?? 'Could not change password';
      notifyListeners();
      return false;
    }
  }
}
