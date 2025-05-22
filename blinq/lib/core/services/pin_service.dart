class PinService {
  static Future<bool> isPinConfigured() async {
    // Simulação: em produção, consulte um storage seguro.
    return Future.value(true);
  }
}
