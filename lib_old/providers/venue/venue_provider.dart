import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';
import '../../models/venue/venue_model.dart';
import '../../models/category/category_model.dart';
import '../../models/subcategory/subcategory_model.dart';
import '../../utils/mock_data/mock_data.dart';

class VenueProvider extends ChangeNotifier {
  List<VenueModel> _venues = List.from(MockData.venues);
  List<CategoryModel> _categories = List.from(MockData.categories);
  List<SubCategoryModel> _subCategories = List.from(MockData.subCategories);

  bool _isLoading = false;
  String? _error;

  String _searchQuery = '';
  String _selectedCategoryTitle = 'All';
  String _selectedSubCategoryTitle = 'All';

  bool get isLoading => _isLoading;
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

  /// Fetches real categories, subcategories, and vendors/venues from the live API.
  Future<void> fetchPublicData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final client = ApiClient();

    try {
      // 1. Fetch real categories & subcategories from /api/public/categories
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

        if (parsedCategories.length > 1) {
          _categories = parsedCategories;
        }
        if (parsedSubCategories.isNotEmpty) {
          _subCategories = parsedSubCategories;
        }
      }

      // 2. Fetch real vendors/venues from /api/public/vendors
      final vendorRes = await client.get('/api/public/vendors');
      if (vendorRes.success && vendorRes.data != null) {
        final List<dynamic> vendorList = vendorRes.data is List ? vendorRes.data : [];
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

        if (parsedVenues.isNotEmpty) {
          _venues = parsedVenues;
        }
      }
    } catch (e) {
      _error = 'Failed to load public data: $e';
    } finally {
      _isLoading = false;
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
