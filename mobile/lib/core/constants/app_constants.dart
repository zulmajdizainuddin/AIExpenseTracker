class AppConstants {
  AppConstants._();

  /// Defaults to the Android-emulator alias for the host machine. Override
  /// at launch for other targets instead of editing this file, e.g.:
  ///   flutter run -d <physical-device-id> --dart-define=API_BASE_URL=http://127.0.0.1:8000/api/v1
  ///   flutter run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1:8000/api/v1
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api/v1',
  );
  static const String tokenKey = 'auth_token';
  static const String userKey = 'auth_user';
  static const int connectTimeoutMs = 15000;
  static const int receiveTimeoutMs = 30000;
}
