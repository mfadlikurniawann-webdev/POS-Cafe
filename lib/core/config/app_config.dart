class AppConfig {
  static const String appName = 'Kopi Nusantara POS';
  static const String appVersion = '1.0.0';

  // Neon.tech PostgreSQL
  static const String dbHost =
      'ep-royal-surf-aopa38s3-pooler.c-2.ap-southeast-1.aws.neon.tech';
  static const int dbPort = 5432;
  static const String dbName = 'neondb';
  static const String dbUser = 'neondb_owner';
  static const String dbPassword = 'npg_dwc7rRCm4uZo';

  // Business
  static const double taxRate = 0.11; // 11% PPN
  static const String currencySymbol = 'Rp';
  static const String currencyLocale = 'id_ID';
}
