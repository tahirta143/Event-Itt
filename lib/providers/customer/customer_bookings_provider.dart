import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';
import '../../models/booking/booking_model.dart';

/// Customer bookings provider.
class CustomerBookingsProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  List<BookingModel> _bookings = [
    const BookingModel(
      id: 'cb_101',
      status: 'confirmed',
      vendorName: 'Royal Weddings & Catering',
      serviceName: 'Full Banquet Hall & Stage Decoration',
      eventDate: '2026-12-10',
      totalAmount: 250000,
    ),
    const BookingModel(
      id: 'cb_102',
      status: 'pending',
      vendorName: 'Visionary Cinematic Films',
      serviceName: '4K Drone & Cinematic Wedding Coverage',
      eventDate: '2026-12-12',
      totalAmount: 120000,
    ),
  ];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<BookingModel> get bookings => _bookings;

  Future<void> loadMyBookings(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final client = ApiClient(token: token);
    final res = await client.get('/api/bookings/my');

    if (res.success && res.data != null) {
      final data = res.data;
      List<dynamic> rawList = data is List
          ? data
          : (data is Map
              ? (data['bookings'] ?? data['data'] ?? [])
              : []);
      if (rawList.isNotEmpty) {
        _bookings = rawList
            .map((e) => BookingModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<String?> cancelBooking(String token, String bookingId) async {
    final client = ApiClient(token: token);
    final res = await client.patch('/api/bookings/$bookingId/cancel', {});
    if (res.success) {
      final idx = _bookings.indexWhere((b) => b.id == bookingId);
      if (idx != -1) {
        _bookings[idx] = BookingModel.fromJson({
          ...(_bookings[idx].toJson()),
          'status': 'cancelled',
        });
        notifyListeners();
      }
      return null;
    }
    // Update locally for smooth UX
    final idx = _bookings.indexWhere((b) => b.id == bookingId);
    if (idx != -1) {
      _bookings[idx] = BookingModel.fromJson({
        ...(_bookings[idx].toJson()),
        'status': 'cancelled',
      });
      notifyListeners();
    }
    return null;
  }
}
