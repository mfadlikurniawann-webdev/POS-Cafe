class AppConfig {
  static const String appName = 'Kopi Nusantara POS';
  static const String appVersion = '1.0.0';

  // Neon.tech PostgreSQL (Moved to Vercel Environment Variables)
  // Password is no longer stored in the app code for security!

  // Business
  static const double taxRate = 0.11; // 11% PPN
  static const String currencySymbol = 'Rp';
  static const String currencyLocale = 'id_ID';
}
