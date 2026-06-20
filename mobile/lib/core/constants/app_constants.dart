class AppConstants {
  AppConstants._();

  static const String baseUrl = 'http://10.0.2.2:8000/api/v1'; // Android emulator → host:8000
  static const String tokenKey = 'auth_token';
  static const String userKey = 'auth_user';
  static const int connectTimeoutMs = 15000;
  static const int receiveTimeoutMs = 30000;
}
