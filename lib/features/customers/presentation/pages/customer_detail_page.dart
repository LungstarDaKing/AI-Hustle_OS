import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../features/customers/data/customer_service.dart';
import '../../domain/customer.dart';

class CustomerDetailPage extends StatefulWidget {
  final String customerId;

  const CustomerDetailPage({
    super.key,
    required this.customerId,
  });

  @override
  State<CustomerDetailPage> createState() => _CustomerDetailPageState();
}

class _CustomerDetailPageState extends State<CustomerDetailPage> {
  bool _isLoading = true;
  Customer? _customer;

  @override
  void initState() {
    super.initState();
    _loadCustomer();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadCustomer() async {
    setState(() => _isLoading = true);
    try {
      final customerService = locator<CustomerService>();
      final customer = await customerService.getCustomerById(widget.customerId);
      if (!mounted) return;
      setState(() {
        _customer = customer;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      // In a real app, we'd show an error message
      debugPrint('Error loading customer: $e');
    }
  }

  Future<void> _refreshCustomer() async {
    await _loadCustomer();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_customer == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Customer Not Found'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(
          child: Text('Customer not found or access denied.'),
        ),
      );
    }

    final customer = _customer!;

    return Scaffold(
      appBar: AppBar(
        title: Text(customer.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit customer',
            onPressed: () => context.go('/customers/${customer.id}/edit'),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Delete customer',
            onPressed: () => _deleteCustomer(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshCustomer,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Customer avatar and name
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      child: Text(
                        customer.name.isNotEmpty
                            ? customer.name[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      customer.name,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Contact information
              _buildInfoCard(
                context,
                'Contact Information',
                [
                  if (customer.phoneNumber != null &&
                      customer.phoneNumber!.isNotEmpty)
                    _buildInfoRow(Icons.phone, 'Phone', customer.phoneNumber!),
                  if (customer.email != null &&
                      customer.email!.isNotEmpty)
                    _buildInfoRow(Icons.email, 'Email', customer.email!),
                ],
              ),
              const SizedBox(height: 16),

              // Address
              if (customer.address != null && customer.address!.isNotEmpty)
                _buildInfoCard(
                  context,
                  'Address',
                  [_buildInfoRow(Icons.home, 'Address', customer.address!)],
                ),
              const SizedBox(height: 16),

              // Notes
              if (customer.notes != null && customer.notes!.isNotEmpty)
                _buildInfoCard(
                  context,
                  'Notes',
                  [_buildInfoRow(Icons.note, 'Notes', customer.notes!)],
                ),
              const SizedBox(height: 16),

              // Statistics
              _buildInfoCard(
                context,
                'Statistics',
                [
                  _buildInfoRow(
                      Icons.attach_money, 'Total Spent', '\$${customer.totalSpent.toStringAsFixed(2)}'),
                  _buildInfoRow(
                      Icons.account_balance_wallet,
                      'Outstanding Balance',
                      '\$${customer.outstandingBalance.toStringAsFixed(2)}'),
                  _buildInfoRow(
                      Icons.access_time,
                      'Last Interaction',
                      customer.lastInteraction != null
                          ? customer.lastInteraction!
                                  .toLocal()
                                  .toString()
                                  .split('.')[0]
                          : 'Never'),
                ],
              ),
              const SizedBox(height: 16),

              // Timestamps
              _buildInfoCard(
                context,
                'Information',
                [
                  _buildInfoRow(
                      Icons.calendar_today, 'Created', customer.createdAt.toLocal().toString().split('.')[0]),
                  _buildInfoRow(
                      Icons.update, 'Updated', customer.updatedAt.toLocal().toString().split('.')[0]),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, String title, List<Widget> children) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Column(children: children),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$label: $value',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCustomer(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Customer'),
        content: Text(
            'Are you sure you want to delete "${_customer?.name}"? This action cannot be undone.'),
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
      setState(() => _isLoading = true);
      try {
        final customerService = locator<CustomerService>();
        await customerService.deleteCustomer(widget.customerId);
        if (!mounted) return;
        // Use context only if still mounted
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Customer deleted successfully'),
              backgroundColor: Theme.of(context).colorScheme.primary, // Using primary as success fallback
            ),
          );
        }
        // Navigate back to list
        if (mounted) {
          context.go('/customers');
        }
      } catch (e) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete customer: $e'),
              backgroundColor: Theme.of(context).colorScheme.error, // error exists on ColorScheme
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }
}