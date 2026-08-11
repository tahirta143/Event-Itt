import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';
import '../../models/auth/vendor_auth_model.dart';

/// Admin vendors provider with pagination, search, subcategory assignment, update, and delete.
class AdminVendorsProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  List<VendorAuthModel> _vendors = [];
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalCount = 0;
  String _searchQuery = '';
  String _statusFilter = ''; // '', 'active', 'inactive'

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<VendorAuthModel> get vendors => _vendors;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalCount => _totalCount;
  String get searchQuery => _searchQuery;
  String get statusFilter => _statusFilter;

  Future<void> loadVendors(String token, {int page = 1, String? search, String? statusFilter}) async {
    _isLoading = true;
    _error = null;
    _currentPage = page;
    if (search != null) _searchQuery = search;
    if (statusFilter != null) _statusFilter = statusFilter;
    notifyListeners();

    final client = ApiClient(token: token);
    final res = await client.get('/api/vendors');

    if (res.success && res.data != null) {
      final data = res.data;
      List<dynamic> rawList = [];
      if (data is List) {
        rawList = data;
      } else if (data is Map && data['rows'] is List) {
        rawList = data['rows'] as List;
      } else if (data is Map && data['vendors'] is List) {
        rawList = data['vendors'] as List;
      }

      var parsed = rawList
          .map((e) => VendorAuthModel.fromJson(e as Map<String, dynamic>))
          .toList();

      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        parsed = parsed.where((v) =>
            v.vendorName.toLowerCase().contains(q) ||
            v.vendorEmail.toLowerCase().contains(q) ||
            v.businessName.toLowerCase().contains(q) ||
            (v.businessAddress).toLowerCase().contains(q)).toList();
      }

      if (_statusFilter == 'active') {
        parsed = parsed.where((v) => v.isActive).toList();
      } else if (_statusFilter == 'inactive') {
        parsed = parsed.where((v) => !v.isActive).toList();
      }

      _totalCount = parsed.length;
      const pageSize = 10;
      _totalPages = (_totalCount / pageSize).ceil().clamp(1, 999);

      final startIndex = ((_currentPage - 1) * pageSize).clamp(0, _totalCount);
      final endIndex = (startIndex + pageSize).clamp(0, _totalCount);

      if (startIndex < endIndex) {
        _vendors = parsed.sublist(startIndex, endIndex);
      } else {
        _vendors = parsed.isNotEmpty && _currentPage == 1 ? parsed : [];
      }
    } else {
      _error = res.error ?? 'Failed to load vendors.';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> nextPage(String token) async {
    if (_currentPage < _totalPages) {
      await loadVendors(token, page: _currentPage + 1);
    }
  }

  Future<void> prevPage(String token) async {
    if (_currentPage > 1) {
      await loadVendors(token, page: _currentPage - 1);
    }
  }

  Future<Map<String, dynamic>?> getVendorDetails(String token, String vendorId) async {
    final client = ApiClient(token: token);
    final res = await client.get('/api/vendors/$vendorId');
    if (res.success && res.data is Map<String, dynamic>) {
      return res.data as Map<String, dynamic>;
    }
    return null;
  }

  Future<String?> toggleVendorStatus(String token, String vendorId, bool isActive) async {
    final client = ApiClient(token: token);
    final res = await client.put('/api/vendors/$vendorId', {
      'is_active': isActive ? 1 : 0,
    });
    if (res.success) {
      await loadVendors(token, page: _currentPage);
      return null;
    }
    return res.error ?? 'Failed to update vendor status.';
  }

  Future<String?> createVendor({
    required String token,
    required String name,
    required String email,
    String? phone,
    String? address,
    String? description,
    String? password,
    String? logoUrl,
    String? imagePath,
    required bool isActive,
    List<String>? subcategoryIds,
  }) async {
    final client = ApiClient(token: token);
    final fields = <String, String>{
      'name': name,
      'contact_email': email,
      if (phone != null && phone.isNotEmpty) 'contact_phone': phone,
      if (address != null && address.isNotEmpty) 'address': address,
      if (description != null && description.isNotEmpty) 'description': description,
      if (password != null && password.isNotEmpty) 'password': password,
      if (logoUrl != null && logoUrl.isNotEmpty) 'logo_url': logoUrl,
      'is_active': isActive ? '1' : '0',
    };

    final res = (imagePath != null && imagePath.isNotEmpty)
        ? await client.multipartPost('/api/vendors', fields: fields, filePath: imagePath)
        : await client.post('/api/vendors', fields);

    if (res.success && res.data != null) {
      final vendorId = res.data['id']?.toString();
      if (vendorId != null && subcategoryIds != null && subcategoryIds.isNotEmpty) {
        await setVendorSubcategories(token, vendorId, subcategoryIds);
      }
      await loadVendors(token, page: 1);
      return null;
    }
    return res.error ?? 'Failed to create vendor.';
  }

  Future<String?> updateVendor({
    required String token,
    required String id,
    required String name,
    required String email,
    String? phone,
    String? address,
    String? description,
    String? password,
    String? logoUrl,
    String? imagePath,
    required bool isActive,
    List<String>? subcategoryIds,
  }) async {
    final client = ApiClient(token: token);
    final fields = <String, String>{
      'name': name,
      'contact_email': email,
      if (phone != null && phone.isNotEmpty) 'contact_phone': phone,
      if (address != null && address.isNotEmpty) 'address': address,
      if (description != null && description.isNotEmpty) 'description': description,
      if (password != null && password.isNotEmpty) 'password': password,
      if (logoUrl != null && logoUrl.isNotEmpty) 'logo_url': logoUrl,
      'is_active': isActive ? '1' : '0',
    };

    final res = (imagePath != null && imagePath.isNotEmpty)
        ? await client.multipartPut('/api/vendors/$id', fields: fields, filePath: imagePath)
        : await client.put('/api/vendors/$id', fields);

    if (res.success) {
      if (subcategoryIds != null) {
        await setVendorSubcategories(token, id, subcategoryIds);
      }
      await loadVendors(token, page: _currentPage);
      return null;
    }
    return res.error ?? 'Failed to update vendor.';
  }

  Future<String?> setVendorSubcategories(String token, String vendorId, List<String> subcategoryIds) async {
    final client = ApiClient(token: token);
    final ids = subcategoryIds.map((e) => int.tryParse(e) ?? e).toList();
    final res = await client.put('/api/vendors/$vendorId/subcategories', {
      'subcategory_ids': ids,
    });
    if (res.success) {
      return null;
    }
    return res.error ?? 'Failed to update vendor subcategories.';
  }

  Future<String?> deleteVendor(String token, String id) async {
    final client = ApiClient(token: token);
    final res = await client.delete('/api/vendors/$id');
    if (res.success) {
      await loadVendors(token, page: _currentPage);
      return null;
    }
    return res.error ?? 'Failed to delete vendor.';
  }
}
