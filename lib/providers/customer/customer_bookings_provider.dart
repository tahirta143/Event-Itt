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
  final bool isSelected;

  const WeddingEventModel({
    required this.id,
    required this.eventType,
    required this.customLabel,
    this.eventDate,
    this.coverImageUrl,
    this.bookingCount = 0,
    this.venue,
    this.isSelected = false,
  });

  factory WeddingEventModel.fromJson(Map<String, dynamic> json) {
    final sel = json['is_selected'];
    final bool isSel = sel == true || sel == 1 || sel == '1';

    return WeddingEventModel(
      id: json['id']?.toString() ?? '',
      eventType: json['event_type']?.toString() ?? 'engagement',
      customLabel: json['custom_label']?.toString() ??
          json['event_type']?.toString() ??
          'Event',
      eventDate: json['event_date']?.toString(),
      coverImageUrl: json['cover_image_url']?.toString(),
      bookingCount: int.tryParse(json['booking_count']?.toString() ?? '0') ?? 0,
      venue: json['venue']?.toString(),
      isSelected: isSel,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'event_type': eventType,
        'custom_label': customLabel,
        'event_date': eventDate,
        'cover_image_url': coverImageUrl,
        'booking_count': bookingCount,
        'venue': venue,
        'is_selected': isSelected,
      };
}

/// Customer bookings provider — handles real API calls for customer bookings,
/// wedding events lifecycle, payments, and vendor reviews.
class CustomerBookingsProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  List<BookingModel> _bookings = [];
  List<WeddingEventModel> _weddingEvents = [];
  String _selectedFilter = 'all';
  String? _selectedEventId;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<BookingModel> get bookings => _bookings;
  List<WeddingEventModel> get weddingEvents => _weddingEvents;
  String get selectedFilter => _selectedFilter;
  String? get selectedEventId => _selectedEventId;

  WeddingEventModel? get selectedWeddingEvent {
    if (_selectedEventId == null) return null;
    try {
      return _weddingEvents.firstWhere((e) => e.id == _selectedEventId);
    } catch (_) {
      return null;
    }
  }

  List<BookingModel> get filteredBookings {
    var list = _bookings;
    if (_selectedEventId != null && _selectedEventId!.isNotEmpty) {
      list = list.where((b) => b.eventId == _selectedEventId).toList();
    }
    if (_selectedFilter != 'all') {
      list = list
          .where((b) => b.status.toLowerCase() == _selectedFilter.toLowerCase())
          .toList();
    }
    return list;
  }

  int getCountByStatus(String status) {
    var list = _bookings;
    if (_selectedEventId != null && _selectedEventId!.isNotEmpty) {
      list = list.where((b) => b.eventId == _selectedEventId).toList();
    }
    if (status == 'all') return list.length;
    return list
        .where((b) => b.status.toLowerCase() == status.toLowerCase())
        .length;
  }

  void setFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  void toggleEventFilter(String? eventId) {
    if (_selectedEventId == eventId) {
      _selectedEventId = null;
    } else {
      _selectedEventId = eventId;
    }
    notifyListeners();
  }

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
    } else {
      _error = res.error;
    }

    if (!isSilent) {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadWeddingEvents(String token, {bool isSilent = false}) async {
    if (SecureStorage.isMockOrInvalidToken(token)) return;

    final client = ApiClient(token: token);
    final res = await client.get('/api/wedding-events');

    if (res.success && res.data != null) {
      final data = res.data;
      List<dynamic> rawList = data is List
          ? data
          : (data is Map ? (data['events'] ?? data['data'] ?? []) : []);
      _weddingEvents = rawList
          .map((e) => WeddingEventModel.fromJson(e as Map<String, dynamic>))
          .toList();
      notifyListeners();
    }
  }

  Future<WeddingEventModel?> createWeddingEvent({
    required String token,
    required String eventType,
    required String customLabel,
    String? eventDate,
    String? venue,
    String? coverImageUrl,
  }) async {
    final client = ApiClient(token: token);
    final body = <String, dynamic>{
      'event_type': eventType,
      'custom_label': customLabel,
      if (eventDate != null && eventDate.isNotEmpty) 'event_date': eventDate,
      if (venue != null && venue.isNotEmpty) 'venue': venue,
      if (coverImageUrl != null && coverImageUrl.isNotEmpty)
        'cover_image_url': coverImageUrl,
    };

    final res = await client.post('/api/wedding-events', body);
    if (res.success && res.data != null) {
      final created = WeddingEventModel.fromJson(
          res.data is Map<String, dynamic> ? res.data : {});
      _weddingEvents.insert(0, created);
      notifyListeners();
      return created;
    }
    return null;
  }

  Future<String?> createBooking({
    required String token,
    required String subcategoryId,
    List<String>? eventIds,
    String? eventId,
    required String eventDate,
    required int guestCount,
    String? specialRequests,
  }) async {
    final client = ApiClient(token: token);
    final subId = int.tryParse(subcategoryId);

    // List of event IDs to create bookings for
    final targetEventIds = <String>[];
    if (eventIds != null && eventIds.isNotEmpty) {
      targetEventIds.addAll(eventIds);
    } else if (eventId != null && eventId.isNotEmpty) {
      targetEventIds.add(eventId);
    }

    if (targetEventIds.isEmpty) {
      // Direct booking without specified event
      final body = <String, dynamic>{
        'subcategory_id': subId ?? subcategoryId,
        'event_date': eventDate,
        'guest_count': guestCount,
        if (specialRequests != null && specialRequests.trim().isNotEmpty)
          'special_requests': specialRequests.trim(),
      };
      final res = await client.post('/api/bookings', body);
      if (res.success) {
        await loadAll(token);
        return null;
      }
      return res.error ?? 'Booking failed.';
    }

    // Multi-event or single event booking
    int successCount = 0;
    String? lastError;

    for (final evId in targetEventIds) {
      final parsedEvId = int.tryParse(evId);
      final body = <String, dynamic>{
        'subcategory_id': subId ?? subcategoryId,
        'event_id': parsedEvId ?? evId,
        'event_date': eventDate,
        'guest_count': guestCount,
        if (specialRequests != null && specialRequests.trim().isNotEmpty)
          'special_requests': specialRequests.trim(),
      };

      final res = await client.post('/api/bookings', body);
      if (res.success) {
        successCount++;
      } else {
        lastError = res.error;
      }
    }

    if (successCount > 0) {
      await loadAll(token);
      return null;
    }

    return lastError ?? 'Booking request failed.';
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

  Future<String?> submitReview({
    required String token,
    required String bookingId,
    required int rating,
    required String comment,
  }) async {
    final client = ApiClient(token: token);
    final res = await client.post('/api/bookings/$bookingId/review', {
      'rating': rating,
      'comment': comment.trim(),
    });

    if (res.success) {
      await loadMyBookings(token);
      return null;
    }
    return res.error ?? 'Failed to submit review.';
  }

  // ---------------------------------------------------------------------------
  // Payments & Invoicing
  // ---------------------------------------------------------------------------

  Future<String?> confirmCOD(String token, String bookingId) async {
    final client = ApiClient(token: token);
    final res = await client.post(
      '/api/customer/bookings/$bookingId/confirm-cod',
      {},
    );
    if (res.success) {
      await loadMyBookings(token);
      return null;
    }
    return res.error ?? 'Could not select Cash on Delivery.';
  }

  Future<String?> confirmPartialPayment(
    String token,
    String bookingId,
    double amount,
  ) async {
    final client = ApiClient(token: token);
    final res = await client.post(
      '/api/customer/bookings/$bookingId/confirm-partial',
      {'amount': amount},
    );
    if (res.success) {
      await loadMyBookings(token);
      return null;
    }
    return res.error ?? 'Failed to submit partial payment.';
  }

  Future<Map<String, dynamic>?> createSafepaySession(
    String token,
    String bookingId,
  ) async {
    final client = ApiClient(token: token);
    final res = await client.post(
      '/api/customer/bookings/$bookingId/safepay-session',
      {},
    );
    if (res.success && res.data is Map) {
      return res.data as Map<String, dynamic>;
    }
    return null;
  }

  Future<Map<String, dynamic>?> createStripePaymentSession(
    String token,
    String bookingId,
  ) async {
    final client = ApiClient(token: token);
    final res = await client.post(
      '/api/customer/bookings/$bookingId/payment-session',
      {},
    );
    if (res.success && res.data is Map) {
      return res.data as Map<String, dynamic>;
    }
    return null;
  }
}
