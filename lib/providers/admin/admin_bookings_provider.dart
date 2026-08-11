import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';
import '../../models/booking/booking_model.dart';

/// Admin bookings provider.
///
/// API endpoints:
///   GET    /api/admin/bookings             → list
///   PATCH  /api/admin/bookings/:id/status  → update status
///   DELETE /api/admin/bookings/:id         → delete
class AdminBookingsProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  List<BookingModel> _bookings = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<BookingModel> get bookings => _bookings;

  Future<void> loadBookings(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final client = ApiClient(token: token);
    final res = await client.get('/api/admin/bookings');

    if (res.success && res.data != null) {
      final data = res.data;
      List<dynamic> rawList = [];
      if (data is List) {
        rawList = data;
      } else if (data is Map && data['bookings'] is List) {
        rawList = data['bookings'] as List;
      } else if (data is Map && data['data'] is List) {
        rawList = data['data'] as List;
      }
      _bookings = rawList
          .map((e) => BookingModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      _error = res.error;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<String?> updateStatus(String token, String id, String status) async {
    final client = ApiClient(token: token);
    final res = await client.patch('/api/admin/bookings/$id/status', {'status': status});
    if (res.success) {
      // Update local list
      final idx = _bookings.indexWhere((b) => b.id == id);
      if (idx != -1) {
        final updated = BookingModel.fromJson({
          ...(_bookings[idx].toJson()),
          'status': status,
        });
        _bookings[idx] = updated;
        notifyListeners();
      }
      return null;
    }
    return res.error;
  }

  Future<String?> deleteBooking(String token, String id) async {
    final client = ApiClient(token: token);
    final res = await client.delete('/api/admin/bookings/$id');
    if (res.success) {
      _bookings.removeWhere((b) => b.id == id);
      notifyListeners();
      return null;
    }
    return res.error;
  }
}
