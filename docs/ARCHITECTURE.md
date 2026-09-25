# AI HustleOS Architecture

## Overview
AI HustleOS is a Flutter-based business management application designed for South African micro-businesses, following a feature-first architecture with clean separation of concerns.

## Architectural Principles
- Feature-first organization
- Clean separation of presentation, domain/business logic, and data
- Repositories/services for data access
- Dependency injection where useful
- Strongly typed models
- Reusable widgets
- Centralized routing
- Centralized theme
- Proper error handling
- Proper loading states
- Proper empty states

## Project Structure
```
lib/
├── core/                     # Core utilities and shared code
│   ├── config/               # Configuration and constants
│   ├── di/                   # Dependency injection setup
│   ├── error/                # Error handling and exceptions
│   ├── network/              # Network utilities and API clients
│   ├── storage/              # Local storage utilities
│   ├── utils/                # Helper functions and extensions
│   └── widgets/              # Shared/reusable widgets
├── features/                 # Feature-based organization
│   ├── auth/                 # Authentication features
│   ├── onboarding/           # Onboarding flow
│   ├── home/                 # Dashboard/home screen
│   ├── business_profile/     # Business profile management
│   ├── customers/            # Customer management (CRM)
│   ├── products_services/    # Products and services management
│   ├── inventory/            # Inventory management
│   ├── transactions/         # Sales/transactions/POS
│   ├── expenses/             # Expense tracking
│   ├── invoices/             # Invoicing system
│   ├── appointments/         # Appointment scheduling
│   ├── suppliers/            # Supplier management
│   ├── analytics/            # Financial analytics
│   ├── goals/                # Business goals tracking
│   ├── marketing/            # Marketing AI assistant
│   ├── ai_assistant/         # AI business assistant
│   ├── notifications/        # Notification system
│   └── search/               # Global search functionality
├── shared/                   # Shared code across features
│   ├── models/               # Data models used across features
│   ├── enums/                # Shared enums
│   └── typedefs/             # Shared typedefs
└── main.dart                 # Application entry point
```

## State Management
- Using Provider for state management (chosen for its simplicity and good performance)
- Separate state objects for each feature
- Global state for authentication and user profile

## Data Layer
- Supabase backend for authentication, database, and storage
- Local caching for offline-first capability
- Repository pattern for data access
- Secure storage for sensitive data

## Navigation
- Centralized routing using GoRouter
- Bottom navigation for primary sections
- Nested navigation for feature-specific screens

## Security
- Authentication via Supabase (email/password)
- Row Level Security (RLS) on Supabase database
- No hardcoded secrets in client code
- Input validation and sanitization
- Secure API communication

## AI Integration
- AI assistant backed by controlled backend services
- Structured function calling for AI to access business data
- Prompt injection protection
- Data privacy controls

## Offline-First Approach
- Local database caching using Hive or Sembast
- Queue-based synchronization for critical operations
- Graceful degradation when offline
- Clear offline status indicators

## Dependencies
Core dependencies specified in pubspec.yaml:
- flutter_svg: For SVG assets
- provider: State management
- go_router: Navigation
- supabase_flutter: Backend integration
- hive: Local caching (for offline support)
- intl: Internationalization
- flutter_local_notifications: Local notifications
- share_plus: Sharing content
- url_launcher: Launching URLs
- image_picker: Image selection
- flutter_bloc: For complex state management where needed
- charts_flutter: For analytics charts
- uuid: Unique ID generation