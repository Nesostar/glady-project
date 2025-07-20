class ApiConfig {
  // ZenoPay API Configuration
  static const String zenoPayBaseUrl =
      'https://phpstack-922297-3201544.cloudwaysapps.com/tukiopay/payment';
  static const String zenoPayStatusUrl =
      'https://phpstack-922297-3201544.cloudwaysapps.com/tukiopay/status';

  // Headers for ZenoPay API
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    // Add your API key here when you get it from ZenoPay
    // 'Authorization': 'Bearer YOUR_API_KEY',
  };
}
