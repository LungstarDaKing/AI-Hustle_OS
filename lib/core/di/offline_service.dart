import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'service_locator.dart';
import '../config/app_constants.dart';

// Abstract offline service
abstract class OfflineService {
  Future<void> queueOperation(String operationType, Map<String, dynamic> data);
  Future<List<Map<String, dynamic>>> getQueuedOperations();
  Future<void> clearQueuedOperations();
  Future<bool> processQueue();
  Future<bool> isQueueEmpty();
}

// Offline service implementation
class OfflineServiceImpl implements OfflineService {
  final Box _box = GetIt.instance<OfflineQueueBoxWrapper>().box;

  @override
  Future<void> queueOperation(String operationType, Map<String, dynamic> data) async {
    final operations = _box.get(AppConstants.offlineQueueBox) ?? [];
    operations.add({
      'type': operationType,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
    });
    await _box.put(AppConstants.offlineQueueBox, operations);
  }

  @override
  Future<List<Map<String, dynamic>>> getQueuedOperations() async {
    final operations = _box.get(AppConstants.offlineQueueBox);
    if (operations is List<dynamic>) {
      return operations.cast<Map<String, dynamic>>();
    }
    return [];
  }

  @override
  Future<void> clearQueuedOperations() async {
    await _box.delete(AppConstants.offlineQueueBox);
  }

  @override
  Future<bool> processQueue() async {
    // In a real implementation, this would:
    // 1. Check if we're online
    // 2. Process each queued operation by sending to the backend
    // 3. Remove successful operations from the queue
    // 4. Keep failed operations for retry

    // For now, we'll just simulate processing
    final operations = await getQueuedOperations();
    if (operations.isEmpty) return true;

    // Simulate processing delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Clear the queue (in reality, we'd only remove processed items)
    await clearQueuedOperations();
    return true;
  }

  @override
  Future<bool> isQueueEmpty() async {
    final operations = await getQueuedOperations();
    return operations.isEmpty;
  }
}