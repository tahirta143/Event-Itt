import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';
import '../../core/storage/secure_storage.dart';

class ContactInquiryModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String subject;
  final String message;
  final bool isRead;
  final String? createdAt;

  ContactInquiryModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.subject,
    required this.message,
    required this.isRead,
    this.createdAt,
  });

  factory ContactInquiryModel.fromJson(Map<String, dynamic> json) {
    return ContactInquiryModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'User',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString(),
      subject: json['subject']?.toString() ?? 'Inquiry',
      message: json['message']?.toString() ?? '',
      isRead: json['is_read'] == 1 || json['is_read'] == true,
      createdAt: json['created_at']?.toString(),
    );
  }
}

class AdminContactInboxProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  List<ContactInquiryModel> _inquiries = [];
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalCount = 0;
  int _unreadTotal = 0;
  String _searchQuery = '';
  String _statusFilter = ''; // '', 'unread', 'read'

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<ContactInquiryModel> get inquiries => _inquiries;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalCount => _totalCount;
  int get unreadTotal => _unreadTotal;
  String get searchQuery => _searchQuery;
  String get statusFilter => _statusFilter;

  Future<void> loadInbox(String token, {int page = 1, String? search, String? status}) async {
    if (SecureStorage.isMockOrInvalidToken(token)) return;

    _isLoading = true;
    _error = null;
    _currentPage = page;
    if (search != null) _searchQuery = search;
    if (status != null) _statusFilter = status;
    notifyListeners();

    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': '10',
    };
    if (_searchQuery.isNotEmpty) queryParams['search'] = _searchQuery;
    if (_statusFilter.isNotEmpty) queryParams['status'] = _statusFilter;

    final queryString = Uri(queryParameters: queryParams).query;
    final url = '/api/admin/contact-inquiries?$queryString';

    final client = ApiClient(token: token);
    final res = await client.get(url);

    if (res.success && res.data != null) {
      final data = res.data;
      if (data is Map<String, dynamic>) {
        final rows = (data['rows'] as List<dynamic>?) ?? [];
        _inquiries = rows
            .map((e) => ContactInquiryModel.fromJson(e as Map<String, dynamic>))
            .toList();
        _totalPages = int.tryParse(data['totalPages']?.toString() ?? '1') ?? 1;
        _totalCount = int.tryParse(data['total']?.toString() ?? '0') ?? 0;
        _unreadTotal = int.tryParse(data['unreadTotal']?.toString() ?? '0') ?? 0;
      }
    } else {
      _error = res.error ?? 'Failed to load inbox.';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> nextPage(String token) async {
    if (_currentPage < _totalPages) {
      await loadInbox(token, page: _currentPage + 1);
    }
  }

  Future<void> prevPage(String token) async {
    if (_currentPage > 1) {
      await loadInbox(token, page: _currentPage - 1);
    }
  }

  Future<String?> markRead(String token, String id, bool isRead) async {
    final client = ApiClient(token: token);
    final res = await client.patch('/api/admin/contact-inquiries/$id/read', {
      'is_read': isRead ? 1 : 0,
    });
    if (res.success) {
      await loadInbox(token, page: _currentPage);
      return null;
    }
    return res.error ?? 'Failed to update read status.';
  }

  Future<String?> deleteInquiry(String token, String id) async {
    final client = ApiClient(token: token);
    final res = await client.delete('/api/admin/contact-inquiries/$id');
    if (res.success) {
      await loadInbox(token, page: _currentPage);
      return null;
    }
    return res.error ?? 'Failed to delete inquiry.';
  }
}
