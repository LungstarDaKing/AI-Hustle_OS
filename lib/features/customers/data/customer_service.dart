import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/di/auth_service.dart';
import '../domain/customer.dart';

// Abstract customer service
abstract class CustomerService {
  Future<List<Customer>> getCustomers({
    int limit = 50,
    int offset = 0,
    String? searchTerm,
  });

  Future<Customer?> getCustomerById(String id);

  Future<Customer> createCustomer(Customer customer);

  Future<Customer> updateCustomer(Customer customer);

  Future<void> deleteCustomer(String id);

  Future<List<Customer>> searchCustomers(String query);
}

// Customer service implementation
class CustomerServiceImpl implements CustomerService {
  final SupabaseClient _supabase = GetIt.instance<SupabaseClient>();

  @override
  Future<List<Customer>> getCustomers({
    int limit = 50,
    int offset = 0,
    String? searchTerm,
  }) async {
    var query = _supabase.from('customers').select('*');

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
      query = query.or('name.ilike.%$searchTerm%,phone_number.ilike.%$searchTerm%,email.ilike.%$searchTerm%');
    }

    // Apply pagination and execute query
    final response = await query.range(offset, offset + limit - 1);
    return response.map((map) => Customer.fromMap(map)).toList();
  }

  @override
  Future<Customer?> getCustomerById(String id) async {
    final String? userId = GetIt.instance<AuthService>().getCurrentUserId();
    if (userId == null) return null;

    // Get user's business ID
    final businessResponse =
        await _supabase.from('businesses').select('id').eq('user_id', userId);
    if (businessResponse.isEmpty) return null;
    final String businessId = businessResponse[0]['id'];

    final response = await _supabase
        .from('customers')
        .select('*')
        .eq('id', id)
        .eq('business_id', businessId)
        .single();

    return Customer.fromMap(response);
  }

  @override
  Future<Customer> createCustomer(Customer customer) async {
    final String? userId = GetIt.instance<AuthService>().getCurrentUserId();
    if (userId == null) throw Exception('User not authenticated');

    // Get user's business ID
    final businessResponse =
        await _supabase.from('businesses').select('id').eq('user_id', userId);
    if (businessResponse.isEmpty) throw Exception('Business not found');
    final String businessId = businessResponse[0]['id'];

    final customerMap = customer.toMap();
    customerMap['business_id'] = businessId; // Ensure business_id is set correctly

    final response = await _supabase.from('customers').insert(customerMap);
    if (response.isEmpty) throw Exception('Failed to create customer');
    return Customer.fromMap(response[0]);
  }

  @override
  Future<Customer> updateCustomer(Customer customer) async {
    final String? userId = GetIt.instance<AuthService>().getCurrentUserId();
    if (userId == null) throw Exception('User not authenticated');

    // Get user's business ID
    final businessResponse =
        await _supabase.from('businesses').select('id').eq('user_id', userId);
    if (businessResponse.isEmpty) throw Exception('Business not found');
    final String businessId = businessResponse[0]['id'];

    // Verify the customer belongs to the user's business
    await _supabase.from('customers').select('*').eq('id', customer.id).eq('business_id', businessId).single();

    final response = await _supabase
        .from('customers')
        .update(customer.toMap())
        .eq('id', customer.id)
        .eq('business_id', businessId);

    if (response.isEmpty) throw Exception('Failed to update customer');
    return Customer.fromMap(response[0]);
  }

  @override
  Future<void> deleteCustomer(String id) async {
    final String? userId = GetIt.instance<AuthService>().getCurrentUserId();
    if (userId == null) throw Exception('User not authenticated');

    // Get user's business ID
    final businessResponse =
        await _supabase.from('businesses').select('id').eq('user_id', userId);
    if (businessResponse.isEmpty) throw Exception('Business not found');
    final String businessId = businessResponse[0]['id'];

    // Verify the customer belongs to the user's business
    await _supabase.from('customers').select('*').eq('id', id).eq('business_id', businessId).single();

    await _supabase
        .from('customers')
        .delete()
        .eq('id', id)
        .eq('business_id', businessId);
  }

  @override
  Future<List<Customer>> searchCustomers(String query) async {
    if (query.isEmpty) return await getCustomers();

    final String? userId = GetIt.instance<AuthService>().getCurrentUserId();
    if (userId == null) return [];

    // Get user's business ID
    final businessResponse =
        await _supabase.from('businesses').select('id').eq('user_id', userId);
    if (businessResponse.isEmpty) return [];
    final String businessId = businessResponse[0]['id'];

    final response = await _supabase
        .from('customers')
        .select('*')
        .eq('business_id', businessId)
        .or('name.ilike.%$query%,phone_number.ilike.%$query%,email.ilike.%$query%');

    return response.map((map) => Customer.fromMap(map)).toList();
  }
}