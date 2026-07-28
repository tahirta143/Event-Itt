import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/auth/auth_provider.dart';
import 'providers/venue/venue_provider.dart';
import 'providers/navigation/navigation_provider.dart';
import 'providers/dashboard/dashboard_provider.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/login/login_screen.dart';
import 'screens/signup/signup_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/dashboard_overview/dashboard_overview_screen.dart';
import 'screens/categories/categories_screen.dart';
import 'screens/services/services_screen.dart';
import 'utils/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );
  runApp(const VenueVibeApp());
}


class VenueVibeApp extends StatelessWidget {
  const VenueVibeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => VenueProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
      ],
      child: MaterialApp(
        title: 'EVENT ITT - Luxury Event Planner',
        debugShowCheckedModeBanner: false,

        theme: AppTheme.luxuryTheme,
        initialRoute: '/splash',
        routes: {
          '/splash': (context) => const SplashScreen(),
          '/onboarding': (context) => const OnboardingScreen(),
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignupScreen(),
          '/home': (context) => const HomeScreen(),
          '/dashboard': (context) => const DashboardOverviewScreen(),
          '/categories': (context) => const CategoriesScreen(),
          '/services': (context) => const ServicesScreen(),
        },
      ),
    );
  }
}
