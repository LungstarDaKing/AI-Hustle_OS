import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../features/customers/data/customer_service.dart';
import '../../domain/customer.dart';

class CustomersListPage extends StatefulWidget {
  const CustomersListPage({super.key});

  @override
  State<CustomersListPage> createState() => _CustomersListPageState();
}

class _CustomersListPageState extends State<CustomersListPage> {
  final _searchController = TextEditingController();
  bool _isLoading = false;
  bool _isSearching = false;
  List<Customer> _customers = [];
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomers({String? searchTerm}) async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final customerService = locator<CustomerService>();
      final customers = await customerService.getCustomers(
        searchTerm: searchTerm ?? _searchTerm,
      );
      if (!mounted) return;
      setState(() {
        _customers = customers;
        _isLoading = false;
        if (searchTerm != null) {
          _isSearching = searchTerm.isNotEmpty;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      // In a real app, we'd show an error message
      debugPrint('Error loading customers: $e');
    }
  }

  Future<void> _refreshCustomers() async {
    await _loadCustomers();
  }

  void _onSearchChanged(String value) {
    // Debounce search - only search when user stops typing for 300ms
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      if (_searchController.text == value) {
        _loadCustomers(searchTerm: value);
      }
    });
  }

  void _onSearchSubmitted(String value) {
    _loadCustomers(searchTerm: value);
  }

  void _onClearSearch() {
    _searchController.clear();
    _loadCustomers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add new customer',
            onPressed: _isLoading
                ? null
                : () => context.go('/customers/new'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextFormField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search customers by name, phone, or email',
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
              onFieldSubmitted: _onSearchSubmitted,
            ),
          ),
          const Divider(height: 1),

          // Customers list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _customers.isEmpty
                    ? Center(
                        child: Text(
                          _isSearching
                              ? 'No customers found'
                              : 'No customers yet. Add your first customer!',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _refreshCustomers,
                        child: ListView.separated(
                          itemCount: _customers.length,
                          separatorBuilder: (context, index) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final customer = _customers[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                child: Text(
                                  customer.name.isNotEmpty
                                      ? customer.name[0].toUpperCase()
                                      : '?',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                customer.name,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (customer.phoneNumber != null &&
                                      customer.phoneNumber!.isNotEmpty)
                                    Text(
                                      '📱 ${customer.phoneNumber}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withValues(alpha: 0.7),
                                      ),
                                    ),
                                  if (customer.email != null &&
                                      customer.email!.isNotEmpty)
                                    Text(
                                      '📧 ${customer.email}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withValues(alpha: 0.7),
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
                                    context.go('/customers/${customer.id}/edit');
                                  } else if (value == 2) {
                                    // Delete
                                    if (!mounted) return;
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Delete Customer'),
                                        content: Text(
                                            'Are you sure you want to delete "${customer.name}"? This action cannot be undone.'),
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
                                      await _deleteCustomer(customer.id);
                                    }
                                  }
                                },
                              ),
                              onTap: () {
                                if (!mounted) return;
                                context.go('/customers/${customer.id}');
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
            : () => context.go('/customers/new'),
        label: Text(_isLoading ? 'Saving...' : 'Add Customer'),
        icon: _isLoading ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ) : const Icon(Icons.person_add),
      ),
    );
  }

  Future<void> _deleteCustomer(String id) async {
    setState(() => _isLoading = true);
    try {
      final customerService = locator<CustomerService>();
      await customerService.deleteCustomer(id);
      if (!mounted) return;
      await _loadCustomers(); // Refresh the list
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Customer deleted successfully'),
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
            content: Text('Failed to delete customer: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}