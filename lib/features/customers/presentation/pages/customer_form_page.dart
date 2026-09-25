import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../features/customers/data/customer_service.dart';
import '../../domain/customer.dart';

class CustomerFormPage extends StatefulWidget {
  final String? customerId; // If null, we're creating; if not null, we're editing

  const CustomerFormPage({
    super.key,
    this.customerId,
  });

  @override
  State<CustomerFormPage> createState() => _CustomerFormPageState();
}

class _CustomerFormPageState extends State<CustomerFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isLoading = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Load customer data if editing
    if (widget.customerId != null) {
      _loadCustomer();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize form with customer data after first build
    if (widget.customerId != null && !_isInitialized) {
      _isInitialized = true;
      _loadCustomer();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomer() async {
    if (widget.customerId == null) return;
    try {
      final customerService = locator<CustomerService>();
      final customer = await customerService.getCustomerById(widget.customerId!);
      if (!mounted) return;
      if (customer != null) {
        setState(() {
          _nameController.text = customer.name;
          _phoneController.text = customer.phoneNumber ?? '';
          _emailController.text = customer.email ?? '';
          _addressController.text = customer.address ?? '';
          _notesController.text = customer.notes ?? '';
        });
      }
    } catch (e) {
      debugPrint('Error loading customer: $e');
      if (mounted) {
        setState(() {
          // Leave fields empty if load fails
        });
      }
    }
  }

  Future<void> _saveCustomer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final customerService = locator<CustomerService>();

      final customer = Customer(
        id: widget.customerId, // Will be null for create, non-null for update
        businessId: widget.customerId ?? '', // Will be filled by service from current user's business
        name: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );

      if (widget.customerId == null) {
        // Create new customer
        await customerService.createCustomer(customer);
        if (!mounted) return;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Customer created successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Update existing customer
        await customerService.updateCustomer(customer);
        if (!mounted) return;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Customer updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
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
            content: Text('Failed to save customer: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEdit = widget.customerId != null;
    final String title = isEdit ? 'Edit Customer' : 'Add New Customer';
    final String submitButtonText = isEdit ? 'Update Customer' : 'Add Customer';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (isEdit)
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: 'Delete customer',
              onPressed: _isLoading
                  ? null
                  : () => _deleteCustomer(context),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Name
                      CustomTextField(
                        controller: _nameController,
                        labelText: 'Customer Name *',
                        hintText: 'Enter customer name',
                        icon: Icons.person,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter customer name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Phone
                      CustomTextField(
                        controller: _phoneController,
                        labelText: 'Phone Number',
                        hintText: 'Enter phone number',
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            // Basic phone validation
                            if (!RegExp(r'^[\d\s\-\(\)\+]+$').hasMatch(value)) {
                              return 'Please enter a valid phone number';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Email
                      CustomTextField(
                        controller: _emailController,
                        labelText: 'Email Address',
                        hintText: 'Enter email address',
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            if (!RegExp(
                                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                .hasMatch(value)) {
                              return 'Please enter a valid email address';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Address
                      CustomTextField(
                        controller: _addressController,
                        labelText: 'Address',
                        hintText: 'Enter address',
                        icon: Icons.home,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),

                      // Notes
                      CustomTextField(
                        controller: _notesController,
                        labelText: 'Notes',
                        hintText: 'Enter any additional notes',
                        icon: Icons.note,
                        maxLines: 5,
                      ),
                      const SizedBox(height: 24),

                      // Submit button
                      CustomButton(
                        text: _isLoading ? 'Saving...' : submitButtonText,
                        onPressed: _isLoading ? null : _saveCustomer,
                        isLoading: _isLoading,
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Future<void> _deleteCustomer(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Customer'),
        content: Text(
            'Are you sure you want to delete "${_nameController.text}"? This action cannot be undone.'),
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
        await customerService.deleteCustomer(widget.customerId!);
        if (!mounted) return;
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
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }
}