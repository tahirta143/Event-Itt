import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';
import '../../models/auth/customer_model.dart';

/// Admin customers provider.
///
/// API endpoint:
///   GET /api/admin/customers → list of customers
class AdminCustomersProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  List<CustomerModel> _customers = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<CustomerModel> get customers => _customers;

  Future<void> loadCustomers(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final client = ApiClient(token: token);
    final res = await client.get('/api/admin/customers');

    if (res.success && res.data != null) {
      final data = res.data;
      List<dynamic> rawList = [];
      if (data is List) {
        rawList = data;
      } else if (data is Map && data['customers'] is List) {
        rawList = data['customers'] as List;
      } else if (data is Map && data['data'] is List) {
        rawList = data['data'] as List;
      }
      _customers = rawList
          .map((e) => CustomerModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      _error = res.error;
    }

    _isLoading = false;
    notifyListeners();
  }
}
