import 'package:flutter/material.dart';
import '../../models/category/category_model.dart';
import '../../models/subcategory/subcategory_model.dart';
import '../../models/service/service_model.dart';
import '../../models/venue/venue_model.dart';
import '../../models/dashboard/dashboard_stat_model.dart';

class MockData {
  static final List<CategoryModel> categories = [
    CategoryModel(
      id: 'cat_1',
      title: 'Mehndi',
      imageUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&q=80&w=600',
      itemQuantity: 120,
    ),
    CategoryModel(
      id: 'cat_2',
      title: 'Photography',
      imageUrl: 'https://images.unsplash.com/photo-1519741497674-611481863552?auto=format&fit=crop&q=80&w=600',
      itemQuantity: 95,
    ),
    CategoryModel(
      id: 'cat_3',
      title: 'Wedding',
      imageUrl: 'https://images.unsplash.com/photo-1511285560929-80b456fea0bc?auto=format&fit=crop&q=80&w=600',
      itemQuantity: 210,
    ),
    CategoryModel(
      id: 'cat_4',
      title: 'Reception',
      imageUrl: 'https://images.unsplash.com/photo-1519225421980-715cb0215aed?auto=format&fit=crop&q=80&w=600',
      itemQuantity: 80,
    ),
    CategoryModel(
      id: 'cat_5',
      title: 'Haldi',
      imageUrl: 'https://images.unsplash.com/photo-1606800052052-a08af7148866?auto=format&fit=crop&q=80&w=600',
      itemQuantity: 45,
    ),
  ];

  static final List<SubCategoryModel> subCategories = [
    SubCategoryModel(
      id: 'sub_1',
      categoryId: 'cat_3',
      title: 'Heritage Palace',
      imageUrl: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&q=80&w=600',
      count: 42,
    ),
    SubCategoryModel(
      id: 'sub_2',
      categoryId: 'cat_3',
      title: 'Luxury Villa',
      imageUrl: 'https://images.unsplash.com/photo-1582719508461-905c673771fd?auto=format&fit=crop&q=80&w=600',
      count: 28,
    ),
    SubCategoryModel(
      id: 'sub_3',
      categoryId: 'cat_3',
      title: 'Beachside Lawn',
      imageUrl: 'https://images.unsplash.com/photo-1540555700478-4be289fbecef?auto=format&fit=crop&q=80&w=600',
      count: 35,
    ),
    SubCategoryModel(
      id: 'sub_4',
      categoryId: 'cat_3',
      title: 'Royal Indoor Hall',
      imageUrl: 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?auto=format&fit=crop&q=80&w=600',
      count: 60,
    ),
  ];

  static final List<VenueModel> venues = [
    VenueModel(
      id: 'v_1',
      title: 'Luxury Wedding Venue',
      location: 'Udaipur, Rajasthan',
      price: '\$ 2,00,000',
      rating: 5.0,
      reviewsCount: 148,
      images: [
        'https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&q=80&w=1000',
        'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?auto=format&fit=crop&q=80&w=1000',
        'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?auto=format&fit=crop&q=80&w=1000',
      ],
      category: 'Wedding',
      subCategory: 'Heritage Palace',
      isFavorite: true,
      description:
          'Experience timeless elegance and royal grandeur at our lakefront palace in Udaipur. Offering majestic architecture, crystal chandeliers, floral arches, and world-class hospitality for your big day.',
      capacity: '800 - 1500 Guests',
    ),
    VenueModel(
      id: 'v_2',
      title: 'The Grand Emerald Resort',
      location: 'Jaipur, Rajasthan',
      price: '\$ 1,75,000',
      rating: 4.9,
      reviewsCount: 96,
      images: [
        'https://images.unsplash.com/photo-1582719508461-905c673771fd?auto=format&fit=crop&q=80&w=1000',
        'https://images.unsplash.com/photo-1571896349842-33c89424de2d?auto=format&fit=crop&q=80&w=1000',
      ],
      category: 'Wedding',
      subCategory: 'Luxury Villa',
      isFavorite: false,
      description:
          'Spread across 15 acres of lush green lawns with bespoke royal arches, ideal for night receptions and Mehndi ceremonies.',
      capacity: '500 - 1000 Guests',
    ),
    VenueModel(
      id: 'v_3',
      title: 'Sunset Beach Estate',
      location: 'Goa, India',
      price: '\$ 1,50,000',
      rating: 4.8,
      reviewsCount: 112,
      images: [
        'https://images.unsplash.com/photo-1540555700478-4be289fbecef?auto=format&fit=crop&q=80&w=1000',
        'https://images.unsplash.com/photo-1510414842594-a61c69b5ae57?auto=format&fit=crop&q=80&w=1000',
      ],
      category: 'Wedding',
      subCategory: 'Beachside Lawn',
      isFavorite: true,
      description:
          'Say "I do" with ocean waves in the background. Pristine white sand decor, ambient lantern lighting, and luxury beachside dining.',
      capacity: '300 - 700 Guests',
    ),
  ];

  static final List<ServiceModel> services = [
    ServiceModel(
      id: 's_1',
      title: 'Royal Catering',
      description: 'Multi-cuisine gourmet dining, live live stations, and luxury dessert bars.',
      icon: Icons.restaurant_rounded,
      startingPrice: '\$ 5,000 / event',
      imageUrl: 'https://images.unsplash.com/photo-1555244162-803834f70033?auto=format&fit=crop&q=80&w=600',
    ),
    ServiceModel(
      id: 's_2',
      title: 'Floral & Stage Decor',
      description: 'Customized luxury flower arches, mandap styling, and ambient lighting.',
      icon: Icons.local_florist_rounded,
      startingPrice: '\$ 8,000 / event',
      imageUrl: 'https://images.unsplash.com/photo-1519225421980-715cb0215aed?auto=format&fit=crop&q=80&w=600',
    ),
    ServiceModel(
      id: 's_3',
      title: 'Cinematic Photography',
      description: 'Pre-wedding shoots, drone coverage, 4K wedding films, and photo albums.',
      icon: Icons.camera_alt_rounded,
      startingPrice: '\$ 3,500 / event',
      imageUrl: 'https://images.unsplash.com/photo-1519741497674-611481863552?auto=format&fit=crop&q=80&w=600',
    ),
    ServiceModel(
      id: 's_4',
      title: 'Sound, DJ & Live Music',
      description: 'Premium acoustic setups, celebrity DJs, and traditional Shehnai live music.',
      icon: Icons.music_note_rounded,
      startingPrice: '\$ 2,500 / event',
      imageUrl: 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?auto=format&fit=crop&q=80&w=600',
    ),
    ServiceModel(
      id: 's_5',
      title: 'Bridal Makeup & Styling',
      description: 'Celebrity makeup artists, hair styling, and saree draping assistance.',
      icon: Icons.face_retouching_natural_rounded,
      startingPrice: '\$ 1,200 / event',
      imageUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&q=80&w=600',
    ),
  ];

  static final List<DashboardStatModel> stats = [
    DashboardStatModel(
      title: 'Total Venues Booked',
      value: '28',
      changePercentage: '+14%',
      isPositive: true,
      icon: Icons.bookmark_added_rounded,
    ),
    DashboardStatModel(
      title: 'Total Revenue / Budget',
      value: '\$ 4.8M',
      changePercentage: '+22%',
      isPositive: true,
      icon: Icons.monetization_on_rounded,
    ),
    DashboardStatModel(
      title: 'Saved Favorites',
      value: '64',
      changePercentage: '+8%',
      isPositive: true,
      icon: Icons.favorite_rounded,
    ),
    DashboardStatModel(
      title: 'Active Inquiries',
      value: '12',
      changePercentage: '-3%',
      isPositive: false,
      icon: Icons.chat_rounded,
    ),
  ];
}
