import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../config/app_constants.dart';
import 'auth_service.dart';
import 'preferences_service.dart';
import 'network_service.dart';
import 'offline_service.dart';
import '../../features/customers/data/customer_service.dart';
import '../../features/products_services/data/product_service.dart';
import '../../features/products_services/data/service_service.dart';

// Simple wrappers for Hive boxes to allow multiple registrations of Box type
class PreferencesBoxWrapper {
  final Box box;
  PreferencesBoxWrapper(this.box);
}

class OfflineQueueBoxWrapper {
  final Box box;
  OfflineQueueBoxWrapper(this.box);
}

final GetIt locator = GetIt.instance;

class ServiceLocator {
  static Future<void> setup() async {
    // Core services
    try {
      await Supabase.initialize(
        url: AppConstants.supabaseUrl,
        publishableKey: AppConstants.supabaseAnonKey,
      );
    } catch (e) {
      // If Supabase initialization fails (e.g., during testing), we'll still register a mock
      // The individual services will need to handle the case where Supabase is not properly initialized
    }

    // Boxes wrapped in wrapper classes to allow multiple registrations
    locator.registerLazySingleton<PreferencesBoxWrapper>(
      () => PreferencesBoxWrapper(Hive.box(AppConstants.preferencesBox)),
    );

    locator.registerLazySingleton<OfflineQueueBoxWrapper>(
      () => OfflineQueueBoxWrapper(Hive.box(AppConstants.offlineQueueBox)),
    );

    // Application services
    locator.registerLazySingleton<AuthService>(
      () => AuthServiceImpl(),
    );

    locator.registerLazySingleton<PreferencesService>(
      () => PreferencesServiceImpl(),
    );

    locator.registerLazySingleton<NetworkService>(
      () => NetworkServiceImpl(),
    );

    locator.registerLazySingleton<OfflineService>(
      () => OfflineServiceImpl(),
    );

    // Feature services
    locator.registerLazySingleton<CustomerService>(
      () => CustomerServiceImpl(),
    );

    locator.registerLazySingleton<ProductService>(
      () => ProductServiceImpl(),
    );

    locator.registerLazySingleton<ServiceService>(
      () => ServiceServiceImpl(),
    );

    // Feature services will be added as we implement them
  }
}