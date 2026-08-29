import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// Auth providers
import 'providers/auth/auth_provider.dart';
import 'providers/auth/admin_auth_provider.dart';
import 'providers/auth/vendor_auth_provider.dart';
import 'providers/auth/customer_auth_provider.dart';

// Existing providers (unchanged)
import 'providers/venue/venue_provider.dart';
import 'providers/navigation/navigation_provider.dart';
import 'providers/dashboard/dashboard_provider.dart';

// Admin providers
import 'providers/admin/admin_dashboard_provider.dart';
import 'providers/admin/admin_bookings_provider.dart';
import 'providers/admin/admin_vendors_provider.dart';
import 'providers/admin/admin_customers_provider.dart';
import 'providers/admin/admin_vendor_requests_provider.dart';
import 'providers/admin/admin_contact_inbox_provider.dart';
import 'providers/admin/admin_category_provider.dart';
import 'providers/admin/admin_subcategory_provider.dart';

// Vendor providers
import 'providers/vendor/vendor_portal_provider.dart';
import 'providers/vendor/vendor_services_provider.dart';
import 'providers/vendor/vendor_availability_provider.dart';
import 'providers/vendor/vendor_requests_provider.dart';
import 'providers/vendor/vendor_profile_provider.dart';

// Customer providers
import 'providers/customer/customer_bookings_provider.dart';

// Screens
import 'screens/splash/splash_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/login/login_screen.dart';
import 'screens/signup/signup_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/dashboard_overview/dashboard_overview_screen.dart';
import 'screens/categories/categories_screen.dart';
import 'screens/services/services_screen.dart';
import 'screens/admin/admin_home_screen.dart';
import 'screens/admin/admin_bookings_screen.dart';
import 'screens/admin/admin_vendors_screen.dart';
import 'screens/admin/admin_customers_screen.dart';
import 'screens/admin/setup/admin_setup_category_screen.dart';
import 'screens/admin/setup/admin_setup_subcategory_screen.dart';
import 'screens/vendor/vendor_home_screen.dart';
import 'screens/vendor/vendor_bookings_screen.dart';
import 'screens/vendor/vendor_services_screen.dart';
import 'screens/vendor/vendor_availability_screen.dart';
import 'screens/vendor/vendor_analytics_screen.dart';
import 'screens/vendor/vendor_requests_screen.dart';
import 'screens/vendor/vendor_profile_screen.dart';
import 'screens/customer/customer_home_screen.dart';
import 'screens/customer/customer_bookings_screen.dart';

import 'core/api/api_client.dart';
import 'utils/theme/app_theme.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );

  // Hook global 401 callback
  ApiClient.onUnauthorized = (path, error) {
    debugPrint('🚨 [UNAUTHORIZED 401] Protected request to $path failed: $error');
  };

  runApp(const VenueVibeApp());
}

class VenueVibeApp extends StatelessWidget {
  const VenueVibeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ── Auth (role coordinator) ──
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        // ── Role-specific auth providers ──
        ChangeNotifierProvider(create: (_) => AdminAuthProvider()),
        ChangeNotifierProvider(create: (_) => VendorAuthProvider()),
        ChangeNotifierProvider(create: (_) => CustomerAuthProvider()),

        // ── Existing providers (unchanged) ──
        ChangeNotifierProvider(create: (_) => VenueProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),

        // ── Admin API providers ──
        ChangeNotifierProvider(create: (_) => AdminDashboardProvider()),
        ChangeNotifierProvider(create: (_) => AdminBookingsProvider()),
        ChangeNotifierProvider(create: (_) => AdminVendorsProvider()),
        ChangeNotifierProvider(create: (_) => AdminCustomersProvider()),
        ChangeNotifierProvider(create: (_) => AdminVendorRequestsProvider()),
        ChangeNotifierProvider(create: (_) => AdminContactInboxProvider()),
        ChangeNotifierProvider(create: (_) => AdminCategoryProvider()),
        ChangeNotifierProvider(create: (_) => AdminSubcategoryProvider()),

        // ── Vendor API providers ──
        ChangeNotifierProvider(create: (_) => VendorPortalProvider()),
        ChangeNotifierProvider(create: (_) => VendorServicesProvider()),
        ChangeNotifierProvider(create: (_) => VendorAvailabilityProvider()),
        ChangeNotifierProvider(create: (_) => VendorRequestsProvider()),
        ChangeNotifierProvider(create: (_) => VendorProfileProvider()),

        // ── Customer API providers ──
        ChangeNotifierProvider(create: (_) => CustomerBookingsProvider()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'EVENT ITT - Luxury Event Planner',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.luxuryTheme,
        initialRoute: '/splash',
        routes: {
          // ── Core routes ──
          '/splash': (context) => const SplashScreen(),
          '/onboarding': (context) => const OnboardingScreen(),
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignupScreen(),

          // ── Existing routes (unchanged) ──
          '/home': (context) => const HomeScreen(),
          '/dashboard': (context) => const DashboardOverviewScreen(),
          '/categories': (context) => const CategoriesScreen(),
          '/services': (context) => const ServicesScreen(),

          // ── Admin routes ──
          '/admin/home': (context) => const AdminHomeScreen(),
          '/admin/bookings': (context) => const AdminBookingsScreen(),
          '/admin/vendors': (context) => const AdminVendorsScreen(),
          '/admin/customers': (context) => const AdminCustomersScreen(),
          '/admin/setup/category': (context) => const AdminSetupCategoryScreen(),
          '/admin/setup/subcategory': (context) => const AdminSetupSubcategoryScreen(),

          // ── Vendor routes ──
          '/vendor/home': (context) => const VendorHomeScreen(),
          '/vendor/bookings': (context) => const VendorBookingsScreen(),
          '/vendor/services': (context) => const VendorServicesScreen(),
          '/vendor/availability': (context) => const VendorAvailabilityScreen(),
          '/vendor/analytics': (context) => const VendorAnalyticsScreen(),
          '/vendor/requests': (context) => const VendorRequestsScreen(),
          '/vendor/profile': (context) => const VendorProfileScreen(),

          // ── Customer routes ──
          '/customer/home': (context) => const CustomerHomeScreen(),
          '/customer/bookings': (context) => const CustomerBookingsScreen(),
        },
      ),
    );
  }
}
