import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';
import '../../models/vendor/vendor_models.dart';
import '../../models/booking/booking_model.dart';

class VendorAvailabilityProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;
  String? _message;

  DateTime _currentMonth = DateTime.now();
  Map<String, Map<String, dynamic>> _calendarBookings = {};
  Map<String, List<BookingModel>> _dayBookings = {};
  Map<String, VendorBlackoutDateModel> _blackoutDates = {};

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get error => _error;
  String? get message => _message;
  DateTime get currentMonth => _currentMonth;
  Map<String, Map<String, dynamic>> get calendarBookings => _calendarBookings;
  Map<String, List<BookingModel>> get dayBookings => _dayBookings;
  Map<String, VendorBlackoutDateModel> get blackoutDates => _blackoutDates;

  void changeMonth(int deltaMonths, String token) {
    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + deltaMonths, 1);
    fetchAvailability(token);
  }

  void goToToday(String token) {
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month, 1);
    fetchAvailability(token);
  }

  String get monthKey =>
      '${_currentMonth.year}-${_currentMonth.month.toString().padLeft(2, '0')}';

  Future<void> fetchAvailability(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final client = ApiClient(token: token);
    final results = await Future.wait([
      client.get('/api/vendor/calendar?month=$monthKey'),
      client.get('/api/vendor/blackout-dates'),
      client.get('/api/vendor/bookings'),
    ]);

    final calRes = results[0];
    final blkRes = results[1];
    final bkRes = results[2];

    if (calRes.success && calRes.data != null) {
      final days = (calRes.data is Map ? calRes.data['days'] : null) as List<dynamic>? ?? [];
      final Map<String, Map<String, dynamic>> map = {};
      for (var d in days) {
        if (d is Map && d['event_date'] != null) {
          final dtStr = d['event_date'].toString();
          map[dtStr.substring(0, dtStr.length >= 10 ? 10 : dtStr.length)] = Map<String, dynamic>.from(d);
        }
      }
      _calendarBookings = map;
    }

    if (blkRes.success && blkRes.data != null) {
      final days = (blkRes.data is Map ? blkRes.data['days'] : (blkRes.data is List ? blkRes.data : null)) as List<dynamic>? ?? [];
      final Map<String, VendorBlackoutDateModel> blkMap = {};
      for (var d in days) {
        if (d is Map && d['date'] != null) {
          final item = VendorBlackoutDateModel.fromJson(Map<String, dynamic>.from(d));
          blkMap[item.date.substring(0, item.date.length >= 10 ? 10 : item.date.length)] = item;
        }
      }
      _blackoutDates = blkMap;
    }

    if (bkRes.success && bkRes.data != null) {
      final data = bkRes.data;
      final rawList = (data is List ? data : (data is Map ? (data['bookings'] ?? data['data'] ?? []) : [])) as List<dynamic>;
      final Map<String, List<BookingModel>> dayMap = {};
      for (var bJson in rawList) {
        final b = BookingModel.fromJson(bJson as Map<String, dynamic>);
        if (b.eventDate != null && b.eventDate!.isNotEmpty) {
          final key = b.eventDate!.substring(0, b.eventDate!.length >= 10 ? 10 : b.eventDate!.length);
          dayMap.putIfAbsent(key, () => []).add(b);
        }
      }
      _dayBookings = dayMap;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createBlackout(String token, String dateStr, {String? reason}) async {
    _isSaving = true;
    _error = null;
    notifyListeners();

    final client = ApiClient(token: token);
    final res = await client.post('/api/vendor/blackout-dates', {
      'date': dateStr,
      if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
    });

    _isSaving = false;
    if (res.success && res.data != null) {
      final item = VendorBlackoutDateModel.fromJson(Map<String, dynamic>.from(res.data));
      _blackoutDates[item.date.substring(0, item.date.length >= 10 ? 10 : item.date.length)] = item;
      _message = 'Date marked unavailable';
      notifyListeners();
      return true;
    } else {
      _error = res.error ?? 'Could not mark date unavailable';
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeBlackout(String token, String dateStr) async {
    final item = _blackoutDates[dateStr];
    if (item == null) return false;

    _isSaving = true;
    _error = null;
    notifyListeners();

    final client = ApiClient(token: token);
    final res = await client.delete('/api/vendor/blackout-dates/${item.id}');

    _isSaving = false;
    if (res.success) {
      _blackoutDates.remove(dateStr);
      _message = 'Date restored to available';
      notifyListeners();
      return true;
    } else {
      _error = res.error ?? 'Could not restore date';
      notifyListeners();
      return false;
    }
  }
}
