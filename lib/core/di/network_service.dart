import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Abstract network service
abstract class NetworkService {
  Future<List<dynamic>> get(String endpoint,
      {Map<String, dynamic>? queryParams});
  Future<List<dynamic>> post(String endpoint,
      {required Map<String, dynamic> data});
  Future<List<dynamic>> put(String endpoint,
      {required Map<String, dynamic> data});
  Future<List<dynamic>> delete(String endpoint, {required String id});
}

// Network service implementation
class NetworkServiceImpl implements NetworkService {
  final SupabaseClient _supabase = GetIt.instance<SupabaseClient>();

  @override
  Future<List<dynamic>> get(String endpoint,
      {Map<String, dynamic>? queryParams}) async {
    var query = _supabase.from(endpoint).select('*');

    // Apply query parameters if provided
    if (queryParams != null) {
      queryParams.forEach((key, value) {
        if (value is List) {
          // Handle 'in' queries for lists
          // Note: Supabase doesn't have direct 'in_' method, we'd need to filter differently
          // For now, we'll skip this implementation detail
        } else {
          // Handle equality queries
          query = query.eq(key, value);
        }
      });
    }

    final response = await query;
    return response;
  }

  @override
  Future<List<dynamic>> post(String endpoint,
      {required Map<String, dynamic> data}) async {
    // Add timestamps
    final dataWithTimestamps = {
      ...data,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    final response = await _supabase.from(endpoint).insert(dataWithTimestamps);
    return response;
  }

  @override
  Future<List<dynamic>> put(String endpoint,
      {required Map<String, dynamic> data}) async {
    // Add update timestamp
    final dataWithTimestamp = {
      ...data,
      'updated_at': DateTime.now().toIso8601String(),
    };

    final response = await _supabase
        .from(endpoint)
        .update(dataWithTimestamp)
        .match({'id': data['id']});
    return response;
  }

  @override
  Future<List<dynamic>> delete(String endpoint, {required String id}) async {
    final response = await _supabase.from(endpoint).delete().match({'id': id});
    return response;
  }
}