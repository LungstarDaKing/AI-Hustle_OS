import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../domain/product.dart';
import '../../data/product_service.dart';

class ProductsListPage extends StatefulWidget {
  const ProductsListPage({super.key});

  @override
  State<ProductsListPage> createState() => _ProductsListPageState();
}

class _ProductsListPageState extends State<ProductsListPage> {
  final _searchController = TextEditingController();
  bool _isLoading = false;
  bool _isSearching = false;
  List<Product> _products = [];
  String _searchTerm = '';
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts({String? searchTerm, String? category}) async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final productService = locator<ProductService>();
      final products = await productService.getProducts(
        searchTerm: searchTerm ?? _searchTerm,
        categoryFilter: category ?? _selectedCategory,
      );
      if (!mounted) return;
      setState(() {
        _products = products;
        _isLoading = false;
        if (searchTerm != null) {
          _isSearching = searchTerm.isNotEmpty;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      // In a real app, we'd show an error message
      debugPrint('Error loading products: $e');
    }
  }

  Future<void> _refreshProducts() async {
    await _loadProducts();
  }

  void _onSearchChanged(String value) {
    // Debounce search - only search when user stops typing for 300ms
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      if (_searchController.text == value) {
        _loadProducts(searchTerm: value);
      }
    });
  }

  void _onSearchSubmitted(String value) {
    _loadProducts(searchTerm: value);
  }

  void _onClearSearch() {
    _searchController.clear();
    _loadProducts();
  }

  void _onCategoryChanged(String? value) {
    setState(() {
      _selectedCategory = value;
    });
    _loadProducts(category: _selectedCategory);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add new product',
            onPressed: _isLoading
                ? null
                : () => context.go('/products/new'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and filter bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search products by name, SKU, or description',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _isSearching
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: _onClearSearch,
                                )
                              : null,
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            ),
                          ),
                        ),
                        onChanged: _onSearchChanged,
                        onSubmitted: _onSearchSubmitted,
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 120,
                      child: DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        hint: const Text('Category'),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('All Categories'),
                          ),
                          // Categories will be populated dynamically in a real app
                          // For now, we'll add some common ones
                          const DropdownMenuItem(
                            value: 'Electronics',
                            child: Text('Electronics'),
                          ),
                          const DropdownMenuItem(
                            value: 'Clothing',
                            child: Text('Clothing'),
                          ),
                          const DropdownMenuItem(
                            value: 'Office Supplies',
                            child: Text('Office Supplies'),
                          ),
                        ],
                        onChanged: _onCategoryChanged,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Products list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _products.isEmpty
                    ? Center(
                        child: Text(
                          _isSearching
                              ? 'No products found'
                              : 'No products yet. Add your first product!',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _refreshProducts,
                        child: ListView.separated(
                          itemCount: _products.length,
                          separatorBuilder: (context, index) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final product = _products[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                child: Text(
                                  product.name.isNotEmpty
                                      ? product.name[0].toUpperCase()
                                      : '?',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                product.name,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'SKU: ${product.sku}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.7),
                                    ),
                                  ),
                                  Text(
                                    '\$${product.sellingPrice.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.7),
                                    ),
                                  ),
                                  if (product.quantity < product.minimumStock)
                                    Text(
                                      'LOW STOCK: ${product.quantity}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Theme.of(context).colorScheme.error,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                ],
                              ),
                              trailing: PopupMenuButton<int>(
                                icon: const Icon(Icons.more_vert),
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 1,
                                    child: ListTile(
                                      leading: Icon(Icons.edit),
                                      title: Text('Edit'),
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 2,
                                    child: ListTile(
                                      leading: Icon(Icons.delete),
                                      title: Text('Delete'),
                                    ),
                                  ),
                                ],
                                onSelected: (value) async {
                                  if (value == 1) {
                                    // Edit
                                    if (!mounted) return;
                                    context.go('/products/${product.id}/edit');
                                  } else if (value == 2) {
                                    // Delete
                                    if (!mounted) return;
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Delete Product'),
                                        content: Text(
                                            'Are you sure you want to delete "${product.name}"? This action cannot be undone.'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.of(context).pop(false),
                                            child: const Text('Cancel'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () => Navigator.of(context).pop(true),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Theme.of(context).colorScheme.error,
                                            ),
                                            child: const Text('Delete'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirm == true && mounted) {
                                      await _deleteProduct(product.id);
                                    }
                                  }
                                },
                              ),
                              onTap: () {
                                if (!mounted) return;
                                context.go('/products/${product.id}');
                              },
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoading
            ? null
            : () => context.go('/products/new'),
        label: Text(_isLoading ? 'Saving...' : 'Add Product'),
        icon: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.add),
      ),
    );
  }

  Future<void> _deleteProduct(String id) async {
    setState(() => _isLoading = true);
    try {
      final productService = locator<ProductService>();
      await productService.deleteProduct(id);
      if (!mounted) return;
      await _loadProducts(); // Refresh the list
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Product deleted successfully'),
            backgroundColor: Theme.of(context).colorScheme.primary, // Using primary as success fallback
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete product: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}