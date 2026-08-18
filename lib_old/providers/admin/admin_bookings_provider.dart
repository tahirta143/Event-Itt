import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';
import '../../core/storage/secure_storage.dart';
import '../../models/booking/booking_model.dart';

/// Admin bookings provider with pagination and search.
class AdminBookingsProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  List<BookingModel> _bookings = [];
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalCount = 0;
  String _searchQuery = '';
  String _statusFilter = '';
  String _priorityFilter = '';

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<BookingModel> get bookings => _bookings;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalCount => _totalCount;
  String get searchQuery => _searchQuery;
  String get statusFilter => _statusFilter;
  String get priorityFilter => _priorityFilter;

  Future<void> loadBookings(
    String token, {
    int page = 1,
    String? search,
    String? status,
    String? priority,
  }) async {
    if (SecureStorage.isMockOrInvalidToken(token)) return;

    _isLoading = true;
    _error = null;
    _currentPage = page;
    if (search != null) _searchQuery = search;
    if (status != null) _statusFilter = status;
    if (priority != null) _priorityFilter = priority;
    notifyListeners();

    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': '10',
    };
    if (_searchQuery.isNotEmpty) queryParams['search'] = _searchQuery;
    if (_statusFilter.isNotEmpty) queryParams['status'] = _statusFilter;
    if (_priorityFilter.isNotEmpty) queryParams['priority'] = _priorityFilter;

    final queryString = Uri(queryParameters: queryParams).query;
    final url = '/api/admin/bookings?$queryString';

    final client = ApiClient(token: token);
    final res = await client.get(url);

    if (res.success && res.data != null) {
      final data = res.data;
      if (data is Map<String, dynamic>) {
        final rows = (data['rows'] as List<dynamic>?) ?? [];
        _bookings = rows
            .map((e) => BookingModel.fromJson(e as Map<String, dynamic>))
            .toList();
        _totalPages = int.tryParse(data['totalPages']?.toString() ?? '1') ?? 1;
        _totalCount = int.tryParse(data['total']?.toString() ?? '0') ?? 0;
      } else if (data is List) {
        _bookings = data
            .map((e) => BookingModel.fromJson(e as Map<String, dynamic>))
            .toList();
        _totalPages = 1;
        _totalCount = _bookings.length;
      }
    } else {
      _error = res.error ?? 'Failed to load bookings.';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> nextPage(String token) async {
    if (_currentPage < _totalPages) {
      await loadBookings(token, page: _currentPage + 1);
    }
  }

  Future<void> prevPage(String token) async {
    if (_currentPage > 1) {
      await loadBookings(token, page: _currentPage - 1);
    }
  }

  Future<String?> updateStatus(String token, String id, String status) async {
    final client = ApiClient(token: token);
    final res = await client.patch('/api/admin/bookings/$id/status', {'status': status});
    if (res.success) {
      await loadBookings(token, page: _currentPage);
      return null;
    }
    return res.error ?? 'Failed to update status.';
  }

  Future<String?> deleteBooking(String token, String id) async {
    final client = ApiClient(token: token);
    final res = await client.delete('/api/admin/bookings/$id');
    if (res.success) {
      await loadBookings(token, page: _currentPage);
      return null;
    }
    return res.error ?? 'Failed to delete booking.';
  }
}
