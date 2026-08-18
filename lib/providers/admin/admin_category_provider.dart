import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';
import '../../core/storage/secure_storage.dart';
import '../../models/category/admin_category_model.dart';

/// Admin "Setup Catalog → Categories" provider.
/// Mirrors client/src/pages/Category.jsx exactly against the real backend:
///   GET    /api/categories
///   GET    /api/sub-services         (parent dropdown)
///   POST   /api/categories           (multipart: sub_service_id, category_name, description, is_active, image)
///   PUT    /api/categories/:id       (multipart, same fields)
///   PUT    /api/categories/:id/events   { event_types: [...] }   (called right after create/update)
///   PATCH  /api/categories/:id/status   { is_active }
///   PATCH  /api/categories/:id/featured { is_featured }
///   DELETE /api/categories/:id
/// There is no bulk endpoint on the backend — bulk actions loop per id,
/// same as the React admin panel.
class AdminCategoryProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;
  List<AdminCategoryModel> _categories = [];
  List<SubServiceOption> _subServices = [];
  String _searchQuery = '';

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get error => _error;
  List<SubServiceOption> get subServices => _subServices;
  String get searchQuery => _searchQuery;
  int get totalCount => _categories.length;

  List<AdminCategoryModel> get categories {
    if (_searchQuery.isEmpty) return _categories;
    final q = _searchQuery.toLowerCase();
    return _categories
        .where((c) =>
            c.categoryName.toLowerCase().contains(q) ||
            (c.description ?? '').toLowerCase().contains(q))
        .toList();
  }

  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> loadCategories(String token) async {
    if (SecureStorage.isMockOrInvalidToken(token)) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    final client = ApiClient(token: token);

    final results = await Future.wait([
      client.get('/api/categories'),
      client.get('/api/sub-services'),
    ]);

    final categoriesRes = results[0];
    final subServicesRes = results[1];

    if (categoriesRes.success && categoriesRes.data != null) {
      _categories = _extractList(categoriesRes.data)
          .map((e) => AdminCategoryModel.fromJson(e))
          .toList();
    } else {
      _error = categoriesRes.error ?? 'Failed to load categories.';
    }

    if (subServicesRes.success && subServicesRes.data != null) {
      _subServices = _extractList(subServicesRes.data)
          .map((e) => SubServiceOption.fromJson(e))
          .toList();
    }

    _isLoading = false;
    notifyListeners();
  }

  List<Map<String, dynamic>> _extractList(dynamic data) {
    if (data is List) return data.whereType<Map<String, dynamic>>().toList();
    if (data is Map<String, dynamic>) {
      final rows = data['rows'] ?? data['data'];
      if (rows is List) return rows.whereType<Map<String, dynamic>>().toList();
    }
    return [];
  }

  /// Client-side duplicate-name guard, mirroring the React admin's findDuplicate().
  bool isDuplicateName(String name, {String? excludeId}) {
    final n = name.trim().toLowerCase();
    return _categories.any((c) => c.categoryName.toLowerCase() == n && c.id != excludeId);
  }

  /// Creates a category. `imagePath` is a local file path from image_picker (optional).
  /// Returns null on success, error message on failure.
  Future<String?> createCategory(
    String token, {
    required String subServiceId,
    required String categoryName,
    required String description,
    required bool isActive,
    required List<String> eventTypes,
    String? imagePath,
  }) async {
    _isSaving = true;
    notifyListeners();

    final client = ApiClient(token: token);
    final res = await client.multipartPost(
      '/api/categories',
      fields: {
        'sub_service_id': subServiceId,
        'category_name': categoryName,
        'description': description,
        'is_active': isActive.toString(),
      },
      filePath: imagePath,
      fileField: 'image',
    );

    String? errorMsg;
    if (res.success && res.data != null) {
      final created = res.data;
      final newId = created is Map<String, dynamic> ? (created['id'] ?? '').toString() : '';
      if (newId.isNotEmpty) {
        await client.put('/api/categories/$newId/events', {'event_types': eventTypes});
      }
      await loadCategories(token);
    } else {
      errorMsg = res.error ?? 'Failed to create category.';
    }

    _isSaving = false;
    notifyListeners();
    return errorMsg;
  }

  Future<String?> updateCategory(
    String token, {
    required String id,
    required String subServiceId,
    required String categoryName,
    required String description,
    required bool isActive,
    required List<String> eventTypes,
    String? imagePath,
  }) async {
    _isSaving = true;
    notifyListeners();

    final client = ApiClient(token: token);
    final res = await client.multipartPut(
      '/api/categories/$id',
      fields: {
        'sub_service_id': subServiceId,
        'category_name': categoryName,
        'description': description,
        'is_active': isActive.toString(),
      },
      filePath: imagePath,
      fileField: 'image',
    );

    String? errorMsg;
    if (res.success) {
      await client.put('/api/categories/$id/events', {'event_types': eventTypes});
      await loadCategories(token);
    } else {
      errorMsg = res.error ?? 'Failed to update category.';
    }

    _isSaving = false;
    notifyListeners();
    return errorMsg;
  }

  Future<String?> deleteCategory(String token, String id) async {
    final client = ApiClient(token: token);
    final res = await client.delete('/api/categories/$id');
    if (res.success) {
      _categories.removeWhere((c) => c.id == id);
      notifyListeners();
      return null;
    }
    return res.error ?? 'Failed to delete category.';
  }

  Future<String?> toggleActive(String token, AdminCategoryModel category) async {
    final client = ApiClient(token: token);
    final newValue = !category.isActive;
    final res = await client.patch('/api/categories/${category.id}/status', {'is_active': newValue});
    if (res.success) {
      final idx = _categories.indexWhere((c) => c.id == category.id);
      if (idx != -1) {
        _categories[idx] = _categories[idx].copyWith(isActive: newValue);
        notifyListeners();
      }
      return null;
    }
    return res.error ?? 'Failed to update status.';
  }

  Future<String?> toggleFeatured(String token, AdminCategoryModel category) async {
    final client = ApiClient(token: token);
    final newValue = !category.isFeatured;
    final res = await client.patch('/api/categories/${category.id}/featured', {'is_featured': newValue});
    if (res.success) {
      final idx = _categories.indexWhere((c) => c.id == category.id);
      if (idx != -1) {
        _categories[idx] = _categories[idx].copyWith(isFeatured: newValue);
        notifyListeners();
      }
      return null;
    }
    return res.error ?? 'Failed to update featured flag.';
  }

  /// Bulk activate/deactivate — loops per id, same as the React admin (no bulk API exists).
  Future<void> bulkSetActive(String token, Set<String> ids, bool active) async {
    final client = ApiClient(token: token);
    for (final id in ids) {
      await client.patch('/api/categories/$id/status', {'is_active': active});
    }
    await loadCategories(token);
  }

  /// Bulk delete — loops per id, same as the React admin.
  Future<void> bulkDelete(String token, Set<String> ids) async {
    final client = ApiClient(token: token);
    for (final id in ids) {
      await client.delete('/api/categories/$id');
    }
    _categories.removeWhere((c) => ids.contains(c.id));
    notifyListeners();
  }
}
