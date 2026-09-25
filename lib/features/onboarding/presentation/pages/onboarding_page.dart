import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/di/preferences_service.dart';
import '../../../../core/config/app_constants.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/onboarding_step_indicator.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  String _selectedBusinessType = '';
  String _selectedIndustry = '';
  final _locationController = TextEditingController();
  String _selectedCurrency = 'ZAR';
  final _productsServicesController = TextEditingController();
  bool _sellsProducts = true;
  bool _sellsServices = true;
  int _customerCount = 0;
  bool _tracksInventory = false;
  bool _issuesInvoices = false;
  final _businessGoalsController = TextEditingController();
  bool _isLoading = false;

  final List<String> _businessTypes = [
    'Sole Proprietorship',
    'Partnership',
    'Private Company (Pty) Ltd',
    'Close Corporation',
    'Cooperative',
    'Non-Profit Organization',
  ];

  final List<String> _industries = [
    'Barber Shop',
    'Hair Salon',
    'Nail Business',
    'Car Wash',
    'Clothing Business',
    'Catering Business',
    'Photography Business',
    'Cleaning Business',
    'Plumbing Business',
    'Electrical Business',
    'Tutoring Business',
    'Repair Business',
    'Construction Business',
    'Food Business',
    'Online Business',
    'Freelance Business',
    'Small Retail Business',
    'Home-based Business',
    'Service Business',
    'Other',
  ];

  final List<String> _currencies = [
    'ZAR (South African Rand)',
    'USD (US Dollar)',
    'EUR (Euro)',
    'GBP (British Pound)',
  ];

  @override
  void dispose() {
    _businessNameController.dispose();
    _ownerNameController.dispose();
    _locationController.dispose();
    _productsServicesController.dispose();
    _businessGoalsController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      // Save onboarding completion status
      await locator<PreferencesService>().set<bool>(
        AppConstants.hasCompletedOnboardingKey,
        true,
      );

      // TODO: Save business profile to database
      // For now, we'll just navigate to home
      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to complete setup: $e'),
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
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Progress indicator
                OnboardingStepIndicator(
                  currentStep: 1,
                  totalSteps: 1,
                ),
                const SizedBox(height: 32),

                // Welcome message
                const Text(
                  'Let\'s set up your business',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Answer a few questions to personalize your experience',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Business name
                CustomTextField(
                  controller: _businessNameController,
                  labelText: 'Business Name',
                  hintText: 'Enter your business name',
                  icon: Icons.business,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your business name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Owner name
                CustomTextField(
                  controller: _ownerNameController,
                  labelText: 'Owner Name',
                  hintText: 'Enter your full name',
                  icon: Icons.person,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Business type
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Business Type',
                    prefixIcon: Icon(Icons.business_center_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                  ),
                  initialValue: _selectedBusinessType.isEmpty ? null : _selectedBusinessType,
                  items: _businessTypes
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedBusinessType = value!;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select your business type';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Industry
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Industry/Category',
                    prefixIcon: Icon(Icons.category_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                  ),
                  initialValue: _selectedIndustry.isEmpty ? null : _selectedIndustry,
                  items: _industries
                      .map((industry) => DropdownMenuItem(
                            value: industry,
                            child: Text(industry),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedIndustry = value!;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select your industry';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Location
                CustomTextField(
                  controller: _locationController,
                  labelText: 'Location',
                  hintText: 'Enter your business location (city, area)',
                  icon: Icons.location_on_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your location';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Currency
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Currency',
                    prefixIcon: Icon(Icons.currency_exchange_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                  ),
                  initialValue: _selectedCurrency == 'ZAR' ? 'ZAR (South African Rand)' : null,
                  items: _currencies
                      .map((currency) => DropdownMenuItem(
                            value: currency,
                            child: Text(currency),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCurrency = value!.split(' ')[0];
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Products/Services
                CustomTextField(
                  controller: _productsServicesController,
                  labelText: 'Main Products/Services',
                  hintText: 'What products or services do you offer?',
                  icon: Icons.shopping_bag_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your main products/services';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // What you sell
                const Text(
                  'What do you sell?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: CheckboxListTile(
                        title: const Text('Products'),
                        value: _sellsProducts,
                        onChanged: (value) {
                          setState(() {
                            _sellsProducts = value!;
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    Expanded(
                      child: CheckboxListTile(
                        title: const Text('Services'),
                        value: _sellsServices,
                        onChanged: (value) {
                          setState(() {
                            _sellsServices = value!;
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Customer count
                DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    labelText: 'Approximate Number of Customers',
                    prefixIcon: Icon(Icons.people_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                  ),
                  initialValue: _customerCount == 0 ? null : _customerCount,
                  items: [
                    0,
                    10,
                    25,
                    50,
                    100,
                    200,
                    500,
                    1000,
                  ]
                      .map((count) => DropdownMenuItem(
                            value: count,
                            child: Text(count == 0 ? 'Just starting' : '$count+'),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _customerCount = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Inventory tracking
                CheckboxListTile(
                  title: const Text('Do you track inventory?'),
                  value: _tracksInventory,
                  onChanged: (value) {
                    setState(() {
                      _tracksInventory = value!;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 16),

                // Invoicing
                CheckboxListTile(
                  title: const Text('Do you issue invoices?'),
                  value: _issuesInvoices,
                  onChanged: (value) {
                    setState(() {
                      _issuesInvoices = value!;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 24),

                // Business goals
                CustomTextField(
                  controller: _businessGoalsController,
                  labelText: 'Business Goals (Optional)',
                  hintText: 'What are your business goals?',
                  icon: Icons.flag_outlined,
                  maxLines: 3,
                ),
                const SizedBox(height: 32),

                // Complete setup button
                CustomButton(
                  text: _isLoading ? 'Setting up...' : 'Complete Setup',
                  onPressed: _isLoading ? null : _completeOnboarding,
                  isLoading: _isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}