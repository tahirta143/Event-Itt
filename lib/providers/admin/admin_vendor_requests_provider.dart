import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';

class VendorRequestModel {
  final String id;
  final String vendorId;
  final String vendorName;
  final String vendorEmail;
  final String type; // 'link' or 'unlink'
  final String subcategoryId;
  final String subcategoryName;
  final String categoryName;
  final String status; // 'pending', 'approved', 'rejected'
  final String? rejectionNote;
  final String? createdAt;

  VendorRequestModel({
    required this.id,
    required this.vendorId,
    required this.vendorName,
    required this.vendorEmail,
    required this.type,
    required this.subcategoryId,
    required this.subcategoryName,
    required this.categoryName,
    required this.status,
    this.rejectionNote,
    this.createdAt,
  });

  factory VendorRequestModel.fromJson(Map<String, dynamic> json) {
    return VendorRequestModel(
      id: json['id']?.toString() ?? '',
      vendorId: json['vendor_id']?.toString() ?? '',
      vendorName: json['vendor_name']?.toString() ?? 'Vendor',
      vendorEmail: json['vendor_email']?.toString() ?? '',
      type: json['type']?.toString() ?? 'link',
      subcategoryId: json['subcategory_id']?.toString() ?? '',
      subcategoryName: json['subcategory_name']?.toString() ?? 'Subcategory',
      categoryName: json['category_name']?.toString() ?? 'Category',
      status: json['status']?.toString() ?? 'pending',
      rejectionNote: json['rejection_note']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }
}

class AdminVendorRequestsProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  List<VendorRequestModel> _requests = [];
  String _statusFilter = 'pending';
  String _searchQuery = '';

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<VendorRequestModel> get requests => _requests;
  String get statusFilter => _statusFilter;
  String get searchQuery => _searchQuery;

  Future<void> loadRequests(String token, {String? status, String? search}) async {
    _isLoading = true;
    _error = null;
    if (status != null) _statusFilter = status;
    if (search != null) _searchQuery = search;
    notifyListeners();

    final queryParams = <String, String>{};
    if (_statusFilter.isNotEmpty) queryParams['status'] = _statusFilter;
    if (_searchQuery.isNotEmpty) queryParams['search'] = _searchQuery;

    final queryString = Uri(queryParameters: queryParams).query;
    final url = '/api/admin/vendor-requests${queryString.isNotEmpty ? '?$queryString' : ''}';

    final client = ApiClient(token: token);
    final res = await client.get(url);

    if (res.success && res.data != null) {
      final List<dynamic> list = res.data is List ? res.data : [];
      _requests = list
          .map((e) => VendorRequestModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      _error = res.error ?? 'Failed to load vendor requests.';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<String?> approveRequest(String token, String id) async {
    final client = ApiClient(token: token);
    final res = await client.post('/api/admin/vendor-requests/$id/approve', {});
    if (res.success) {
      await loadRequests(token);
      return null;
    }
    return res.error ?? 'Failed to approve request.';
  }

  Future<String?> rejectRequest(String token, String id, String note) async {
    final client = ApiClient(token: token);
    final res = await client.post('/api/admin/vendor-requests/$id/reject', {
      'rejection_note': note,
    });
    if (res.success) {
      await loadRequests(token);
      return null;
    }
    return res.error ?? 'Failed to reject request.';
  }
}
