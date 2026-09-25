import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/di/auth_service.dart';
import '../domain/service.dart';

// Abstract service service
abstract class ServiceService {
  Future<List<Service>> getServices({
    int limit = 50,
    int offset = 0,
    String? searchTerm,
    String? categoryFilter,
  });

  Future<Service?> getServiceById(String id);

  Future<Service> createService(Service service);

  Future<Service> updateService(Service service);

  Future<void> deleteService(String id);

  Future<List<Service>> searchServices(String query);
}

// Service service implementation
class ServiceServiceImpl implements ServiceService {
  final SupabaseClient _supabase = GetIt.instance<SupabaseClient>();

  @override
  Future<List<Service>> getServices({
    int limit = 50,
    int offset = 0,
    String? searchTerm,
    String? categoryFilter,
  }) async {
    var query = _supabase.from('services').select('*');

    // Apply business filter (get current user's business)
    final String? userId = GetIt.instance<AuthService>().getCurrentUserId();
    if (userId != null) {
      // We need to get the business ID for the current user first
      final businessResponse =
          await _supabase.from('businesses').select('id').eq('user_id', userId);
      if (businessResponse.isNotEmpty) {
        final String businessId = businessResponse[0]['id'];
        query = query.eq('business_id', businessId);
      }
    }

    // Apply search term if provided
    if (searchTerm != null && searchTerm.isNotEmpty) {
      query = query.or('name.ilike.%$searchTerm%,description.ilike.%$searchTerm%');
    }

    // Apply category filter if provided
    if (categoryFilter != null && categoryFilter.isNotEmpty) {
      query = query.eq('category', categoryFilter);
    }

    // Apply pagination and execute query
    final response = await query.range(offset, offset + limit - 1);
    return response.map((map) => Service.fromMap(map)).toList();
  }

  @override
  Future<Service?> getServiceById(String id) async {
    final String? userId = GetIt.instance<AuthService>().getCurrentUserId();
    if (userId == null) return null;

    // Get user's business ID
    final businessResponse =
        await _supabase.from('businesses').select('id').eq('user_id', userId);
    if (businessResponse.isEmpty) return null;
    final String businessId = businessResponse[0]['id'];

    final response = await _supabase
        .from('services')
        .select('*')
        .eq('id', id)
        .eq('business_id', businessId)
        .single();

    return Service.fromMap(response);
  }

  @override
  Future<Service> createService(Service service) async {
    final String? userId = GetIt.instance<AuthService>().getCurrentUserId();
    if (userId == null) throw Exception('User not authenticated');

    // Get user's business ID
    final businessResponse =
        await _supabase.from('businesses').select('id').eq('user_id', userId);
    if (businessResponse.isEmpty) throw Exception('Business not found');
    final String businessId = businessResponse[0]['id'];

    final serviceMap = service.toMap();
    serviceMap['business_id'] = businessId; // Ensure business_id is set correctly

    final response = await _supabase.from('services').insert(serviceMap);
    if (response.isEmpty) throw Exception('Failed to create service');
    return Service.fromMap(response[0]);
  }

  @override
  Future<Service> updateService(Service service) async {
    final String? userId = GetIt.instance<AuthService>().getCurrentUserId();
    if (userId == null) throw Exception('User not authenticated');

    // Get user's business ID
    final businessResponse =
        await _supabase.from('businesses').select('id').eq('user_id', userId);
    if (businessResponse.isEmpty) throw Exception('Business not found');
    final String businessId = businessResponse[0]['id'];

    // Verify the service belongs to the user's business
    await _supabase.from('services').select('*').eq('id', service.id).eq('business_id', businessId).single();

    final response = await _supabase
        .from('services')
        .update(service.toMap())
        .eq('id', service.id)
        .eq('business_id', businessId);

    if (response.isEmpty) throw Exception('Failed to update service');
    return Service.fromMap(response[0]);
  }

  @override
  Future<void> deleteService(String id) async {
    final String? userId = GetIt.instance<AuthService>().getCurrentUserId();
    if (userId == null) throw Exception('User not authenticated');

    // Get user's business ID
    final businessResponse =
        await _supabase.from('businesses').select('id').eq('user_id', userId);
    if (businessResponse.isEmpty) throw Exception('Business not found');
    final String businessId = businessResponse[0]['id'];

    // Verify the service belongs to the user's business
    await _supabase.from('services').select('*').eq('id', id).eq('business_id', businessId).single();

    await _supabase
        .from('services')
        .delete()
        .eq('id', id)
        .eq('business_id', businessId);
  }

  @override
  Future<List<Service>> searchServices(String query) async {
    if (query.isEmpty) return await getServices();

    final String? userId = GetIt.instance<AuthService>().getCurrentUserId();
    if (userId == null) return [];

    // Get user's business ID
    final businessResponse =
        await _supabase.from('businesses').select('id').eq('user_id', userId);
    if (businessResponse.isEmpty) return [];
    final String businessId = businessResponse[0]['id'];

    final response = await _supabase
        .from('services')
        .select('*')
        .eq('business_id', businessId)
        .or('name.ilike.%$query%,description.ilike.%$query%');

    return response.map((map) => Service.fromMap(map)).toList();
  }
}