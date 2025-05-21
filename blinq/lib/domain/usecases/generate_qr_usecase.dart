/// Caso de uso para gerar um payload de QR code.
///
/// Exemplo de formato gerado:
/// blinq://transfer?email=destino@exemplo.com&amount=50.0&desc=Pagamento
class GenerateQrUseCase {
  String execute({
    required String email,
    required double amount,
    String? description,
  }) {
    final base = 'blinq://transfer';
    final query = Uri(
      path: '',
      queryParameters: {
        'email': email,
        'amount': amount.toString(),
        if (description != null) 'desc': description,
      },
    ).query;

    return '$base?$query';
  }
}
