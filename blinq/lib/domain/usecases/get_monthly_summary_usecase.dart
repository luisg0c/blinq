import '../repositories/transaction_repository.dart';

class MonthlySummary {
  final double entradas;
  final double saidas;
  final double total;

  MonthlySummary({
    required this.entradas,
    required this.saidas,
  }) : total = entradas - saidas;
}

class GetMonthlySummaryUseCase {
  final TransactionRepository _repository;

  GetMonthlySummaryUseCase(this._repository);

  Future<MonthlySummary> execute({DateTime? referenceDate}) async {
    final now = referenceDate ?? DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 1).subtract(const Duration(seconds: 1));

    final all = await _repository.getTransactionsBetween(start: start, end: end);

    final entradas = all.where((t) => t.amount > 0).fold(0.0, (sum, t) => sum + t.amount);
    final saidas = all.where((t) => t.amount < 0).fold(0.0, (sum, t) => sum + t.amount.abs());

    return MonthlySummary(entradas: entradas, saidas: saidas);
  }
}