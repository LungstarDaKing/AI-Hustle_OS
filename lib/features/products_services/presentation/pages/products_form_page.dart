import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../domain/product.dart';
import '../../data/product_service.dart';

class ProductsFormPage extends StatefulWidget {
  final String? productId; // If null, we're creating; if not null, we're editing

  const ProductsFormPage({
    super.key,
    this.productId,
  });

  @override
  State<ProductsFormPage> createState() => _ProductsFormPageState();
}

class _ProductsFormPageState extends State<ProductsFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _skuController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _costController = TextEditingController();
  final _sellingPriceController = TextEditingController();
  final _categoryController = TextEditingController();
  final _quantityController = TextEditingController();
  final _minimumStockController = TextEditingController();
  final _supplierController = TextEditingController();
  bool _isLoading = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Load product data if editing
    if (widget.productId != null) {
      _loadProduct();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize form with product data after first build
    if (widget.productId != null && !_isInitialized) {
      _isInitialized = true;
      _loadProduct();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _descriptionController.dispose();
    _costController.dispose();
    _sellingPriceController.dispose();
    _categoryController.dispose();
    _quantityController.dispose();
    _minimumStockController.dispose();
    _supplierController.dispose();
    super.dispose();
  }

  Future<void> _loadProduct() async {
    if (widget.productId == null) return;
    try {
      final productService = locator<ProductService>();
      final product = await productService.getProductById(widget.productId!);
      if (!mounted) return;
      if (product != null) {
        setState(() {
          _nameController.text = product.name;
          _skuController.text = product.sku;
          _descriptionController.text = product.description ?? '';
          _costController.text = product.cost.toString();
          _sellingPriceController.text = product.sellingPrice.toString();
          _categoryController.text = product.category;
          _quantityController.text = product.quantity.toString();
          _minimumStockController.text = product.minimumStock.toString();
          _supplierController.text = product.supplier ?? '';
        });
      }
    } catch (e) {
      debugPrint('Error loading product: $e');
      if (mounted) {
        setState(() {
          // Leave fields empty if load fails
        });
      }
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final productService = locator<ProductService>();

      final product = Product(
        id: widget.productId, // Will be null for create, non-null for update
        businessId: '', // Will be filled by service from current user's business
        name: _nameController.text.trim(),
        sku: _skuController.text.trim(),
        description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        cost: double.tryParse(_costController.text) ?? 0.0,
        sellingPrice: double.tryParse(_sellingPriceController.text) ?? 0.0,
        category: _categoryController.text.trim(),
        quantity: int.tryParse(_quantityController.text) ?? 0,
        minimumStock: int.tryParse(_minimumStockController.text) ?? 0,
        supplier: _supplierController.text.trim().isEmpty ? null : _supplierController.text.trim(),
      );

      if (widget.productId == null) {
        // Create new product
        await productService.createProduct(product);
        if (!mounted) return;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Product created successfully'),
              backgroundColor: Theme.of(context).colorScheme.primary, // Using primary as success fallback
            ),
          );
        }
      } else {
        // Update existing product
        await productService.updateProduct(product);
        if (!mounted) return;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Product updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }

      // Navigate back to list
      if (mounted) {
        context.go('/products');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save product: $e'),
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
    final bool isEdit = widget.productId != null;
    final String title = isEdit ? 'Edit Product' : 'Add New Product';
    final String submitButtonText = isEdit ? 'Update Product' : 'Add Product';

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
              tooltip: 'Delete product',
              onPressed: _isLoading
                  ? null
                  : () => _deleteProduct(context),
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
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Product Name *',
                          hintText: 'Enter product name',
                          prefixIcon: Icon(Icons.title),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter product name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // SKU
                      TextFormField(
                        controller: _skuController,
                        decoration: const InputDecoration(
                          labelText: 'SKU *',
                          hintText: 'Enter SKU (Stock Keeping Unit)',
                          prefixIcon: Icon(Icons.qr_code_scanner),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter SKU';
                          }
                          // Basic SKU validation - alphanumeric and dashes/underscores
                          if (!RegExp(r'^[A-Z0-9_-]+$').hasMatch(value.toUpperCase())) {
                            return 'Please enter a valid SKU (letters, numbers, hyphens, underscores only)';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          hintText: 'Enter product description',
                          prefixIcon: Icon(Icons.description),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),

                      // Cost
                      TextFormField(
                        controller: _costController,
                        decoration: const InputDecoration(
                          labelText: 'Cost *',
                          hintText: 'Enter product cost',
                          prefixIcon: Icon(Icons.attach_money),
                        ),
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter cost';
                          }
                          final numValue = double.tryParse(value);
                          if (numValue == null) {
                            return 'Please enter a valid number';
                          }
                          if (numValue < 0) {
                            return 'Cost cannot be negative';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Selling Price
                      TextFormField(
                        controller: _sellingPriceController,
                        decoration: const InputDecoration(
                          labelText: 'Selling Price *',
                          hintText: 'Enter selling price',
                          prefixIcon: Icon(Icons.sell),
                        ),
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter selling price';
                          }
                          final numValue = double.tryParse(value);
                          if (numValue == null) {
                            return 'Please enter a valid number';
                          }
                          if (numValue < 0) {
                            return 'Selling price cannot be negative';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Category
                      TextFormField(
                        controller: _categoryController,
                        decoration: const InputDecoration(
                          labelText: 'Category *',
                          hintText: 'Enter product category',
                          prefixIcon: Icon(Icons.category),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter category';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Quantity
                      TextFormField(
                        controller: _quantityController,
                        decoration: const InputDecoration(
                          labelText: 'Quantity *',
                          hintText: 'Enter quantity in stock',
                          prefixIcon: Icon(Icons.numbers),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter quantity';
                          }
                          final numValue = int.tryParse(value);
                          if (numValue == null) {
                            return 'Please enter a valid number';
                          }
                          if (numValue < 0) {
                            return 'Quantity cannot be negative';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Minimum Stock
                      TextFormField(
                        controller: _minimumStockController,
                        decoration: const InputDecoration(
                          labelText: 'Minimum Stock *',
                          hintText: 'Enter minimum stock level',
                          prefixIcon: Icon(Icons.remove_circle_outline),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter minimum stock';
                          }
                          final numValue = int.tryParse(value);
                          if (numValue == null) {
                            return 'Please enter a valid number';
                          }
                          if (numValue < 0) {
                            return 'Minimum stock cannot be negative';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Supplier
                      TextFormField(
                        controller: _supplierController,
                        decoration: const InputDecoration(
                          labelText: 'Supplier',
                          hintText: 'Enter supplier name',
                          prefixIcon: Icon(Icons.business),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Submit button
                      ElevatedButton(
                        onPressed: _isLoading ? null : _saveProduct,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(submitButtonText),
                      ),
                    ],
                  ),
                ),
              ),
            ),
      floatingActionButton: !_isLoading && !isEdit
          ? FloatingActionButton(
              onPressed: () {
                // Clear form for new product
                _formKey.currentState?.reset();
                setState(() {
                  _nameController.clear();
                  _skuController.clear();
                  _descriptionController.clear();
                  _costController.clear();
                  _sellingPriceController.clear();
                  _categoryController.clear();
                  _quantityController.clear();
                  _minimumStockController.clear();
                  _supplierController.clear();
                });
              },
              tooltip: 'Clear form',
              child: const Icon(Icons.clear_all),
            )
          : null,
    );
  }

  Future<void> _deleteProduct(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
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
        final productService = locator<ProductService>();
        await productService.deleteProduct(widget.productId!);
        if (!mounted) return;
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Product deleted successfully'),
              backgroundColor: Theme.of(context).colorScheme.primary, // Using primary as success fallback
            ),
          );
        }
        // Navigate back to list
        if (mounted) {
          context.go('/products');
        }
      } catch (e) {
        if (!mounted) return;
        setState(() => _isLoading = false);
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
}