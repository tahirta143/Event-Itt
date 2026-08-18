import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';
import '../../core/storage/secure_storage.dart';
import '../../models/booking/booking_model.dart';

class WeddingEventModel {
  final String id;
  final String eventType;
  final String customLabel;
  final String? eventDate;
  final String? coverImageUrl;
  final int bookingCount;
  final String? venue;

  const WeddingEventModel({
    required this.id,
    required this.eventType,
    required this.customLabel,
    this.eventDate,
    this.coverImageUrl,
    this.bookingCount = 0,
    this.venue,
  });

  factory WeddingEventModel.fromJson(Map<String, dynamic> json) {
    return WeddingEventModel(
      id: json['id']?.toString() ?? '',
      eventType: json['event_type']?.toString() ?? 'engagement',
      customLabel: json['custom_label']?.toString() ?? json['event_type']?.toString() ?? 'Event',
      eventDate: json['event_date']?.toString(),
      coverImageUrl: json['cover_image_url']?.toString(),
      bookingCount: int.tryParse(json['booking_count']?.toString() ?? '0') ?? 0,
      venue: json['venue']?.toString(),
    );
  }
}

/// Customer bookings provider — handles real API calls for customer bookings & wedding events.
class CustomerBookingsProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  List<BookingModel> _bookings = [];
  List<WeddingEventModel> _weddingEvents = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<BookingModel> get bookings => _bookings;
  List<WeddingEventModel> get weddingEvents => _weddingEvents;

  Future<void> loadAll(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    await Future.wait([
      loadMyBookings(token, isSilent: true),
      loadWeddingEvents(token, isSilent: true),
    ]);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadMyBookings(String token, {bool isSilent = false}) async {
    if (SecureStorage.isMockOrInvalidToken(token)) return;

    if (!isSilent) {
      _isLoading = true;
      _error = null;
      notifyListeners();
    }

    final client = ApiClient(token: token);
    final res = await client.get('/api/bookings/my');

    if (res.success && res.data != null) {
      final data = res.data;
      List<dynamic> rawList = data is List
          ? data
          : (data is Map ? (data['bookings'] ?? data['data'] ?? []) : []);
      _bookings = rawList
          .map((e) => BookingModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    if (!isSilent) {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadWeddingEvents(String token, {bool isSilent = false}) async {
    final client = ApiClient(token: token);
    final res = await client.get('/api/wedding-events');

    if (res.success && res.data != null) {
      final data = res.data;
      List<dynamic> rawList = data is List ? data : [];
      _weddingEvents = rawList
          .map((e) => WeddingEventModel.fromJson(e as Map<String, dynamic>))
          .toList();
      notifyListeners();
    }
  }

  Future<String?> createBooking({
    required String token,
    required String subcategoryId,
    String? eventId,
    required String eventDate,
    required int guestCount,
    String? specialRequests,
  }) async {
    final client = ApiClient(token: token);
    final body = <String, dynamic>{
      'subcategory_id': int.tryParse(subcategoryId) ?? subcategoryId,
      if (eventId != null && eventId.isNotEmpty) 'event_id': int.tryParse(eventId) ?? eventId,
      'event_date': eventDate,
      'guest_count': guestCount,
      if (specialRequests != null && specialRequests.isNotEmpty) 'special_requests': specialRequests,
    };

    final res = await client.post('/api/bookings', body);
    if (res.success) {
      await loadAll(token);
      return null;
    }
    return res.error ?? 'Booking failed.';
  }

  Future<String?> cancelBooking(String token, String bookingId) async {
    final client = ApiClient(token: token);
    final res = await client.patch('/api/bookings/$bookingId/cancel', {});
    if (res.success) {
      await loadMyBookings(token);
      return null;
    }
    return res.error ?? 'Failed to cancel booking.';
  }
}
