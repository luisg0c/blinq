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
