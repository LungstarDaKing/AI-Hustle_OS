import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'service_locator.dart';

// Abstract preferences service
abstract class PreferencesService {
  Future<T?> get<T>(String key);
  Future<void> set<T>(String key, T value);
  Future<void> remove(String key);
  Future<void> clear();
}

// Preferences service implementation
class PreferencesServiceImpl implements PreferencesService {
  final Box _box = GetIt.instance<PreferencesBoxWrapper>().box;

  @override
  Future<T?> get<T>(String key) async {
    return _box.get(key) as T?;
  }

  @override
  Future<void> set<T>(String key, T value) async {
    await _box.put(key, value);
  }

  @override
  Future<void> remove(String key) async {
    await _box.delete(key);
  }

  @override
  Future<void> clear() async {
    await _box.clear();
  }
}