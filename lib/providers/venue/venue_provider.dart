import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';
import '../../models/venue/venue_model.dart';
import '../../models/category/category_model.dart';
import '../../models/subcategory/subcategory_model.dart';
import '../../utils/mock_data/mock_data.dart';

class VenueProvider extends ChangeNotifier {
  List<VenueModel> _venues = [];
  List<CategoryModel> _categories = [];
  List<SubCategoryModel> _subCategories = [];

  bool _isLoading = false;
  bool _isLoadingMoreVenues = false;
  String? _error;

  int _currentVenuePage = 1;
  int _totalVenuePages = 1;

  String _searchQuery = '';
  String _selectedCategoryTitle = 'All';
  String _selectedSubCategoryTitle = 'All';

  bool get isLoading => _isLoading;
  bool get isLoadingMoreVenues => _isLoadingMoreVenues;
  String? get error => _error;

  List<VenueModel> get venues {
    return _venues.where((venue) {
      final matchesSearch = venue.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          venue.location.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          venue.category.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          venue.subCategory.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory =
          _selectedCategoryTitle == 'All' || venue.category.toLowerCase() == _selectedCategoryTitle.toLowerCase();
      final matchesSubCategory = _selectedSubCategoryTitle == 'All' ||
          venue.subCategory.toLowerCase() == _selectedSubCategoryTitle.toLowerCase();
      return matchesSearch && matchesCategory && matchesSubCategory;
    }).toList();
  }

  List<CategoryModel> get categories => _categories;
  List<SubCategoryModel> get subCategories => _subCategories;
  String get searchQuery => _searchQuery;
  String get selectedCategoryTitle => _selectedCategoryTitle;
  String get selectedSubCategoryTitle => _selectedSubCategoryTitle;
  int get currentVenuePage => _currentVenuePage;
  int get totalVenuePages => _totalVenuePages;

  /// Main entry point to fetch initial public data
  Future<void> fetchPublicData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    // Start both concurrently
    final catTask = fetchCategories();
    final venTask = fetchVenues(page: 1);

    // We don't use Future.wait here because we want 
    // fetchCategories and fetchVenues to notify listeners 
    // independently as they finish.
    await catTask;
    await venTask;

    _isLoading = false;
    notifyListeners();
  }

  /// Fetches real categories & subcategories from the live API.
  Future<void> fetchCategories() async {
    final client = ApiClient();
    try {
      final catRes = await client.get('/api/public/categories');
      if (catRes.success && catRes.data != null) {
        final List<dynamic> catList = catRes.data is List ? catRes.data : [];
        final List<CategoryModel> parsedCategories = [
          CategoryModel(id: 'all', title: 'All', imageUrl: 'https://images.unsplash.com/photo-1519741497674-611481863552?w=600&q=80')
        ];
        final List<SubCategoryModel> parsedSubCategories = [];

        for (var c in catList) {
          if (c is Map<String, dynamic>) {
            final catId = c['id']?.toString() ?? '';
            final catName = c['category_name']?.toString() ?? 'Category';
            final catImg = c['image_url']?.toString() ?? '';
            final subs = (c['subcategories'] as List<dynamic>?) ?? [];

            parsedCategories.add(CategoryModel(
              id: catId,
              title: catName,
              imageUrl: catImg.isNotEmpty ? _resolveUrl(catImg) : 'https://images.unsplash.com/photo-1519741497674-611481863552?w=600&q=80',
              itemQuantity: subs.length,
            ));

            for (var s in subs) {
              if (s is Map<String, dynamic>) {
                final subImg = s['image_url']?.toString() ?? '';
                parsedSubCategories.add(SubCategoryModel(
                  id: s['id']?.toString() ?? '',
                  categoryId: catId,
                  title: s['subcategory_name']?.toString() ?? 'Subcategory',
                  imageUrl: subImg.isNotEmpty ? _resolveUrl(subImg) : 'https://images.unsplash.com/photo-1522673607200-164d1b6ce486?w=600&q=80',
                  count: 1,
                ));
              }
            }
          }
        }
        _categories = parsedCategories;
        _subCategories = parsedSubCategories;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ [VenueProvider] Error fetching categories: $e');
    }
  }

  /// Fetches real vendors/venues with pagination support.
  Future<void> fetchVenues({int page = 1, bool loadMore = false}) async {
    if (loadMore) {
      if (_isLoadingMoreVenues || _currentVenuePage >= _totalVenuePages) return;
      _isLoadingMoreVenues = true;
    } else {
      _currentVenuePage = page;
      // Don't clear venues immediately if we are just refreshing, 
      // but let fetchPublicData handle the main loader.
    }
    notifyListeners();

    final client = ApiClient();
    try {
      final vendorRes = await client.get('/api/public/vendors?page=$page&limit=10');
      if (vendorRes.success && vendorRes.data != null) {
        final data = vendorRes.data;
        List<dynamic> vendorList = [];
        
        if (data is Map<String, dynamic>) {
          vendorList = (data['rows'] ?? data['vendors'] ?? data['data'] ?? []) as List;
          _totalVenuePages = int.tryParse((data['totalPages'] ?? data['total_pages'] ?? '1').toString()) ?? 1;
        } else if (data is List) {
          vendorList = data;
          _totalVenuePages = 1;
        }

        final List<VenueModel> parsedVenues = [];
        for (var v in vendorList) {
          if (v is Map<String, dynamic>) {
            final logo = v['logo_url']?.toString() ?? '';
            final imgUrl = logo.isNotEmpty
                ? _resolveUrl(logo)
                : 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=800&q=80';

            final categoryNames = v['category_names']?.toString() ?? 'Venue';
            final subcategoryNames = v['subcategory_names']?.toString() ?? '';
            final count = (v['subcategory_count'] is int) ? (v['subcategory_count'] as int) : 2;

            parsedVenues.add(VenueModel(
              id: v['id']?.toString() ?? '',
              title: v['name']?.toString() ?? 'Vendor',
              location: v['address']?.toString() ?? 'Pakistan',
              price: 'Rs ${count * 75000}+',
              rating: 4.8,
              reviewsCount: count * 12,
              images: [imgUrl],
              category: categoryNames.split(',')[0].trim(),
              subCategory: subcategoryNames.isNotEmpty ? subcategoryNames.split(',')[0].trim() : 'General',
              description: v['description']?.toString() ?? 'Verified EventITT vendor.',
              capacity: '${count * 250} Guests',
            ));
          }
        }

        if (loadMore) {
          _venues.addAll(parsedVenues);
          _currentVenuePage++;
        } else {
          _venues = parsedVenues;
        }
      }
    } catch (e) {
      debugPrint('❌ [VenueProvider] Error fetching venues: $e');
      if (!loadMore) _error = 'Failed to load venues: $e';
    } finally {
      _isLoadingMoreVenues = false;
      notifyListeners();
    }
  }

  String _resolveUrl(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    return 'https://api.eventitt.afaqmis.com$url';
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void selectCategory(String title) {
    if (_selectedCategoryTitle == title) {
      _selectedCategoryTitle = 'All';
    } else {
      _selectedCategoryTitle = title;
    }
    notifyListeners();
  }

  void selectSubCategory(String title) {
    if (_selectedSubCategoryTitle == title) {
      _selectedSubCategoryTitle = 'All';
    } else {
      _selectedSubCategoryTitle = title;
    }
    notifyListeners();
  }

  void toggleFavorite(String venueId) {
    final index = _venues.indexWhere((v) => v.id == venueId);
    if (index != -1) {
      _venues[index] = _venues[index].copyWith(
        isFavorite: !_venues[index].isFavorite,
      );
      notifyListeners();
    }
  }
}
