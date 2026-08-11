import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';
import '../../models/auth/customer_model.dart';

/// Admin customers provider with pagination and search.
class AdminCustomersProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  List<CustomerModel> _customers = [];
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalCount = 0;
  String _searchQuery = '';

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<CustomerModel> get customers => _customers;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalCount => _totalCount;
  String get searchQuery => _searchQuery;

  Future<void> loadCustomers(String token, {int page = 1, String? search}) async {
    _isLoading = true;
    _error = null;
    _currentPage = page;
    if (search != null) _searchQuery = search;
    notifyListeners();

    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': '10',
    };
    if (_searchQuery.isNotEmpty) queryParams['search'] = _searchQuery;

    final queryString = Uri(queryParameters: queryParams).query;
    final url = '/api/admin/customers?$queryString';

    final client = ApiClient(token: token);
    final res = await client.get(url);

    if (res.success && res.data != null) {
      final data = res.data;
      if (data is Map<String, dynamic>) {
        final rows = (data['rows'] as List<dynamic>?) ?? [];
        _customers = rows
            .map((e) => CustomerModel.fromJson(e as Map<String, dynamic>))
            .toList();
        _totalPages = int.tryParse(data['totalPages']?.toString() ?? '1') ?? 1;
        _totalCount = int.tryParse(data['total']?.toString() ?? '0') ?? 0;
      } else if (data is List) {
        _customers = data
            .map((e) => CustomerModel.fromJson(e as Map<String, dynamic>))
            .toList();
        _totalPages = 1;
        _totalCount = _customers.length;
      }
    } else {
      _error = res.error ?? 'Failed to load customers.';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> nextPage(String token) async {
    if (_currentPage < _totalPages) {
      await loadCustomers(token, page: _currentPage + 1);
    }
  }

  Future<void> prevPage(String token) async {
    if (_currentPage > 1) {
      await loadCustomers(token, page: _currentPage - 1);
    }
  }

  Future<String?> createCustomer(String token, {required String name, required String email, String? phone, String? notes}) async {
    final client = ApiClient(token: token);
    final res = await client.post('/api/admin/customers', {
      'name': name,
      'email': email,
      if (phone != null) 'phone': phone,
      if (notes != null) 'notes': notes,
    });
    if (res.success) {
      await loadCustomers(token, page: 1);
      return null;
    }
    return res.error ?? 'Failed to create customer.';
  }
}
