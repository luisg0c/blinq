class PinService {
  static bool _isConfigured = false;

  static Future<bool> isPinConfigured() async {
    return _isConfigured;
  }

  static Future<void> setPinConfigured(bool value) async {
    _isConfigured = value;
  }
}
