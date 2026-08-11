import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';
import '../../models/auth/vendor_auth_model.dart';

/// Admin vendors provider.
///
/// API endpoints:
///   GET /api/admin/vendors      → list
///   PUT /api/admin/vendors/:id  → update vendor
class AdminVendorsProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  List<VendorAuthModel> _vendors = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<VendorAuthModel> get vendors => _vendors;

  Future<void> loadVendors(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final client = ApiClient(token: token);
    final res = await client.get('/api/admin/vendors');

    if (res.success && res.data != null) {
      final data = res.data;
      List<dynamic> rawList = [];
      if (data is List) {
        rawList = data;
      } else if (data is Map && data['vendors'] is List) {
        rawList = data['vendors'] as List;
      } else if (data is Map && data['data'] is List) {
        rawList = data['data'] as List;
      }
      _vendors = rawList
          .map((e) => VendorAuthModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      _error = res.error;
    }

    _isLoading = false;
    notifyListeners();
  }
}
