import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';

/// Full Admin dashboard summary provider integrated with /api/dashboard/summary and /api/dashboard/calendar.
class AdminDashboardProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  String _range = '30days';
  Map<String, dynamic>? _summaryData;

  // Calendar State
  Map<String, List<dynamic>> _eventsByDate = {};
  List<dynamic> _upcomingEvents = [];
  bool _isLoadingCalendar = false;

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get range => _range;
  Map<String, dynamic>? get summaryData => _summaryData;

  Map<String, List<dynamic>> get eventsByDate => _eventsByDate;
  List<dynamic> get upcomingEvents => _upcomingEvents;
  bool get isLoadingCalendar => _isLoadingCalendar;

  // Convenient getters
  Map<String, dynamic> get todayBookings =>
      (_summaryData?['todayBookings'] as Map<String, dynamic>?) ??
      {'total': 0, 'value': 0};

  int get upcomingCount =>
      _parseInt(_summaryData?['upcomingCount'] ?? _summaryData?['upcoming_count']);

  int get overdueCount =>
      _parseInt(_summaryData?['overdueCount'] ?? _summaryData?['overdue_count']);

  Map<String, dynamic> get bookings =>
      (_summaryData?['bookings'] as Map<String, dynamic>?) ??
      {'total': 0, 'pending': 0, 'confirmed': 0, 'cancelled': 0};

  double get pipelineValue =>
      _parseDouble(_summaryData?['pipelineValue'] ?? _summaryData?['pipeline_value']);

  int get customersWithBookings =>
      _parseInt(_summaryData?['customersWithBookings'] ?? _summaryData?['active_clients']);

  Map<String, dynamic> get categories =>
      (_summaryData?['categories'] as Map<String, dynamic>?) ??
      {'total': 0, 'active': 0, 'inactive': 0};

  Map<String, dynamic> get subcategories =>
      (_summaryData?['subcategories'] as Map<String, dynamic>?) ??
      {'total': 0, 'active': 0, 'inactive': 0};

  List<dynamic> get needsAttention =>
      (_summaryData?['needsAttention'] as List<dynamic>?) ?? [];

  List<dynamic> get topServices =>
      (_summaryData?['topServices'] as List<dynamic>?) ?? [];

  List<dynamic> get bookingChartData =>
      (_summaryData?['bookingChartData'] as List<dynamic>?) ?? [];

  List<dynamic> get recentBookings =>
      (_summaryData?['recentBookings'] as List<dynamic>?) ?? [];

  // Convenience summary stats for backward compatibility
  int get totalBookings => _parseInt(bookings['total']);
  int get pendingBookings => _parseInt(bookings['pending']);
  int get confirmedBookings => _parseInt(bookings['confirmed']);
  int get totalVendors =>
      _parseInt(_summaryData?['vendors']?['total'] ?? _summaryData?['totalVendors'] ?? 0);
  int get totalCustomers =>
      _parseInt(_summaryData?['customers']?['total'] ?? _summaryData?['totalCustomers'] ?? 0);
  double get totalRevenue => pipelineValue;

  Future<void> setRange(String token, String newRange) async {
    _range = newRange;
    await loadSummary(token);
  }

  Future<void> loadSummary(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final client = ApiClient(token: token);
    final res = await client.get('/api/dashboard/summary?range=$_range');

    if (res.success && res.data != null && res.data is Map<String, dynamic>) {
      _summaryData = res.data as Map<String, dynamic>;
    } else {
      _error = res.error ?? 'Failed to load dashboard summary.';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadRecentBookings(String token) async {
    final client = ApiClient(token: token);
    final res = await client.get('/api/dashboard/recent-bookings');
    if (res.success && res.data != null) {
      if (res.data is List) {
        if (_summaryData == null) _summaryData = {};
        _summaryData!['recentBookings'] = res.data;
      } else if (res.data is Map && res.data['bookings'] is List) {
        if (_summaryData == null) _summaryData = {};
        _summaryData!['recentBookings'] = res.data['bookings'];
      }
      notifyListeners();
    }
  }

  Future<void> loadCalendar(String token, String start, String end) async {
    _isLoadingCalendar = true;
    notifyListeners();

    final client = ApiClient(token: token);
    final res = await client.get('/api/dashboard/calendar?start=$start&end=$end');

    if (res.success && res.data != null && res.data is Map<String, dynamic>) {
      final data = res.data as Map<String, dynamic>;
      final eventsList = (data['events'] as List<dynamic>?) ?? [];
      _upcomingEvents = (data['upcoming'] as List<dynamic>?) ?? [];

      final Map<String, List<dynamic>> grouped = {};
      for (final e in eventsList) {
        if (e is Map<String, dynamic>) {
          final dateStr = e['event_date']?.toString().split('T')[0] ?? '';
          if (dateStr.isNotEmpty) {
            grouped.putIfAbsent(dateStr, () => []).add(e);
          }
        }
      }
      _eventsByDate = grouped;
    }

    _isLoadingCalendar = false;
    notifyListeners();
  }

  Future<String?> updateBookingStatus(
      String token, String bookingId, String status) async {
    final client = ApiClient(token: token);
    final res = await client.patch('/api/admin/bookings/$bookingId/status', {
      'status': status,
    });
    if (res.success) {
      await loadSummary(token);
      return null;
    }
    return res.error ?? 'Failed to update booking status.';
  }

  int _parseInt(dynamic v) => int.tryParse(v?.toString() ?? '0') ?? 0;
  double _parseDouble(dynamic v) => double.tryParse(v?.toString() ?? '0') ?? 0.0;
}
