import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';
import '../../models/vendor/vendor_models.dart';

class VendorRequestsProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;
  String? _message;

  List<VendorServiceRequestModel> _requests = [];
  List<dynamic> _catalogCategories = [];

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get error => _error;
  String? get message => _message;
  List<VendorServiceRequestModel> get requests => _requests;
  List<dynamic> get catalogCategories => _catalogCategories;

  Future<void> fetchRequests(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final client = ApiClient(token: token);
    final res = await client.get('/api/vendor/service-requests');
    if (res.success && res.data != null) {
      final list = (res.data is List ? res.data : (res.data is Map ? (res.data['requests'] ?? res.data['data'] ?? []) : [])) as List<dynamic>;
      _requests = list
          .map((r) => VendorServiceRequestModel.fromJson(r as Map<String, dynamic>))
          .toList();
    } else {
      _error = res.error ?? 'Could not load service requests';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchCatalogCategories(String token) async {
    final client = ApiClient(token: token);
    final res = await client.get('/api/vendor/catalog-categories');
    if (res.success && res.data != null) {
      if (res.data is List) {
        _catalogCategories = res.data as List;
      } else if (res.data is Map && res.data['categories'] is List) {
        _catalogCategories = res.data['categories'] as List;
      }
      notifyListeners();
    }
  }

  Future<bool> submitRequest(
    String token, {
    required String requestType,
    required int subcategoryId,
    String? reason,
  }) async {
    _isSaving = true;
    _error = null;
    notifyListeners();

    final client = ApiClient(token: token);
    final res = await client.post('/api/vendor/service-requests', {
      'request_type': requestType,
      'subcategory_id': subcategoryId,
      if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
    });

    _isSaving = false;
    if (res.success) {
      _message = 'Request submitted successfully';
      await fetchRequests(token);
      return true;
    } else {
      _error = res.error ?? 'Could not submit request';
      notifyListeners();
      return false;
    }
  }

  Future<bool> cancelRequest(String token, int requestId) async {
    _isSaving = true;
    _error = null;
    notifyListeners();

    final client = ApiClient(token: token);
    final res = await client.delete('/api/vendor/service-requests/$requestId');

    _isSaving = false;
    if (res.success) {
      _requests.removeWhere((r) => r.id == requestId);
      _message = 'Request cancelled';
      notifyListeners();
      return true;
    } else {
      _error = res.error ?? 'Could not cancel request';
      notifyListeners();
      return false;
    }
  }
}
