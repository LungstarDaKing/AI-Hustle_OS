import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:get_it/get_it.dart';

import 'core/config/app_constants.dart';
import 'core/config/theme.dart';
import 'core/di/service_locator.dart';
import 'core/di/auth_service.dart';
import 'core/di/preferences_service.dart';
import 'features/auth/presentation/pages/splash_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/onboarding/presentation/pages/onboarding_page.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/customers/presentation/pages/customers_list_page.dart';
import 'features/customers/presentation/pages/customer_form_page.dart';
import 'features/customers/presentation/pages/customer_detail_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    publishableKey: AppConstants.supabaseAnonKey,
  );

  // Initialize Hive for local storage
  await Hive.initFlutter();

  // Set up service locator (dependency injection)
  await ServiceLocator.setup();

  runApp(const AIHustleOSApp());
}

class AIHustleOSApp extends StatelessWidget {
  const AIHustleOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Temporary empty providers list - will be populated as features are implemented
    final List<Provider<dynamic>> providers = [];

    // If we have providers, use MultiProvider; otherwise, just provide the child
    if (providers.isNotEmpty) {
      return MultiProvider(
        providers: providers,
        child: MaterialApp.router(
          title: 'AI HustleOS',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.light,
          routerConfig: _goRouter,
        ),
      );
    } else {
      return MaterialApp.router(
        title: 'AI HustleOS',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        routerConfig: _goRouter,
      );
    }
  }
}

// GoRouter configuration
final GoRouter _goRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/customers',
      builder: (context, state) => const CustomersListPage(),
    ),
    GoRoute(
      path: '/customers/new',
      builder: (context, state) => const CustomerFormPage(),
    ),
    GoRoute(
      path: '/customers/:id',
      builder: (context, state) => CustomerDetailPage(
        customerId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: '/customers/:id/edit',
      builder: (context, state) => CustomerFormPage(
        customerId: state.pathParameters['id'],
      ),
    ),
  ],
  // Redirect based on authentication state
  redirect: (context, state) async {
    // Don't redirect if we're already on the splash page - let it handle its own logic
    if (state.uri.path == '/splash') {
      return null;
    }

    final loggedIn = await locator<AuthService>().isLoggedIn;
    final loggingIn = state.uri.path == '/login';
    final registering = state.uri.path == '/register';
    final onboarding = state.uri.path == '/onboarding';

    if (!loggedIn && !loggingIn && !registering && !onboarding) {
      return '/login';
    }

    if (loggedIn && (loggingIn || registering)) {
      // Check if user has completed onboarding
      final hasCompletedOnboarding = await locator<PreferencesService>().get<bool>(
        AppConstants.hasCompletedOnboardingKey,
      ) ?? false;

      if (!hasCompletedOnboarding) {
        return '/onboarding';
      }

      return '/home';
    }

    return null; // No redirect needed
  },
);

// Helper extension to get services from locator
extension ServiceLocatorExtension on ServiceLocator {
  T locator<T extends Object>() {
    return GetIt.instance.get<T>();
  }
}