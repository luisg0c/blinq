/// Resultado do QR Code interpretado.
class ParsedQrData {
  final String email;
  final double amount;
  final String? description;

  ParsedQrData({
    required this.email,
    required this.amount,
    this.description,
  });
}

/// Caso de uso para interpretar um QR code gerado via [GenerateQrUseCase].
class ParseQrUseCase {
  ParsedQrData execute(String payload) {
    final uri = Uri.tryParse(payload);
    if (uri == null ||
        !uri.scheme.startsWith('blinq') ||
        uri.host != 'transfer') {
      throw Exception('QR inválido ou desconhecido');
    }

    final email = uri.queryParameters['email'];
    final amountStr = uri.queryParameters['amount'];
    final description = uri.queryParameters['desc'];

    if (email == null || amountStr == null) {
      throw Exception('QR incompleto');
    }

    final amount = double.tryParse(amountStr);
    if (amount == null || amount <= 0) {
      throw Exception('Valor inválido no QR');
    }

    return ParsedQrData(
      email: email,
      amount: amount,
      description: description,
    );
  }
}
