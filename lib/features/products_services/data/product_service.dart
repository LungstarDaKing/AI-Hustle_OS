import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/di/auth_service.dart';
import '../domain/product.dart';

// Abstract product service
abstract class ProductService {
  Future<List<Product>> getProducts({
    int limit = 50,
    int offset = 0,
    String? searchTerm,
    String? categoryFilter,
  });

  Future<Product?> getProductById(String id);

  Future<Product> createProduct(Product product);

  Future<Product> updateProduct(Product product);

  Future<void> deleteProduct(String id);

  Future<List<Product>> searchProducts(String query);
}

// Product service implementation
class ProductServiceImpl implements ProductService {
  final SupabaseClient _supabase = GetIt.instance<SupabaseClient>();

  @override
  Future<List<Product>> getProducts({
    int limit = 50,
    int offset = 0,
    String? searchTerm,
    String? categoryFilter,
  }) async {
    var query = _supabase.from('products').select('*');

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
      query = query.or('name.ilike.%$searchTerm%,sku.ilike.%$searchTerm%,description.ilike.%$searchTerm%');
    }

    // Apply category filter if provided
    if (categoryFilter != null && categoryFilter.isNotEmpty) {
      query = query.eq('category', categoryFilter);
    }

    // Apply pagination and execute query
    final response = await query.range(offset, offset + limit - 1);
    return response.map((map) => Product.fromMap(map)).toList();
  }

  @override
  Future<Product?> getProductById(String id) async {
    final String? userId = GetIt.instance<AuthService>().getCurrentUserId();
    if (userId == null) return null;

    // Get user's business ID
    final businessResponse =
        await _supabase.from('businesses').select('id').eq('user_id', userId);
    if (businessResponse.isEmpty) return null;
    final String businessId = businessResponse[0]['id'];

    final response = await _supabase
        .from('products')
        .select('*')
        .eq('id', id)
        .eq('business_id', businessId)
        .single();

    return Product.fromMap(response);
  }

  @override
  Future<Product> createProduct(Product product) async {
    final String? userId = GetIt.instance<AuthService>().getCurrentUserId();
    if (userId == null) throw Exception('User not authenticated');

    // Get user's business ID
    final businessResponse =
        await _supabase.from('businesses').select('id').eq('user_id', userId);
    if (businessResponse.isEmpty) throw Exception('Business not found');
    final String businessId = businessResponse[0]['id'];

    final productMap = product.toMap();
    productMap['business_id'] = businessId; // Ensure business_id is set correctly

    final response = await _supabase.from('products').insert(productMap);
    if (response.isEmpty) throw Exception('Failed to create product');
    return Product.fromMap(response[0]);
  }

  @override
  Future<Product> updateProduct(Product product) async {
    final String? userId = GetIt.instance<AuthService>().getCurrentUserId();
    if (userId == null) throw Exception('User not authenticated');

    // Get user's business ID
    final businessResponse =
        await _supabase.from('businesses').select('id').eq('user_id', userId);
    if (businessResponse.isEmpty) throw Exception('Business not found');
    final String businessId = businessResponse[0]['id'];

    // Verify the product belongs to the user's business
    await _supabase.from('products').select('*').eq('id', product.id).eq('business_id', businessId).single();

    final response = await _supabase
        .from('products')
        .update(product.toMap())
        .eq('id', product.id)
        .eq('business_id', businessId);

    if (response.isEmpty) throw Exception('Failed to update product');
    return Product.fromMap(response[0]);
  }

  @override
  Future<void> deleteProduct(String id) async {
    final String? userId = GetIt.instance<AuthService>().getCurrentUserId();
    if (userId == null) throw Exception('User not authenticated');

    // Get user's business ID
    final businessResponse =
        await _supabase.from('businesses').select('id').eq('user_id', userId);
    if (businessResponse.isEmpty) throw Exception('Business not found');
    final String businessId = businessResponse[0]['id'];

    // Verify the product belongs to the user's business
    await _supabase.from('products').select('*').eq('id', id).eq('business_id', businessId).single();

    await _supabase
        .from('products')
        .delete()
        .eq('id', id)
        .eq('business_id', businessId);
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    if (query.isEmpty) return await getProducts();

    final String? userId = GetIt.instance<AuthService>().getCurrentUserId();
    if (userId == null) return [];

    // Get user's business ID
    final businessResponse =
        await _supabase.from('businesses').select('id').eq('user_id', userId);
    if (businessResponse.isEmpty) return [];
    final String businessId = businessResponse[0]['id'];

    final response = await _supabase
        .from('products')
        .select('*')
        .eq('business_id', businessId)
        .or('name.ilike.%$query%,sku.ilike.%$query%,description.ilike.%$query%');

    return response.map((map) => Product.fromMap(map)).toList();
  }
}