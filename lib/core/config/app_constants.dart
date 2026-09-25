class AppConstants {
  // Supabase configuration
  // In a real app, these would come from environment variables or secure storage
  // Using fake but valid-looking values for testing
  static const String supabaseUrl = 'https://xyzcompany.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0';

  // Hive box names
  static const String preferencesBox = 'preferences_box';
  static const String offlineQueueBox = 'offline_queue_box';

  // Preferences keys
  static const String hasCompletedOnboardingKey = 'has_completed_onboarding';
  static const String userIdKey = 'user_id';
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';

  // Currency settings
  static const String defaultCurrency = 'ZAR';
  static const String currencySymbol = 'R';

  // Pagination
  static const int itemsPerPage = 20;

  // AI Configuration
  static const String aiModel = 'claude-3-5-sonnet-20241022';
  static const double aiTemperature = 0.7;

  // Notification channels
  static const String lowStockChannel = 'low_stock';
  static const String overdueInvoiceChannel = 'overdue_invoice';
  static const String upcomingAppointmentChannel = 'upcoming_appointment';
  static const String goalMilestoneChannel = 'goal_milestone';
  static const String aiInsightChannel = 'ai_insight';

  // Date formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm';

  // Asset paths
  static const String assetImagesPath = 'assets/images/';
  static const String assetIconsPath = 'assets/icons/';
  static const String assetLogosPath = 'assets/logos/';
  static const String assetAnimationsPath = 'assets/animations/';
  static const String assetFontsPath = 'assets/fonts/';
}